import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/sleep_entry.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/baby_provider.dart';
import '../../../shared/providers/home_provider.dart';
import 'community_message.dart';
import 'community_stat_entry.dart';

final _fs = FirebaseFirestore.instance;

CollectionReference<Map<String, dynamic>> _statsCol(String weekKey) =>
    _fs.collection('community_stats').doc(weekKey).collection('entries');

String _hashUserId(String userId) => userId.codeUnits
    .fold(0, (h, c) => (h * 31 + c) & 0xFFFFFFFF)
    .toRadixString(16);

String _todayKey() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}

int _totalSleepMinutes(List<SleepEntry> sleeps) =>
    sleeps.fold(0, (sum, s) {
      if (s.endTime == null) return sum;
      return sum + s.endTime!.difference(s.startTime).inMinutes;
    });

// Reads today's anonymous stat entries for the current community week group.
final communityStatsEntriesProvider =
    StreamProvider<List<CommunityStatEntry>>((ref) {
  final baby = ref.watch(activeBabyProvider);
  if (baby == null) return Stream.value(const []);
  final weekKey = communityKeyForDate(baby.dateOfBirth);
  final dateKey = _todayKey();
  return _statsCol(weekKey)
      .where('date', isEqualTo: dateKey)
      .snapshots()
      .map((s) => s.docs.map(CommunityStatEntry.fromFirestore).toList());
});

class CommunityPercentiles {
  const CommunityPercentiles({
    required this.feedingPct,
    required this.sleepPct,
    required this.diaperPct,
    required this.myEntry,
    required this.totalContributors,
  });

  final double feedingPct; // 0..100, higher = more feedings than peers
  final double sleepPct; // higher = more sleep than peers
  final double diaperPct; // higher = more diapers than peers
  final CommunityStatEntry? myEntry;
  final int totalContributors;
}

double _percentile(List<int> values, int myValue) {
  if (values.isEmpty || values.length == 1) return 50;
  final below = values.where((v) => v < myValue).length;
  return (below / values.length * 100).clamp(0, 99).toDouble();
}

final communityPercentilesProvider = Provider<CommunityPercentiles?>((ref) {
  final user = ref.watch(currentUserProvider);
  final baby = ref.watch(activeBabyProvider);
  if (user == null || baby == null) return null;

  final entriesAsync = ref.watch(communityStatsEntriesProvider);
  if (!entriesAsync.hasValue) return null;
  final entries = entriesAsync.value!;

  final myHash = _hashUserId(user.uid);
  final myEntry = entries.where((e) => e.hashedUserId == myHash).firstOrNull;

  if (myEntry == null) {
    return CommunityPercentiles(
      feedingPct: 50,
      sleepPct: 50,
      diaperPct: 50,
      myEntry: null,
      totalContributors: entries.length,
    );
  }

  return CommunityPercentiles(
    feedingPct: _percentile(
        entries.map((e) => e.feedingCount).toList(), myEntry.feedingCount),
    sleepPct: _percentile(
        entries.map((e) => e.totalSleepMinutes).toList(),
        myEntry.totalSleepMinutes),
    diaperPct: _percentile(
        entries.map((e) => e.diaperCount).toList(), myEntry.diaperCount),
    myEntry: myEntry,
    totalContributors: entries.length,
  );
});

// Call this to publish the current user's today stats to the community.
Future<void> publishCommunityStats(WidgetRef ref) async {
  final user = ref.read(currentUserProvider);
  final baby = ref.read(activeBabyProvider);
  if (user == null || baby == null) return;

  final feedings = ref.read(todayFeedingsProvider);
  final sleeps = ref.read(todaySleepsProvider);
  final diapers = ref.read(todayDiapersProvider);

  final weekKey = communityKeyForDate(baby.dateOfBirth);
  final dateKey = _todayKey();
  final hashedUserId = _hashUserId(user.uid);

  final entry = CommunityStatEntry(
    weekKey: weekKey,
    hashedUserId: hashedUserId,
    date: dateKey,
    feedingCount: feedings.length,
    totalSleepMinutes: _totalSleepMinutes(sleeps),
    diaperCount: diapers.length,
  );

  await _statsCol(weekKey)
      .doc(entry.docId)
      .set(entry.toFirestore(), SetOptions(merge: true));
}
