import '../../../shared/models/feeding_entry.dart';
import '../../../shared/models/sleep_entry.dart';
import '../../../shared/models/diaper_entry.dart';
import '../../../shared/models/pump_entry.dart';

class WrappedStats {
  const WrappedStats({
    required this.year,
    required this.babyName,
    required this.totalFeedings,
    required this.totalBreastMinutes,
    required this.totalBottleMl,
    required this.totalSleepHours,
    required this.longestSleepMinutes,
    required this.totalDiapers,
    required this.wetDiapers,
    required this.dirtyDiapers,
    required this.totalPumpSessions,
    required this.totalPumpMl,
    required this.trackingDays,
    required this.busiestHour,
    required this.busiestDay,
  });

  final int year;
  final String babyName;
  final int totalFeedings;
  final int totalBreastMinutes;
  final double totalBottleMl;
  final double totalSleepHours;
  final int longestSleepMinutes;
  final int totalDiapers;
  final int wetDiapers;
  final int dirtyDiapers;
  final int totalPumpSessions;
  final double totalPumpMl;
  final int trackingDays;
  final int busiestHour; // 0-23
  final String busiestDay; // e.g. 'Thứ 2'

  static WrappedStats compute({
    required int year,
    required String babyName,
    required List<FeedingEntry> feedings,
    required List<SleepEntry> sleeps,
    required List<DiaperEntry> diapers,
    required List<PumpEntry> pumps,
  }) {
    bool inYear(DateTime t) => t.year == year;

    final yFeedings = feedings.where((e) => inYear(e.startTime)).toList();
    final ySleeps = sleeps.where((e) => inYear(e.startTime)).toList();
    final yDiapers = diapers.where((e) => inYear(e.time)).toList();
    final yPumps = pumps.where((e) => inYear(e.startTime)).toList();

    final breastMinutes = yFeedings
        .where((e) => e.type == FeedingType.breastLeft || e.type == FeedingType.breastRight)
        .fold<int>(0, (s, e) => s + (e.durationMinutes ?? 0));
    final bottleMl = yFeedings
        .where((e) => e.type == FeedingType.bottle)
        .fold<double>(0, (s, e) => s + (e.amountMl ?? 0));

    final sleepHours = ySleeps.fold<double>(
        0, (s, e) => s + (e.durationMinutes ?? 0) / 60.0);
    final longestSleep = ySleeps.isEmpty
        ? 0
        : ySleeps
            .map((e) => e.durationMinutes ?? 0)
            .reduce((a, b) => a > b ? a : b);

    // Busy hour from all events
    final hourCounts = List<int>.filled(24, 0);
    for (final e in yFeedings) hourCounts[e.startTime.hour]++;
    for (final e in ySleeps) hourCounts[e.startTime.hour]++;
    for (final e in yDiapers) hourCounts[e.time.hour]++;
    int busiestHour = 0;
    for (var i = 1; i < 24; i++) {
      if (hourCounts[i] > hourCounts[busiestHour]) busiestHour = i;
    }

    // Busiest day of week
    final dayCounts = List<int>.filled(7, 0);
    for (final e in yFeedings) dayCounts[e.startTime.weekday % 7]++;
    for (final e in ySleeps) dayCounts[e.startTime.weekday % 7]++;
    for (final e in yDiapers) dayCounts[e.time.weekday % 7]++;
    int busiestDayIdx = 0;
    for (var i = 1; i < 7; i++) {
      if (dayCounts[i] > dayCounts[busiestDayIdx]) busiestDayIdx = i;
    }
    const dayNames = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    final busiestDay = dayNames[busiestDayIdx];

    // Unique days with at least one log
    final uniqueDays = <String>{};
    for (final e in yFeedings) uniqueDays.add(_dayKey(e.startTime));
    for (final e in ySleeps) uniqueDays.add(_dayKey(e.startTime));
    for (final e in yDiapers) uniqueDays.add(_dayKey(e.time));

    return WrappedStats(
      year: year,
      babyName: babyName,
      totalFeedings: yFeedings.length,
      totalBreastMinutes: breastMinutes,
      totalBottleMl: bottleMl,
      totalSleepHours: sleepHours,
      longestSleepMinutes: longestSleep,
      totalDiapers: yDiapers.length,
      wetDiapers: yDiapers.where((e) => e.type == DiaperType.wet || e.type == DiaperType.both).length,
      dirtyDiapers: yDiapers.where((e) => e.type == DiaperType.dirty || e.type == DiaperType.both).length,
      totalPumpSessions: yPumps.length,
      totalPumpMl: yPumps.fold(0, (s, e) => s + (e.leftAmountMl ?? 0) + (e.rightAmountMl ?? 0)),
      trackingDays: uniqueDays.length,
      busiestHour: busiestHour,
      busiestDay: busiestDay,
    );
  }

  static String _dayKey(DateTime t) => '${t.year}-${t.month}-${t.day}';

  String get breastHours {
    final h = totalBreastMinutes ~/ 60;
    final m = totalBreastMinutes % 60;
    if (h == 0) return '${m}ph';
    return m == 0 ? '${h}h' : '${h}h ${m}ph';
  }

  String get sleepHoursStr {
    final h = totalSleepHours.toInt();
    return '${h}h';
  }

  String get longestSleepStr {
    final h = longestSleepMinutes ~/ 60;
    final m = longestSleepMinutes % 60;
    if (h == 0) return '${m} phút';
    return m == 0 ? '$h tiếng' : '$h tiếng $m phút';
  }

  String get busiestHourStr {
    final suffix = busiestHour < 12 ? 'SA' : 'CH';
    final h = busiestHour == 0 ? 12 : (busiestHour > 12 ? busiestHour - 12 : busiestHour);
    return '$h:00 $suffix';
  }
}
