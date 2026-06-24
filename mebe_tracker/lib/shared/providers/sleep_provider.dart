import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/date_utils.dart';
import '../models/sleep_entry.dart';
import '../services/firestore_service.dart';
import 'baby_provider.dart';
import 'home_provider.dart';

class ActiveSleepState {
  const ActiveSleepState({this.startTime, this.elapsedSeconds = 0, this.type = SleepType.nap});

  final DateTime? startTime;
  final int elapsedSeconds;
  final SleepType type;

  bool get isActive => startTime != null;

  ActiveSleepState copyWith({DateTime? startTime, int? elapsedSeconds, SleepType? type}) {
    return ActiveSleepState(
      startTime: startTime ?? this.startTime,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      type: type ?? this.type,
    );
  }
}

SleepType sleepTypeForHour(int hour) => (hour >= 19 || hour < 6) ? SleepType.night : SleepType.nap;

class ActiveSleepNotifier extends StateNotifier<ActiveSleepState> {
  ActiveSleepNotifier() : super(const ActiveSleepState());

  Timer? _ticker;

  void start() {
    if (state.isActive) return;
    final now = DateTime.now();
    state = ActiveSleepState(startTime: now, type: sleepTypeForHour(now.hour));
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    });
  }

  void reset() {
    _ticker?.cancel();
    state = const ActiveSleepState();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

final activeSleepProvider = StateNotifierProvider<ActiveSleepNotifier, ActiveSleepState>(
  (ref) => ActiveSleepNotifier(),
);

String sleepLabel(SleepEntry entry) {
  final hour = entry.startTime.hour;
  if (entry.type == SleepType.night) return 'Giấc đêm';
  if (hour < 12) return 'Giấc sáng';
  return 'Giấc chiều';
}

String sleepIcon(SleepEntry entry) {
  if (entry.type == SleepType.night) return '🌙';
  final hour = entry.startTime.hour;
  return hour < 12 ? '☀️' : '🌤️';
}

class SleepPrediction {
  const SleepPrediction({
    required this.windowStart,
    required this.windowEnd,
    required this.sampleDays,
    required this.confidencePercent,
  });

  final DateTime windowStart;
  final DateTime windowEnd;
  final int sampleDays;
  final int confidencePercent;
}

final sleepPredictionProvider = FutureProvider<SleepPrediction?>((ref) async {
  final sleeps = ref.watch(allSleepsProvider).value ?? const [];
  if (sleeps.length < 3) return null;

  final cutoff = DateTime.now().subtract(const Duration(days: 7));
  final recent = sleeps.where((e) => e.startTime.isAfter(cutoff)).toList();
  if (recent.length < 3) return null;

  final now = DateTime.now();
  final nextType = sleepTypeForHour(now.hour) == SleepType.night ? SleepType.nap : SleepType.night;
  final sameTypeStarts = recent
      .where((e) => e.type == nextType)
      .map((e) => e.startTime.hour * 60 + e.startTime.minute)
      .toList();
  if (sameTypeStarts.isEmpty) return null;

  final avgMinutes = sameTypeStarts.reduce((a, b) => a + b) / sameTypeStarts.length;
  var windowStart = DateTime(now.year, now.month, now.day, 0, avgMinutes.round());
  if (windowStart.isBefore(now)) windowStart = windowStart.add(const Duration(days: 1));
  final windowEnd = windowStart.add(const Duration(minutes: 30));

  final sampleDays = recent.map((e) => startOfDay(e.startTime)).toSet().length;
  final confidence = (50 + sameTypeStarts.length * 7).clamp(50, 95);

  return SleepPrediction(
    windowStart: windowStart,
    windowEnd: windowEnd,
    sampleDays: sampleDays,
    confidencePercent: confidence,
  );
});

class DailySleepTotal {
  const DailySleepTotal({required this.day, required this.napMinutes, required this.nightMinutes});
  final DateTime day;
  final int napMinutes;
  final int nightMinutes;
}

final weeklySleepProvider = FutureProvider<List<DailySleepTotal>>((ref) async {
  final sleeps = ref.watch(allSleepsProvider).value ?? const [];
  final today = startOfDay(DateTime.now());
  return List.generate(7, (index) {
    final day = today.subtract(Duration(days: 6 - index));
    final dayEntries = sleeps.where((e) => isSameDay(e.startTime, day));
    final napMinutes = dayEntries
        .where((e) => e.type == SleepType.nap)
        .fold<int>(0, (sum, e) => sum + (e.durationMinutes ?? 0));
    final nightMinutes = dayEntries
        .where((e) => e.type == SleepType.night)
        .fold<int>(0, (sum, e) => sum + (e.durationMinutes ?? 0));
    return DailySleepTotal(day: day, napMinutes: napMinutes, nightMinutes: nightMinutes);
  });
});

class DailySleepSummary {
  const DailySleepSummary({
    required this.totalMinutes,
    required this.sessionCount,
    required this.nightMinutes,
  });

  final int totalMinutes;
  final int sessionCount;
  final int nightMinutes;
}

final dailySleepSummaryProvider = Provider<DailySleepSummary>((ref) {
  final sleeps = ref.watch(todaySleepsProvider);
  final totalMinutes = sleeps.fold<int>(0, (sum, e) => sum + (e.durationMinutes ?? 0));
  final nightMinutes = sleeps
      .where((e) => e.type == SleepType.night)
      .fold<int>(0, (sum, e) => sum + (e.durationMinutes ?? 0));
  return DailySleepSummary(
    totalMinutes: totalMinutes,
    sessionCount: sleeps.length,
    nightMinutes: nightMinutes,
  );
});

class SleepRepository {
  SleepRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  Future<void> addSleep(SleepEntry entry) async {
    await _firestoreService.addSleep(entry);
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'sleep_logged',
        parameters: {
          'type': entry.type.name,
          if (entry.durationMinutes != null) 'duration_minutes': entry.durationMinutes!,
        },
      );
    } catch (_) {
      // Analytics failures must never block saving the sleep entry.
    }
  }

  Future<void> deleteSleep(String userId, String babyId, String entryId) =>
      _firestoreService.deleteSleep(userId, babyId, entryId);
}

final sleepRepositoryProvider = Provider<SleepRepository>((ref) {
  return SleepRepository(ref.watch(firestoreServiceProvider));
});
