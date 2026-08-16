import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/providers/auth_provider.dart';
import '../../../shared/services/firestore_service.dart';
import 'prenatal_entry.dart';

final allPrenatalProvider = StreamProvider<List<PrenatalEntry>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(const []);
  return ref.watch(firestoreServiceProvider).watchPrenatal(user.uid);
});

class PrenatalNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> add(PrenatalEntry entry) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    await ref.read(firestoreServiceProvider).addPrenatalEntry(entry);
  }

  Future<void> delete(String entryId) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    await ref
        .read(firestoreServiceProvider)
        .deletePrenatalEntry(user.uid, entryId);
  }
}

final prenatalNotifierProvider =
    NotifierProvider<PrenatalNotifier, void>(PrenatalNotifier.new);

String newPrenatalId() => const Uuid().v4();
