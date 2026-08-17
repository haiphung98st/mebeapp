import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/baby_profile.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/baby_provider.dart';
import '../../wonder_weeks/data/wonder_weeks_data.dart';

class DayMood {
  const DayMood({
    required this.date,
    required this.color,
    this.momMood,
    this.isLeapStorm = false,
    this.leapName,
  });

  final DateTime date;
  final Color color;
  final int? momMood; // 1-5
  final bool isLeapStorm;
  final String? leapName;
}

bool _isInLeapStorm(BabyProfile baby, DateTime date) {
  final ref = baby.edd ?? baby.dateOfBirth;
  final ageWeeks = date.difference(ref).inDays / 7;
  for (final leap in wonderWeeksLeaps) {
    if (ageWeeks >= leap.stormStartWeek && ageWeeks <= leap.stormEndWeek) {
      return true;
    }
  }
  return false;
}

String? _leapName(BabyProfile baby, DateTime date) {
  final ref = baby.edd ?? baby.dateOfBirth;
  final ageWeeks = date.difference(ref).inDays / 7;
  for (final leap in wonderWeeksLeaps) {
    if (ageWeeks >= leap.stormStartWeek && ageWeeks <= leap.stormEndWeek) {
      return leap.name;
    }
  }
  return null;
}

Color _moodColor(int? momMood, bool isStorm) {
  if (isStorm) return const Color(0xFFFC8181);
  if (momMood == null) return const Color(0xFFE2E8F0);
  if (momMood >= 4) return const Color(0xFF68D391);
  if (momMood >= 3) return const Color(0xFFF6E05E);
  return const Color(0xFFFBD38D);
}

String _dateKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

final moodTimelineProvider =
    FutureProvider.family<List<DayMood>, ({DateTime from, DateTime to})>(
        (ref, args) async {
  final user = ref.read(currentUserProvider);
  final baby = ref.read(activeBabyProvider);
  if (user == null || baby == null) return [];

  final results = <DayMood>[];
  var cursor = args.from;

  while (!cursor.isAfter(args.to)) {
    final dateStr = _dateKey(cursor);
    final momDoc = await FirebaseFirestore.instance
        .doc('users/${user.uid}/mom_health/$dateStr')
        .get();
    final momMood = (momDoc.data()?['moodScore'] as num?)?.toInt();
    final isStorm = _isInLeapStorm(baby, cursor);

    results.add(DayMood(
      date: cursor,
      color: _moodColor(momMood, isStorm),
      momMood: momMood,
      isLeapStorm: isStorm,
      leapName: _leapName(baby, cursor),
    ));

    cursor = cursor.add(const Duration(days: 1));
  }
  return results;
});

class MoodInsights {
  const MoodInsights({
    required this.greenDays,
    required this.redDays,
    required this.bestMonth,
    this.crankiestWeekday,
  });

  final int greenDays;
  final int redDays;
  final String bestMonth;
  final String? crankiestWeekday;
}

MoodInsights computeInsights(List<DayMood> days) {
  final green = days.where((d) => d.momMood != null && d.momMood! >= 4).length;
  final red = days.where((d) => d.isLeapStorm).length;

  // Best month: month with most green days
  final monthCounts = <int, int>{};
  for (final d in days) {
    if (d.momMood != null && d.momMood! >= 4) {
      monthCounts[d.date.month] = (monthCounts[d.date.month] ?? 0) + 1;
    }
  }
  final bestMonthNum = monthCounts.isEmpty
      ? DateTime.now().month
      : monthCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

  const months = [
    '', 'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
    'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'
  ];

  // Crankiest weekday
  final weekdayCounts = <int, int>{};
  for (final d in days) {
    if (d.isLeapStorm) {
      weekdayCounts[d.date.weekday] =
          (weekdayCounts[d.date.weekday] ?? 0) + 1;
    }
  }
  const weekdays = ['', 'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'CN'];
  final crankiest = weekdayCounts.isEmpty
      ? null
      : weekdays[weekdayCounts.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key];

  return MoodInsights(
    greenDays: green,
    redDays: red,
    bestMonth: months[bestMonthNum],
    crankiestWeekday: crankiest,
  );
}
