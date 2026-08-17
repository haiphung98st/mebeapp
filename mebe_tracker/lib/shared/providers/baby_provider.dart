import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/baby_profile.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final babiesProvider = StreamProvider<List<BabyProfile>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(const []);
  return ref.watch(firestoreServiceProvider).watchBabies(user.uid);
});

class ActiveBabyIdNotifier extends StateNotifier<String?> {
  static const _key = 'active_baby_id';

  ActiveBabyIdNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_key);
  }

  Future<void> setActiveBaby(String babyId) async {
    state = babyId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, babyId);
  }
}

final activeBabyIdProvider =
    StateNotifierProvider<ActiveBabyIdNotifier, String?>(
        (_) => ActiveBabyIdNotifier());

final activeBabyProvider = Provider<BabyProfile?>((ref) {
  final babies = ref.watch(babiesProvider).value;
  if (babies == null || babies.isEmpty) return null;
  final savedId = ref.watch(activeBabyIdProvider);
  if (savedId != null) {
    final found = babies.where((b) => b.id == savedId).firstOrNull;
    if (found != null) return found;
  }
  return babies.first;
});
