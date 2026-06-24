import 'package:flutter_riverpod/flutter_riverpod.dart';

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

final activeBabyProvider = Provider<BabyProfile?>((ref) {
  final babies = ref.watch(babiesProvider).value;
  if (babies == null || babies.isEmpty) return null;
  return babies.first;
});
