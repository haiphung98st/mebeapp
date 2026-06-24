import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/vaccine_schedule_data.dart';
import '../models/vaccine_entry.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';
import 'baby_provider.dart';

enum VaccineStatus { done, upcoming, notYet, overdue }

class VaccineViewItem {
  const VaccineViewItem({required this.def, required this.scheduledDate, this.entry});

  final VaccineDef def;
  final DateTime scheduledDate;
  final VaccineEntry? entry;

  bool get isCompleted => entry?.isCompleted ?? false;

  VaccineStatus get status {
    if (isCompleted) return VaccineStatus.done;
    final now = DateTime.now();
    if (scheduledDate.isBefore(now)) return VaccineStatus.overdue;
    if (scheduledDate.difference(now).inDays <= 7) return VaccineStatus.upcoming;
    return VaccineStatus.notYet;
  }
}

final allVaccinesProvider = StreamProvider<List<VaccineEntry>>((ref) {
  final user = ref.watch(currentUserProvider);
  final baby = ref.watch(activeBabyProvider);
  if (user == null || baby == null) return Stream.value(const []);
  return ref.watch(firestoreServiceProvider).watchVaccines(user.uid, baby.id);
});

final vaccineViewListProvider = Provider<List<VaccineViewItem>>((ref) {
  final baby = ref.watch(activeBabyProvider);
  if (baby == null) return const [];
  final entries = ref.watch(allVaccinesProvider).value ?? const [];
  final byKey = {for (final e in entries) e.vaccineKey: e};
  return vaccineDefs.map((def) {
    return VaccineViewItem(
      def: def,
      scheduledDate: baby.dateOfBirth.add(Duration(days: def.offsetDays)),
      entry: byKey[def.key],
    );
  }).toList();
});

final upcomingVaccineAlertProvider = Provider<VaccineViewItem?>((ref) {
  final items = ref.watch(vaccineViewListProvider);
  for (final item in items) {
    if (item.status == VaccineStatus.upcoming) return item;
  }
  return null;
});

class VaccineRepository {
  VaccineRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  Future<void> markAdministered(
    VaccineViewItem item, {
    required String userId,
    required String babyId,
    required DateTime administeredDate,
    String? clinicName,
  }) {
    final entry = (item.entry ?? VaccineEntry(
      id: _firestoreService.newId(),
      babyId: babyId,
      vaccineKey: item.def.key,
      nameVi: item.def.nameVi,
      scheduledDate: item.scheduledDate,
      isCompleted: false,
      createdAt: DateTime.now(),
    )).copyWith(administeredDate: administeredDate, isCompleted: true, clinicName: clinicName);

    return item.entry == null
        ? _firestoreService.addVaccine(userId, entry)
        : _firestoreService.updateVaccine(userId, entry);
  }
}

final vaccineRepositoryProvider = Provider<VaccineRepository>((ref) {
  return VaccineRepository(ref.watch(firestoreServiceProvider));
});
