import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/feeding_entry.dart';
import '../services/firestore_service.dart';
import 'baby_provider.dart';
import 'home_provider.dart';

class FeedingTimerState {
  const FeedingTimerState({
    this.isRunning = false,
    this.side = FeedingType.breastLeft,
    this.elapsedSeconds = 0,
    this.startTime,
  });

  final bool isRunning;
  final FeedingType side;
  final int elapsedSeconds;
  final DateTime? startTime;

  FeedingTimerState copyWith({
    bool? isRunning,
    FeedingType? side,
    int? elapsedSeconds,
    DateTime? startTime,
  }) {
    return FeedingTimerState(
      isRunning: isRunning ?? this.isRunning,
      side: side ?? this.side,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      startTime: startTime ?? this.startTime,
    );
  }
}

class FeedingTimerNotifier extends StateNotifier<FeedingTimerState> {
  FeedingTimerNotifier() : super(const FeedingTimerState());

  Timer? _ticker;

  void selectSide(FeedingType side) {
    if (state.isRunning) return;
    state = state.copyWith(side: side);
  }

  void start() {
    if (state.isRunning) return;
    final startTime = DateTime.now().subtract(Duration(seconds: state.elapsedSeconds));
    state = state.copyWith(isRunning: true, startTime: startTime);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    });
  }

  void pause() {
    _ticker?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void reset() {
    _ticker?.cancel();
    state = const FeedingTimerState();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

final feedingTimerProvider =
    StateNotifierProvider<FeedingTimerNotifier, FeedingTimerState>(
  (ref) => FeedingTimerNotifier(),
);

final lastFeedingProvider = Provider<FeedingEntry?>((ref) {
  final feedings = ref.watch(allFeedingsProvider).value;
  if (feedings == null || feedings.isEmpty) return null;
  return feedings.first;
});

final lastBreastFeedingProvider = Provider<FeedingEntry?>((ref) {
  final feedings = ref.watch(allFeedingsProvider).value ?? const [];
  for (final entry in feedings) {
    if (entry.type == FeedingType.breastLeft || entry.type == FeedingType.breastRight) {
      return entry;
    }
  }
  return null;
});

final lastBottleFeedingProvider = Provider<FeedingEntry?>((ref) {
  final feedings = ref.watch(allFeedingsProvider).value ?? const [];
  for (final entry in feedings) {
    if (entry.type == FeedingType.bottle) return entry;
  }
  return null;
});

class FeedingSummary {
  const FeedingSummary({
    required this.totalCount,
    required this.totalDurationMinutes,
    required this.leftCount,
    required this.rightCount,
  });

  final int totalCount;
  final int totalDurationMinutes;
  final int leftCount;
  final int rightCount;
}

final todayFeedingSummaryProvider = Provider<FeedingSummary>((ref) {
  final feedings = ref.watch(todayFeedingsProvider);
  var totalDuration = 0;
  var leftCount = 0;
  var rightCount = 0;
  for (final entry in feedings) {
    totalDuration += entry.durationMinutes ?? 0;
    if (entry.type == FeedingType.breastLeft) leftCount++;
    if (entry.type == FeedingType.breastRight) rightCount++;
  }
  return FeedingSummary(
    totalCount: feedings.length,
    totalDurationMinutes: totalDuration,
    leftCount: leftCount,
    rightCount: rightCount,
  );
});

class FeedingRepository {
  FeedingRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  Future<void> addFeeding(FeedingEntry entry) async {
    await _firestoreService.addFeeding(entry);
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'feeding_logged',
        parameters: {
          'type': entry.type.name,
          if (entry.durationMinutes != null) 'duration_minutes': entry.durationMinutes!,
          if (entry.amountMl != null) 'amount_ml': entry.amountMl!,
        },
      );
    } catch (_) {
      // Analytics failures must never block saving the feeding entry.
    }
  }

  Future<void> deleteFeeding(String userId, String babyId, String entryId) =>
      _firestoreService.deleteFeeding(userId, babyId, entryId);
}

final feedingRepositoryProvider = Provider<FeedingRepository>((ref) {
  return FeedingRepository(ref.watch(firestoreServiceProvider));
});
