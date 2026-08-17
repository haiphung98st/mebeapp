import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/baby_provider.dart';

final teethProvider = StreamProvider<Map<String, DateTime>>((ref) {
  final user = ref.watch(currentUserProvider);
  final baby = ref.watch(activeBabyProvider);
  if (user == null || baby == null) return Stream.value(const {});
  return ref.watch(firestoreServiceProvider).watchTeeth(user.uid, baby.id);
});

class TeethNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> markErupted(String toothId, DateTime at) async {
    final user = ref.read(currentUserProvider);
    final baby = ref.read(activeBabyProvider);
    if (user == null || baby == null) return;
    await ref.read(firestoreServiceProvider).markToothErupted(user.uid, baby.id, toothId, at);
  }

  Future<void> unmark(String toothId) async {
    final user = ref.read(currentUserProvider);
    final baby = ref.read(activeBabyProvider);
    if (user == null || baby == null) return;
    await ref.read(firestoreServiceProvider).unmarkToothErupted(user.uid, baby.id, toothId);
  }
}

final teethNotifierProvider = NotifierProvider<TeethNotifier, void>(TeethNotifier.new);
