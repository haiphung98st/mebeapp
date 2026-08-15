import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../features/widget/widget_service.dart';
import '../models/diaper_entry.dart';
import '../services/firestore_service.dart';
import 'baby_provider.dart';
import 'home_provider.dart';

String diaperTypeLabel(DiaperType type) {
  switch (type) {
    case DiaperType.wet:
      return 'Ướt';
    case DiaperType.dirty:
      return 'Bẩn';
    case DiaperType.both:
      return 'Cả hai';
  }
}

String diaperTypeIcon(DiaperType type) {
  switch (type) {
    case DiaperType.wet:
      return '💧';
    case DiaperType.dirty:
      return '💩';
    case DiaperType.both:
      return '🔄';
  }
}

Color diaperTypeColor(DiaperType type) {
  switch (type) {
    case DiaperType.wet:
      return AppColors.info;
    case DiaperType.dirty:
      return AppColors.peach;
    case DiaperType.both:
      return AppColors.mint;
  }
}

class DiaperColorOption {
  const DiaperColorOption({required this.name, required this.color, required this.meaning, this.isWarning = false});

  final String name;
  final Color color;
  final String meaning;
  final bool isWarning;
}

const diaperColorGuide = [
  DiaperColorOption(name: 'Vàng', color: Color(0xFFF5C542), meaning: 'Bình thường ở trẻ bú mẹ'),
  DiaperColorOption(name: 'Nâu', color: Color(0xFF8B5E3C), meaning: 'Bình thường khi bé ăn dặm'),
  DiaperColorOption(name: 'Xanh', color: Color(0xFF4FAE7A), meaning: 'Có thể do sữa công thức, thường không đáng lo'),
  DiaperColorOption(
    name: 'Đỏ / Trắng',
    color: Color(0xFFE05D5D),
    meaning: 'Có thể có máu hoặc thiếu mật — nên gặp bác sĩ',
    isWarning: true,
  ),
];

class DailyDiaperCount {
  const DailyDiaperCount({required this.day, required this.wetCount, required this.dirtyCount});

  final DateTime day;
  final int wetCount;
  final int dirtyCount;

  int get total => wetCount + dirtyCount;
}

final diaperStatsProvider = FutureProvider<List<DailyDiaperCount>>((ref) async {
  final diapers = ref.watch(allDiapersProvider).value ?? const [];
  final today = startOfDay(DateTime.now());
  return List.generate(7, (index) {
    final day = today.subtract(Duration(days: 6 - index));
    final dayEntries = diapers.where((e) => isSameDay(e.time, day));
    final wetCount = dayEntries.where((e) => e.type != DiaperType.dirty).length;
    final dirtyCount = dayEntries.where((e) => e.type != DiaperType.wet).length;
    return DailyDiaperCount(day: day, wetCount: wetCount, dirtyCount: dirtyCount);
  });
});

final yesterdayDiaperCountProvider = Provider<int>((ref) {
  final diapers = ref.watch(allDiapersProvider).value ?? const [];
  final yesterday = DateTime.now().subtract(const Duration(days: 1));
  return diapers.where((e) => isSameDay(e.time, yesterday)).length;
});

final lowDiaperAlertProvider = Provider<bool>((ref) {
  final now = DateTime.now();
  if (now.hour < 12) return false;
  final todayCount = ref.watch(todayDiapersProvider).length;
  return todayCount < 3;
});

class DiaperRepository {
  DiaperRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  Future<void> addDiaper(DiaperEntry entry) async {
    await _firestoreService.addDiaper(entry);
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'diaper_logged',
        parameters: {'type': entry.type.name},
      );
    } catch (_) {
      // Analytics failures must never block saving the diaper entry.
    }
    WidgetService.triggerNativeRefresh().ignore();
  }

  Future<void> deleteDiaper(String userId, String babyId, String entryId) =>
      _firestoreService.deleteDiaper(userId, babyId, entryId);
}

final diaperRepositoryProvider = Provider<DiaperRepository>((ref) {
  return DiaperRepository(ref.watch(firestoreServiceProvider));
});
