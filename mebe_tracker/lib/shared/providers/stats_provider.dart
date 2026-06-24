import 'dart:math' show sqrt;

import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/who_growth_data.dart';
import '../../core/services/notification_service.dart';
import '../../core/utils/date_utils.dart';
import '../models/diaper_entry.dart';
import '../models/feeding_entry.dart';
import '../models/pump_entry.dart';
import '../models/sleep_entry.dart';
import 'baby_provider.dart';
import 'growth_provider.dart';
import 'home_provider.dart';

enum StatsRangeType { today, week, month, custom }

final statsRangeTypeProvider = StateProvider<StatsRangeType>((ref) => StatsRangeType.week);
final statsCustomRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

final statsDateRangeProvider = Provider<DateTimeRange>((ref) {
  final type = ref.watch(statsRangeTypeProvider);
  final now = DateTime.now();
  final today = startOfDay(now);
  switch (type) {
    case StatsRangeType.today:
      return DateTimeRange(start: today, end: today.add(const Duration(days: 1)));
    case StatsRangeType.week:
      return DateTimeRange(start: today.subtract(const Duration(days: 6)), end: today.add(const Duration(days: 1)));
    case StatsRangeType.month:
      return DateTimeRange(start: DateTime(now.year, now.month, 1), end: today.add(const Duration(days: 1)));
    case StatsRangeType.custom:
      return ref.watch(statsCustomRangeProvider) ??
          DateTimeRange(start: today.subtract(const Duration(days: 6)), end: today.add(const Duration(days: 1)));
  }
});

bool _inRange(DateTime time, DateTimeRange range) =>
    !time.isBefore(range.start) && time.isBefore(range.end);

final statsFeedingsProvider = Provider<List<FeedingEntry>>((ref) {
  final range = ref.watch(statsDateRangeProvider);
  final feedings = ref.watch(allFeedingsProvider).value ?? const [];
  return feedings.where((e) => _inRange(e.startTime, range)).toList();
});

final statsSleepsProvider = Provider<List<SleepEntry>>((ref) {
  final range = ref.watch(statsDateRangeProvider);
  final sleeps = ref.watch(allSleepsProvider).value ?? const [];
  return sleeps.where((e) => _inRange(e.startTime, range)).toList();
});

final statsPumpsProvider = Provider<List<PumpEntry>>((ref) {
  final range = ref.watch(statsDateRangeProvider);
  final pumps = ref.watch(allPumpsProvider).value ?? const [];
  return pumps.where((e) => _inRange(e.startTime, range)).toList();
});

final statsDiapersProvider = Provider<List<DiaperEntry>>((ref) {
  final range = ref.watch(statsDateRangeProvider);
  final diapers = ref.watch(allDiapersProvider).value ?? const [];
  return diapers.where((e) => _inRange(e.time, range)).toList();
});

int _rangeDays(DateTimeRange range) => range.end.difference(range.start).inDays.clamp(1, 365);

class DailyValue {
  const DailyValue(this.day, this.value);
  final DateTime day;
  final double value;
}

List<DailyValue> _bucketByDay(
  DateTimeRange range,
  Iterable<DateTime> times,
  double Function(DateTime) weightOf,
) {
  final days = _rangeDays(range);
  final totals = List<double>.filled(days, 0);
  for (final time in times) {
    final index = startOfDay(time).difference(range.start).inDays;
    if (index >= 0 && index < days) totals[index] += weightOf(time);
  }
  return List.generate(days, (i) => DailyValue(range.start.add(Duration(days: i)), totals[i]));
}

class FeedingSummary {
  const FeedingSummary({
    required this.totalCount,
    required this.totalDurationMinutes,
    required this.totalAmountMl,
    required this.avgPerDay,
    required this.avgDurationPerSession,
    required this.leftRatio,
    required this.rightRatio,
    required this.dailyCounts,
  });

  final int totalCount;
  final int totalDurationMinutes;
  final double totalAmountMl;
  final double avgPerDay;
  final double avgDurationPerSession;
  final double leftRatio;
  final double rightRatio;
  final List<DailyValue> dailyCounts;
}

final feedingSummaryProvider = Provider<FeedingSummary>((ref) {
  final range = ref.watch(statsDateRangeProvider);
  final feedings = ref.watch(statsFeedingsProvider);
  final days = _rangeDays(range);

  final totalDuration = feedings.fold<int>(0, (sum, e) => sum + (e.durationMinutes ?? 0));
  final totalAmount = feedings.fold<double>(0, (sum, e) => sum + (e.amountMl ?? 0));
  final breastFeeds = feedings.where(
    (e) => e.type == FeedingType.breastLeft || e.type == FeedingType.breastRight,
  );
  final leftCount = breastFeeds.where((e) => e.type == FeedingType.breastLeft).length;
  final rightCount = breastFeeds.where((e) => e.type == FeedingType.breastRight).length;
  final breastTotal = leftCount + rightCount;

  return FeedingSummary(
    totalCount: feedings.length,
    totalDurationMinutes: totalDuration,
    totalAmountMl: totalAmount,
    avgPerDay: feedings.length / days,
    avgDurationPerSession: breastFeeds.isEmpty ? 0 : totalDuration / breastFeeds.length,
    leftRatio: breastTotal == 0 ? 0.5 : leftCount / breastTotal,
    rightRatio: breastTotal == 0 ? 0.5 : rightCount / breastTotal,
    dailyCounts: _bucketByDay(range, feedings.map((e) => e.startTime), (_) => 1),
  );
});

class SleepSummary {
  const SleepSummary({
    required this.totalHours,
    required this.avgHoursPerDay,
    required this.nightRatio,
    required this.dayRatio,
    required this.dailyNightHours,
    required this.dailyNapHours,
    required this.trendMinutesVsPrevious,
  });

  final double totalHours;
  final double avgHoursPerDay;
  final double nightRatio;
  final double dayRatio;
  final List<DailyValue> dailyNightHours;
  final List<DailyValue> dailyNapHours;
  final int trendMinutesVsPrevious;
}

final sleepSummaryProvider = Provider<SleepSummary>((ref) {
  final range = ref.watch(statsDateRangeProvider);
  final sleeps = ref.watch(statsSleepsProvider);
  final days = _rangeDays(range);

  final totalMinutes = sleeps.fold<int>(0, (sum, e) => sum + (e.durationMinutes ?? 0));
  final nightMinutes = sleeps
      .where((e) => e.type == SleepType.night)
      .fold<int>(0, (sum, e) => sum + (e.durationMinutes ?? 0));
  final napMinutes = totalMinutes - nightMinutes;

  final previousRange = DateTimeRange(
    start: range.start.subtract(range.end.difference(range.start)),
    end: range.start,
  );
  final allSleeps = ref.watch(allSleepsProvider).value ?? const [];
  final previousMinutes = allSleeps
      .where((e) => _inRange(e.startTime, previousRange))
      .fold<int>(0, (sum, e) => sum + (e.durationMinutes ?? 0));

  return SleepSummary(
    totalHours: totalMinutes / 60,
    avgHoursPerDay: totalMinutes / 60 / days,
    nightRatio: totalMinutes == 0 ? 0.5 : nightMinutes / totalMinutes,
    dayRatio: totalMinutes == 0 ? 0.5 : napMinutes / totalMinutes,
    dailyNightHours: _bucketByDay(
      range,
      sleeps.where((e) => e.type == SleepType.night).map((e) => e.startTime),
      (_) => 1,
    ).asMap().entries.map((entry) {
      final minutes = sleeps
          .where((e) => e.type == SleepType.night && isSameDay(e.startTime, entry.value.day))
          .fold<int>(0, (sum, e) => sum + (e.durationMinutes ?? 0));
      return DailyValue(entry.value.day, minutes / 60);
    }).toList(),
    dailyNapHours: _bucketByDay(range, sleeps.where((e) => e.type == SleepType.nap).map((e) => e.startTime), (_) => 1)
        .asMap()
        .entries
        .map((entry) {
      final minutes = sleeps
          .where((e) => e.type == SleepType.nap && isSameDay(e.startTime, entry.value.day))
          .fold<int>(0, (sum, e) => sum + (e.durationMinutes ?? 0));
      return DailyValue(entry.value.day, minutes / 60);
    }).toList(),
    trendMinutesVsPrevious: totalMinutes - previousMinutes,
  );
});

class PumpSummary {
  const PumpSummary({
    required this.totalMl,
    required this.avgMlPerDay,
    required this.sessionCount,
    required this.dailyMl,
    required this.peakDay,
    required this.lowestDay,
  });

  final double totalMl;
  final double avgMlPerDay;
  final int sessionCount;
  final List<DailyValue> dailyMl;
  final DailyValue? peakDay;
  final DailyValue? lowestDay;
}

final pumpSummaryProvider = Provider<PumpSummary>((ref) {
  final range = ref.watch(statsDateRangeProvider);
  final pumps = ref.watch(statsPumpsProvider);
  final days = _rangeDays(range);

  final dailyMl = _bucketByDay(
    range,
    pumps.map((e) => e.startTime),
    (_) => 0,
  ).asMap().entries.map((entry) {
    final ml = pumps
        .where((e) => isSameDay(e.startTime, entry.value.day))
        .fold<double>(0, (sum, e) => sum + (e.leftAmountMl ?? 0) + (e.rightAmountMl ?? 0));
    return DailyValue(entry.value.day, ml);
  }).toList();

  final totalMl = dailyMl.fold<double>(0, (sum, d) => sum + d.value);
  final nonZeroDays = dailyMl.where((d) => d.value > 0).toList();
  DailyValue? peak;
  DailyValue? lowest;
  for (final d in nonZeroDays) {
    if (peak == null || d.value > peak.value) peak = d;
    if (lowest == null || d.value < lowest.value) lowest = d;
  }

  return PumpSummary(
    totalMl: totalMl,
    avgMlPerDay: totalMl / days,
    sessionCount: pumps.length,
    dailyMl: dailyMl,
    peakDay: peak,
    lowestDay: lowest,
  );
});

class DiaperSummary {
  const DiaperSummary({
    required this.totalCount,
    required this.wetCount,
    required this.dirtyCount,
    required this.bothCount,
    required this.dailyCounts,
  });

  final int totalCount;
  final int wetCount;
  final int dirtyCount;
  final int bothCount;
  final List<DailyValue> dailyCounts;
}

final diaperSummaryProvider = Provider<DiaperSummary>((ref) {
  final range = ref.watch(statsDateRangeProvider);
  final diapers = ref.watch(statsDiapersProvider);

  return DiaperSummary(
    totalCount: diapers.length,
    wetCount: diapers.where((e) => e.type == DiaperType.wet).length,
    dirtyCount: diapers.where((e) => e.type == DiaperType.dirty).length,
    bothCount: diapers.where((e) => e.type == DiaperType.both).length,
    dailyCounts: _bucketByDay(range, diapers.map((e) => e.time), (_) => 1),
  );
});

enum InsightType { pattern, feedingPattern, growth, anomaly }

class Insight {
  const Insight({required this.type, required this.message});
  final InsightType type;
  final String message;
}

double _average(List<double> values) => values.isEmpty ? 0 : values.reduce((a, b) => a + b) / values.length;

double _stdDev(List<double> values) {
  if (values.length < 2) return 0;
  final avg = _average(values);
  final variance = values.fold<double>(0, (sum, v) => sum + (v - avg) * (v - avg)) / values.length;
  return sqrt(variance);
}

/// Local on-device heuristics: 7-day moving averages, stddev-based anomaly
/// detection, and simple time-clustering for nap patterns. No network calls.
final aiInsightsProvider = Provider<List<Insight>>((ref) {
  final baby = ref.watch(activeBabyProvider);
  final feedings = ref.watch(allFeedingsProvider).value ?? const [];
  final sleeps = ref.watch(allSleepsProvider).value ?? const [];
  final growths = ref.watch(allGrowthsProvider).value ?? const [];
  final insights = <Insight>[];
  if (baby == null) return insights;

  final now = DateTime.now();
  final today = startOfDay(now);

  // Nap time-clustering pattern.
  final naps = sleeps.where((e) => e.type == SleepType.nap && now.difference(e.startTime).inDays <= 14).toList();
  if (naps.length >= 3) {
    final startMinutes = naps.map((e) => e.startTime.hour * 60.0 + e.startTime.minute).toList();
    final avgStart = _average(startMinutes);
    final spread = startMinutes.map((m) => (m - avgStart).abs()).reduce((a, b) => a > b ? a : b);
    if (spread <= 45) {
      final avgDuration = _average(naps.map((e) => (e.durationMinutes ?? 0).toDouble()).toList());
      final hour = avgStart ~/ 60;
      final minute = (avgStart % 60).round();
      insights.add(Insight(
        type: InsightType.pattern,
        message: '🐰 Bé ${baby.name} có xu hướng ngủ giấc chiều lúc '
            '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}, '
            'kéo dài ~${(avgDuration / 60).toStringAsFixed(1)} giờ',
      ));
    }
  }

  // Feeding interval consistency: this week vs last week.
  double avgIntervalHoursIn(DateTimeRange range) {
    final inRange = feedings.where((e) => _inRange(e.startTime, range)).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    if (inRange.length < 2) return 0;
    final gaps = <double>[];
    for (var i = 0; i < inRange.length - 1; i++) {
      gaps.add(inRange[i + 1].startTime.difference(inRange[i].startTime).inMinutes / 60);
    }
    return _average(gaps);
  }

  final thisWeek = DateTimeRange(start: today.subtract(const Duration(days: 6)), end: today.add(const Duration(days: 1)));
  final lastWeek = DateTimeRange(start: thisWeek.start.subtract(const Duration(days: 7)), end: thisWeek.start);
  final avgThisWeek = avgIntervalHoursIn(thisWeek);
  final avgLastWeek = avgIntervalHoursIn(lastWeek);
  if (avgThisWeek > 0 && avgLastWeek > 0) {
    insights.add(Insight(
      type: InsightType.feedingPattern,
      message: '🐰 Khoảng cách cữ bú của bé trung bình '
          '${avgThisWeek.toStringAsFixed(1)} giờ/cữ (tuần trước: ${avgLastWeek.toStringAsFixed(1)} giờ)',
    ));
  }

  // Growth vs WHO P50 curve.
  if (growths.isNotEmpty) {
    final sorted = [...growths]..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));
    final latest = sorted.last;
    if (latest.weightKg != null) {
      final ageMonths = ageInMonthsAt(baby.dateOfBirth, latest.measuredAt);
      final percentile = WhoGrowthStandard.percentileFor(GrowthMetric.weight, ageMonths, latest.weightKg!);
      String rateText = '';
      if (sorted.length >= 2) {
        final previous = sorted[sorted.length - 2];
        if (previous.weightKg != null) {
          final weeks = latest.measuredAt.difference(previous.measuredAt).inDays / 7;
          if (weeks > 0) {
            final ratePerWeek = (latest.weightKg! - previous.weightKg!) / weeks;
            rateText = '. Tốc độ tăng: ${ratePerWeek >= 0 ? '+' : ''}${ratePerWeek.toStringAsFixed(2)}kg/tuần';
          }
        }
      }
      final curveLabel = percentile >= 45 && percentile <= 55 ? 'P50' : 'P$percentile';
      insights.add(Insight(
        type: InsightType.growth,
        message: '🐰 Cân nặng của bé đang phát triển theo đường cong WHO $curveLabel$rateText',
      ));
    }
  }

  // Anomaly: today's feeding count vs 7-day baseline (excluding today).
  final last7 = List.generate(7, (i) => today.subtract(Duration(days: i + 1)));
  final dailyCounts = last7
      .map((day) => feedings.where((e) => isSameDay(e.startTime, day)).length.toDouble())
      .toList();
  if (dailyCounts.length >= 5) {
    final avg = _average(dailyCounts);
    final stddev = _stdDev(dailyCounts);
    final todayCount = feedings.where((e) => isSameDay(e.startTime, today)).length;
    final threshold = avg - 1.5 * stddev;
    if (now.hour >= 18 && stddev > 0 && todayCount < threshold) {
      insights.add(Insight(
        type: InsightType.anomaly,
        message: '⚠️ Hôm nay bé bú ít hơn bình thường ($todayCount cữ thay vì ${avg.round()}). '
            'Nếu kèm biểu hiện khác, hãy theo dõi thêm.',
      ));
    }
  }

  return insights;
});

final weeklyReportSchedulerProvider = Provider<void>((ref) {
  final baby = ref.watch(activeBabyProvider);
  if (baby != null) {
    NotificationService.instance.scheduleWeeklyReport(baby.name);
  }
});
