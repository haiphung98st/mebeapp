import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/who_growth_data.dart';
import '../models/growth_entry.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';
import 'baby_provider.dart';

double ageInMonthsAt(DateTime dateOfBirth, DateTime at) {
  final days = at.difference(dateOfBirth).inHours / 24;
  return days / 30.4375;
}

double? valueForMetric(GrowthEntry entry, GrowthMetric metric) {
  switch (metric) {
    case GrowthMetric.weight:
      return entry.weightKg;
    case GrowthMetric.height:
      return entry.heightCm;
    case GrowthMetric.headCircumference:
      return entry.headCircumferenceCm;
  }
}

final allGrowthsProvider = StreamProvider<List<GrowthEntry>>((ref) {
  final user = ref.watch(currentUserProvider);
  final baby = ref.watch(activeBabyProvider);
  if (user == null || baby == null) return Stream.value(const []);
  return ref.watch(firestoreServiceProvider).watchGrowths(user.uid, baby.id);
});

final latestGrowthProvider = Provider<GrowthEntry?>((ref) {
  final growths = ref.watch(allGrowthsProvider).value ?? const [];
  if (growths.isEmpty) return null;
  return growths.reduce((a, b) => a.measuredAt.isAfter(b.measuredAt) ? a : b);
});

class GrowthPoint {
  const GrowthPoint({required this.ageMonths, required this.value});
  final double ageMonths;
  final double value;
}

final growthChartDataProvider = Provider.family<List<GrowthPoint>, GrowthMetric>((ref, metric) {
  final baby = ref.watch(activeBabyProvider);
  final growths = ref.watch(allGrowthsProvider).value ?? const [];
  if (baby == null) return const [];

  final points = <GrowthPoint>[];
  for (final entry in growths) {
    final value = valueForMetric(entry, metric);
    if (value == null) continue;
    points.add(GrowthPoint(ageMonths: ageInMonthsAt(baby.dateOfBirth, entry.measuredAt), value: value));
  }
  points.sort((a, b) => a.ageMonths.compareTo(b.ageMonths));
  return points;
});

class GrowthRepository {
  GrowthRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  Future<void> addGrowth(GrowthEntry entry) async {
    await _firestoreService.addGrowth(entry);
    try {
      await FirebaseAnalytics.instance.logEvent(name: 'growth_logged');
    } catch (_) {
      // Analytics failures must never block saving the growth entry.
    }
  }

  Future<void> deleteGrowth(String userId, String babyId, String entryId) =>
      _firestoreService.deleteGrowth(userId, babyId, entryId);
}

final growthRepositoryProvider = Provider<GrowthRepository>((ref) {
  return GrowthRepository(ref.watch(firestoreServiceProvider));
});
