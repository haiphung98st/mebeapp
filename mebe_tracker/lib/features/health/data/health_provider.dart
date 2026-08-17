import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/baby_provider.dart';
import '../../../shared/services/firestore_service.dart';
import 'health_models.dart';

final temperaturesProvider = StreamProvider<List<TemperatureReading>>((ref) {
  final user = ref.watch(currentUserProvider);
  final baby = ref.watch(activeBabyProvider);
  if (user == null || baby == null) return Stream.value([]);
  return ref
      .watch(firestoreServiceProvider)
      .watchTemperatures(user.uid, baby.id);
});

final medicinesProvider = StreamProvider<List<MedicineRecord>>((ref) {
  final user = ref.watch(currentUserProvider);
  final baby = ref.watch(activeBabyProvider);
  if (user == null || baby == null) return Stream.value([]);
  return ref
      .watch(firestoreServiceProvider)
      .watchMedicines(user.uid, baby.id);
});

final illnessesProvider = StreamProvider<List<IllnessEpisode>>((ref) {
  final user = ref.watch(currentUserProvider);
  final baby = ref.watch(activeBabyProvider);
  if (user == null || baby == null) return Stream.value([]);
  return ref
      .watch(firestoreServiceProvider)
      .watchIllnesses(user.uid, baby.id);
});
