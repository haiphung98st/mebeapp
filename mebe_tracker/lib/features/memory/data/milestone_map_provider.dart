import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/achievement/data/achievement_data.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/baby_provider.dart';

class MilestoneMapItem {
  const MilestoneMapItem({
    required this.id,
    required this.type,
    required this.emoji,
    required this.titleVi,
    required this.date,
    required this.color,
    this.shareText,
  });

  final String id;
  final String type; // 'achievement'|'milestone'
  final String emoji;
  final String titleVi;
  final DateTime date;
  final Color color;
  final String? shareText;
}

Color _colorForTier(AchievementTier tier) {
  switch (tier) {
    case AchievementTier.bronze:
      return const Color(0xFFCD7F32);
    case AchievementTier.silver:
      return const Color(0xFFC0C0C0);
    case AchievementTier.gold:
      return const Color(0xFFFFD700);
    case AchievementTier.platinum:
      return const Color(0xFFB9F2FF);
  }
}

final milestoneMapProvider =
    FutureProvider<List<MilestoneMapItem>>((ref) async {
  final user = ref.watch(currentUserProvider);
  final baby = ref.watch(activeBabyProvider);
  if (user == null || baby == null) return [];

  final items = <MilestoneMapItem>[];

  // From achievements
  final achSnap = await FirebaseFirestore.instance
      .collection('users/${user.uid}/babies/${baby.id}/achievements')
      .orderBy('unlockedAt')
      .get();

  for (final d in achSnap.docs) {
    final achId = d.data()['achievementId'] as String? ?? '';
    final AchievementDef? ach =
        allAchievements.where((a) => a.id == achId).firstOrNull;
    if (ach == null) continue;
    final ts = d.data()['unlockedAt'];
    if (ts == null) continue;
    items.add(MilestoneMapItem(
      id: d.id,
      type: 'achievement',
      emoji: ach.icon,
      titleVi: ach.name,
      date: (ts as Timestamp).toDate(),
      color: _colorForTier(ach.tier),
      shareText: '${ach.icon} ${ach.name}: ${ach.description}',
    ));
  }

  // From milestones
  try {
    final milSnap = await FirebaseFirestore.instance
        .collection('users/${user.uid}/babies/${baby.id}/milestones')
        .where('achievedDate', isNotEqualTo: null)
        .get();

    for (final d in milSnap.docs) {
      final ts = d.data()['achievedDate'];
      if (ts == null) continue;
      items.add(MilestoneMapItem(
        id: d.id,
        type: 'milestone',
        emoji: d.data()['emoji'] as String? ?? '🌟',
        titleVi: d.data()['nameVi'] as String? ?? '',
        date: (ts as Timestamp).toDate(),
        color: const Color(0xFF7DE8C8),
      ));
    }
  } catch (_) {}

  items.sort((a, b) => a.date.compareTo(b.date));
  return items;
});
