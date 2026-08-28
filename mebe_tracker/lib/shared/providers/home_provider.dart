import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../models/diaper_entry.dart';
import '../models/feeding_entry.dart';
import '../models/pump_entry.dart';
import '../models/sleep_entry.dart';
import 'auth_provider.dart';
import 'baby_provider.dart';

final allFeedingsProvider = StreamProvider<List<FeedingEntry>>((ref) {
  final user = ref.watch(currentUserProvider);
  final baby = ref.watch(activeBabyProvider);
  if (user == null || baby == null) return Stream.value(const []);
  return ref.watch(firestoreServiceProvider).watchFeedings(user.uid, baby.id);
});

final allSleepsProvider = StreamProvider<List<SleepEntry>>((ref) {
  final user = ref.watch(currentUserProvider);
  final baby = ref.watch(activeBabyProvider);
  if (user == null || baby == null) return Stream.value(const []);
  return ref.watch(firestoreServiceProvider).watchSleeps(user.uid, baby.id);
});

final allDiapersProvider = StreamProvider<List<DiaperEntry>>((ref) {
  final user = ref.watch(currentUserProvider);
  final baby = ref.watch(activeBabyProvider);
  if (user == null || baby == null) return Stream.value(const []);
  return ref.watch(firestoreServiceProvider).watchDiapers(user.uid, baby.id);
});

final allPumpsProvider = StreamProvider<List<PumpEntry>>((ref) {
  final user = ref.watch(currentUserProvider);
  final baby = ref.watch(activeBabyProvider);
  if (user == null || baby == null) return Stream.value(const []);
  return ref.watch(firestoreServiceProvider).watchPumps(user.uid, baby.id);
});

final todayFeedingsProvider = Provider<List<FeedingEntry>>((ref) {
  final feedings = ref.watch(allFeedingsProvider).value ?? const [];
  final today = DateTime.now();
  return feedings.where((e) => isSameDay(e.startTime, today)).toList();
});

final todaySleepsProvider = Provider<List<SleepEntry>>((ref) {
  final sleeps = ref.watch(allSleepsProvider).value ?? const [];
  final today = DateTime.now();
  return sleeps.where((e) => isSameDay(e.startTime, today)).toList();
});

final todayDiapersProvider = Provider<List<DiaperEntry>>((ref) {
  final diapers = ref.watch(allDiapersProvider).value ?? const [];
  final today = DateTime.now();
  return diapers.where((e) => isSameDay(e.time, today)).toList();
});

final todayPumpsProvider = Provider<List<PumpEntry>>((ref) {
  final pumps = ref.watch(allPumpsProvider).value ?? const [];
  final today = DateTime.now();
  return pumps.where((e) => isSameDay(e.startTime, today)).toList();
});

enum RecentEventType { feeding, sleep, pump }

class RecentEvent {
  const RecentEvent({
    required this.type,
    required this.icon,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  final RecentEventType type;
  final String icon;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final DateTime time;
}

String _feedingTitle(FeedingEntry entry) {
  switch (entry.type) {
    case FeedingType.breastLeft:
    case FeedingType.breastRight:
      return 'Bú mẹ';
    case FeedingType.bottle:
      return 'Bú bình';
    case FeedingType.solid:
      return 'Ăn dặm';
  }
}

String _feedingSubtitle(FeedingEntry entry) {
  switch (entry.type) {
    case FeedingType.breastLeft:
      return 'Bên trái · ${entry.durationMinutes ?? 0} phút';
    case FeedingType.breastRight:
      return 'Bên phải · ${entry.durationMinutes ?? 0} phút';
    case FeedingType.bottle:
      return '${entry.amountMl?.toStringAsFixed(0) ?? 0} ml';
    case FeedingType.solid:
      return entry.notes ?? '';
  }
}

final recentEventsProvider = Provider<List<RecentEvent>>((ref) {
  final feedings = ref.watch(allFeedingsProvider).value ?? const [];
  final sleeps = ref.watch(allSleepsProvider).value ?? const [];
  final pumps = ref.watch(allPumpsProvider).value ?? const [];

  final events = <RecentEvent>[
    ...feedings.map(
      (e) => RecentEvent(
        type: RecentEventType.feeding,
        icon: '🍼',
        iconBackground: AppColors.blush,
        title: _feedingTitle(e),
        subtitle: _feedingSubtitle(e),
        time: e.startTime,
      ),
    ),
    ...sleeps.map(
      (e) => RecentEvent(
        type: RecentEventType.sleep,
        icon: '🌙',
        iconBackground: AppColors.lilac,
        title: 'Giấc ngủ',
        subtitle: e.type == SleepType.nap
            ? 'Giấc ngắn · ${formatMinutes(e.durationMinutes)}'
            : 'Giấc đêm · ${formatMinutes(e.durationMinutes)}',
        time: e.startTime,
      ),
    ),
    ...pumps.map(
      (e) => RecentEvent(
        type: RecentEventType.pump,
        icon: '🥛',
        iconBackground: AppColors.lilac,
        title: 'Hút sữa',
        subtitle: 'Tổng ${((e.leftAmountMl ?? 0) + (e.rightAmountMl ?? 0)).toStringAsFixed(0)} ml',
        time: e.startTime,
      ),
    ),
  ];

  events.sort((a, b) => b.time.compareTo(a.time));
  return events.take(5).toList();
});

String formatMinutes(int? minutes) => minutes == null ? '—' : '$minutes phút';

/// Fallback interval used when there isn't enough same-session data to
/// average from (e.g. right after an overnight gap drops out of the window).
const _defaultFeedingIntervalMinutes = 150;

final nextFeedingTimeProvider = Provider<DateTime?>((ref) {
  final feedings = ref.watch(allFeedingsProvider).value ?? const [];
  if (feedings.isEmpty) return null;
  final recent = feedings.take(5).toList();

  // Only count gaps that look like a normal daytime feeding cadence (30min
  // to 6h) — a night-sleep gap between two feeds would otherwise skew the
  // average far past the baby's actual next feeding time.
  final gaps = <int>[];
  for (var i = 0; i < recent.length - 1; i++) {
    final minutes = recent[i].startTime.difference(recent[i + 1].startTime).inMinutes;
    if (minutes >= 30 && minutes <= 360) gaps.add(minutes);
  }

  final avgMinutes = gaps.isEmpty
      ? _defaultFeedingIntervalMinutes
      : (gaps.reduce((a, b) => a + b) / gaps.length).round();
  return recent.first.startTime.add(Duration(minutes: avgMinutes));
});
