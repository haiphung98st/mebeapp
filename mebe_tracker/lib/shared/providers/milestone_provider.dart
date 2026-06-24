import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/milestone_data.dart';
import '../models/milestone_entry.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';
import 'baby_provider.dart';

enum MilestoneStatus { achieved, inProgress, notYet }

class MilestoneViewItem {
  const MilestoneViewItem({required this.def, this.entry});

  final MilestoneDef def;
  final MilestoneEntry? entry;

  bool get isAchieved => entry?.isAchieved ?? false;

  MilestoneStatus statusAt(int ageWeeks) {
    if (isAchieved) return MilestoneStatus.achieved;
    if (ageWeeks >= def.expectedWeekMin) return MilestoneStatus.inProgress;
    return MilestoneStatus.notYet;
  }
}

final allMilestonesProvider = StreamProvider<List<MilestoneEntry>>((ref) {
  final user = ref.watch(currentUserProvider);
  final baby = ref.watch(activeBabyProvider);
  if (user == null || baby == null) return Stream.value(const []);
  return ref.watch(firestoreServiceProvider).watchMilestones(user.uid, baby.id);
});

final milestoneViewListProvider = Provider<List<MilestoneViewItem>>((ref) {
  final entries = ref.watch(allMilestonesProvider).value ?? const [];
  final byKey = {for (final e in entries) e.milestoneKey: e};
  return milestoneDefs.map((def) => MilestoneViewItem(def: def, entry: byKey[def.key])).toList();
});

class MilestoneRepository {
  MilestoneRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  Future<void> markAchieved(
    MilestoneViewItem item, {
    required String userId,
    required String babyId,
    required DateTime achievedAt,
    String? photoUrl,
  }) {
    final entry = (item.entry ?? MilestoneEntry(
      id: _firestoreService.newId(),
      babyId: babyId,
      milestoneKey: item.def.key,
      titleVi: item.def.titleVi,
      expectedWeekMin: item.def.expectedWeekMin,
      expectedWeekMax: item.def.expectedWeekMax,
      isAchieved: false,
    )).copyWith(achievedAt: achievedAt, isAchieved: true, photoUrl: photoUrl);

    return item.entry == null
        ? _firestoreService.addMilestone(userId, entry)
        : _firestoreService.updateMilestone(userId, entry);
  }

  Future<void> updateAchievedDate(
    MilestoneEntry entry, {
    required String userId,
    required DateTime achievedAt,
  }) {
    return _firestoreService.updateMilestone(userId, entry.copyWith(achievedAt: achievedAt));
  }
}

final milestoneRepositoryProvider = Provider<MilestoneRepository>((ref) {
  return MilestoneRepository(ref.watch(firestoreServiceProvider));
});
