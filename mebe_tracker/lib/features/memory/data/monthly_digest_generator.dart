import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../features/achievement/data/achievement_data.dart';
import '../../../shared/models/baby_profile.dart';

class MonthlyDigest {
  const MonthlyDigest({
    required this.year,
    required this.month,
    required this.babyName,
    required this.ageMonths,
    required this.totalFeedings,
    required this.avgSleepHours,
    required this.totalDiapers,
    this.weightKg,
    this.heightCm,
    this.newAchievementNames = const [],
    this.highlights = const [],
  });

  final int year;
  final int month;
  final String babyName;
  final int ageMonths;
  final int totalFeedings;
  final double avgSleepHours;
  final int totalDiapers;
  final double? weightKg;
  final double? heightCm;
  final List<String> newAchievementNames;
  final List<String> highlights;

  String get monthLabel {
    const months = [
      '', 'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
      'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'
    ];
    return months[month];
  }
}

class MonthlyDigestGenerator {
  Future<MonthlyDigest> generate({
    required String userId,
    required BabyProfile baby,
    required int year,
    required int month,
  }) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59);
    final fs = FirebaseFirestore.instance;
    final babyPath = 'users/$userId/babies/${baby.id}';

    final results = await Future.wait([
      fs
          .collection('$babyPath/feedings')
          .where('startTime',
              isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('startTime',
              isLessThanOrEqualTo: Timestamp.fromDate(end))
          .count()
          .get(),
      fs
          .collection('$babyPath/sleeps')
          .where('startTime',
              isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get(),
      fs
          .collection('$babyPath/diapers')
          .where('time',
              isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('time', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .count()
          .get(),
      fs
          .collection('$babyPath/growths')
          .orderBy('measuredAt', descending: true)
          .limit(1)
          .get(),
      fs
          .collection('$babyPath/achievements')
          .where('unlockedAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('unlockedAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get(),
    ]);

    final feedingCount = (results[0] as AggregateQuerySnapshot).count ?? 0;
    final sleepsSnap = results[1] as QuerySnapshot;
    final diaperCount = (results[2] as AggregateQuerySnapshot).count ?? 0;
    final growthSnap = results[3] as QuerySnapshot;
    final achSnap = results[4] as QuerySnapshot;

    // Avg sleep hours per day
    double totalSleepMin = 0;
    int sleepCount = 0;
    for (final d in sleepsSnap.docs) {
      final data = d.data() as Map<String, dynamic>;
      final start_ = (data['startTime'] as Timestamp).toDate();
      final end_ = (data['endTime'] as Timestamp?)?.toDate();
      if (end_ != null) {
        totalSleepMin += end_.difference(start_).inMinutes;
        sleepCount++;
      }
    }
    final daysInMonth = end.day;
    final avgSleepH =
        daysInMonth > 0 ? (totalSleepMin / 60 / daysInMonth) : 0.0;

    // Latest growth
    double? weightKg, heightCm;
    if (growthSnap.docs.isNotEmpty) {
      final gData = growthSnap.docs.first.data() as Map<String, dynamic>;
      weightKg = (gData['weightKg'] as num?)?.toDouble();
      heightCm = (gData['heightCm'] as num?)?.toDouble();
    }

    // Achievement names
    final achNames = <String>[];
    for (final d in achSnap.docs) {
      final achId = (d.data() as Map<String, dynamic>)['achievementId'] as String?;
      final ach = allAchievements.where((a) => a.id == achId).firstOrNull;
      if (ach != null) achNames.add('${ach.icon} ${ach.name}');
    }

    // Highlights
    final highlights = <String>[];
    if (feedingCount > 200) highlights.add('Tháng bú chăm chỉ — $feedingCount cữ!');
    if (avgSleepH >= 14) highlights.add('Giấc ngủ tốt — TB ${avgSleepH.toStringAsFixed(1)}h/ngày');
    for (final a in achNames) highlights.add('Đạt huy chương: $a');

    final ageMonths = baby.dateOfBirth.year == year && baby.dateOfBirth.month == month
        ? 0
        : ((DateTime(year, month).difference(baby.dateOfBirth).inDays) / 30).floor();

    return MonthlyDigest(
      year: year,
      month: month,
      babyName: baby.name,
      ageMonths: ageMonths.clamp(0, 999),
      totalFeedings: feedingCount,
      avgSleepHours: avgSleepH,
      totalDiapers: diaperCount,
      weightKg: weightKg,
      heightCm: heightCm,
      newAchievementNames: achNames,
      highlights: highlights,
    );
  }
}
