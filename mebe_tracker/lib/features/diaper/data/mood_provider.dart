import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/baby_provider.dart';
import '../../../shared/services/firestore_service.dart';
import 'mood_entry.dart';

final allMoodsProvider = StreamProvider<List<MoodEntry>>((ref) {
  final user = ref.watch(currentUserProvider);
  final baby = ref.watch(activeBabyProvider);
  if (user == null || baby == null) return Stream.value(const []);
  return ref
      .watch(firestoreServiceProvider)
      .watchMoods(user.uid, baby.id);
});

final todayMoodsProvider = Provider<List<MoodEntry>>((ref) {
  final all = ref.watch(allMoodsProvider).value ?? [];
  final now = DateTime.now();
  return all.where((e) {
    final t = e.time;
    return t.year == now.year && t.month == now.month && t.day == now.day;
  }).toList();
});

class MoodNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> log(BabyMood mood, {String? notes}) async {
    final user = ref.read(currentUserProvider);
    final baby = ref.read(activeBabyProvider);
    if (user == null || baby == null) return;

    final entry = MoodEntry(
      id: const Uuid().v4(),
      babyId: baby.id,
      userId: user.uid,
      mood: mood,
      time: DateTime.now(),
      notes: notes,
    );
    await ref.read(firestoreServiceProvider).addMood(entry);
  }

  Future<void> delete(String entryId) async {
    final user = ref.read(currentUserProvider);
    final baby = ref.read(activeBabyProvider);
    if (user == null || baby == null) return;
    await ref.read(firestoreServiceProvider).deleteMood(user.uid, baby.id, entryId);
  }
}

final moodNotifierProvider = NotifierProvider<MoodNotifier, void>(MoodNotifier.new);
