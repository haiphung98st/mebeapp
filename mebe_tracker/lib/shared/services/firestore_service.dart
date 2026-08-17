import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../models/baby_profile.dart';
import '../models/diaper_entry.dart';
import '../models/feeding_entry.dart';
import '../models/growth_entry.dart';
import '../models/milestone_entry.dart';
import '../models/milk_stash_entry.dart';
import '../models/pump_entry.dart';
import '../models/sleep_entry.dart';
import '../models/vaccine_entry.dart';
import '../../features/diaper/data/mood_entry.dart';
import '../../features/growth/data/motor_entry.dart';
import '../../features/health/data/health_models.dart';
import '../../features/prenatal/data/prenatal_entry.dart';

/// Wraps all Firestore reads/writes for the `users/{userId}/babies/{babyId}/...`
/// data hierarchy described in the data-model spec.
class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final Uuid _uuid = const Uuid();

  String newId() => _uuid.v4();

  CollectionReference<Map<String, dynamic>> _babies(String userId) => _firestore
      .collection('users')
      .doc(userId)
      .collection('babies');

  DocumentReference<Map<String, dynamic>> _baby(String userId, String babyId) =>
      _babies(userId).doc(babyId);

  CollectionReference<Map<String, dynamic>> _feedings(String userId, String babyId) =>
      _baby(userId, babyId).collection('feedings');

  CollectionReference<Map<String, dynamic>> _pumps(String userId, String babyId) =>
      _baby(userId, babyId).collection('pumps');

  CollectionReference<Map<String, dynamic>> _sleeps(String userId, String babyId) =>
      _baby(userId, babyId).collection('sleeps');

  CollectionReference<Map<String, dynamic>> _diapers(String userId, String babyId) =>
      _baby(userId, babyId).collection('diapers');

  CollectionReference<Map<String, dynamic>> _growths(String userId, String babyId) =>
      _baby(userId, babyId).collection('growths');

  CollectionReference<Map<String, dynamic>> _milkStash(String userId, String babyId) =>
      _baby(userId, babyId).collection('milkStash');

  CollectionReference<Map<String, dynamic>> _milestones(String userId, String babyId) =>
      _baby(userId, babyId).collection('milestones');

  CollectionReference<Map<String, dynamic>> _vaccines(String userId, String babyId) =>
      _baby(userId, babyId).collection('vaccines');

  DocumentReference<Map<String, dynamic>> _teethDoc(String userId, String babyId) =>
      _baby(userId, babyId).collection('teeth').doc('eruptions');

  CollectionReference<Map<String, dynamic>> _moods(String userId, String babyId) =>
      _baby(userId, babyId).collection('moods');

  CollectionReference<Map<String, dynamic>> _motors(String userId, String babyId) =>
      _baby(userId, babyId).collection('motorActivities');

  CollectionReference<Map<String, dynamic>> _prenatal(String userId) =>
      _firestore.collection('users').doc(userId).collection('prenatal');

  // ---- Baby profiles ----

  Future<void> createBaby(BabyProfile baby) =>
      _baby(baby.userId, baby.id).set(baby.toFirestore());

  Future<void> updateBaby(BabyProfile baby) =>
      _baby(baby.userId, baby.id).update(baby.toFirestore());

  Future<void> deleteBaby(String userId, String babyId) =>
      _baby(userId, babyId).delete();

  Stream<BabyProfile?> watchBaby(String userId, String babyId) =>
      _baby(userId, babyId).snapshots().map((doc) => doc.exists ? BabyProfile.fromFirestore(doc) : null);

  Stream<List<BabyProfile>> watchBabies(String userId) => _babies(userId)
      .orderBy('createdAt')
      .snapshots()
      .map((s) => s.docs.map(BabyProfile.fromFirestore).toList());

  // ---- Feedings ----

  Future<void> addFeeding(FeedingEntry entry) =>
      _feedings(entry.userId, entry.babyId).doc(entry.id).set(entry.toFirestore());

  Future<void> updateFeeding(FeedingEntry entry) =>
      _feedings(entry.userId, entry.babyId).doc(entry.id).update(entry.toFirestore());

  Future<void> deleteFeeding(String userId, String babyId, String entryId) =>
      _feedings(userId, babyId).doc(entryId).delete();

  Stream<List<FeedingEntry>> watchFeedings(String userId, String babyId) =>
      _feedings(userId, babyId)
          .orderBy('startTime', descending: true)
          .snapshots()
          .map((s) => s.docs.map(FeedingEntry.fromFirestore).toList());

  // ---- Pumps ----

  Future<void> addPump(PumpEntry entry) =>
      _pumps(entry.userId, entry.babyId).doc(entry.id).set(entry.toFirestore());

  Future<void> updatePump(PumpEntry entry) =>
      _pumps(entry.userId, entry.babyId).doc(entry.id).update(entry.toFirestore());

  Future<void> deletePump(String userId, String babyId, String entryId) =>
      _pumps(userId, babyId).doc(entryId).delete();

  Stream<List<PumpEntry>> watchPumps(String userId, String babyId) => _pumps(userId, babyId)
      .orderBy('startTime', descending: true)
      .snapshots()
      .map((s) => s.docs.map(PumpEntry.fromFirestore).toList());

  // ---- Sleeps ----

  Future<void> addSleep(SleepEntry entry) =>
      _sleeps(entry.userId, entry.babyId).doc(entry.id).set(entry.toFirestore());

  Future<void> updateSleep(SleepEntry entry) =>
      _sleeps(entry.userId, entry.babyId).doc(entry.id).update(entry.toFirestore());

  Future<void> deleteSleep(String userId, String babyId, String entryId) =>
      _sleeps(userId, babyId).doc(entryId).delete();

  Stream<List<SleepEntry>> watchSleeps(String userId, String babyId) => _sleeps(userId, babyId)
      .orderBy('startTime', descending: true)
      .snapshots()
      .map((s) => s.docs.map(SleepEntry.fromFirestore).toList());

  // ---- Diapers ----

  Future<void> addDiaper(DiaperEntry entry) =>
      _diapers(entry.userId, entry.babyId).doc(entry.id).set(entry.toFirestore());

  Future<void> updateDiaper(DiaperEntry entry) =>
      _diapers(entry.userId, entry.babyId).doc(entry.id).update(entry.toFirestore());

  Future<void> deleteDiaper(String userId, String babyId, String entryId) =>
      _diapers(userId, babyId).doc(entryId).delete();

  Stream<List<DiaperEntry>> watchDiapers(String userId, String babyId) => _diapers(userId, babyId)
      .orderBy('time', descending: true)
      .snapshots()
      .map((s) => s.docs.map(DiaperEntry.fromFirestore).toList());

  // ---- Growths ----

  Future<void> addGrowth(GrowthEntry entry) =>
      _growths(entry.userId, entry.babyId).doc(entry.id).set(entry.toFirestore());

  Future<void> updateGrowth(GrowthEntry entry) =>
      _growths(entry.userId, entry.babyId).doc(entry.id).update(entry.toFirestore());

  Future<void> deleteGrowth(String userId, String babyId, String entryId) =>
      _growths(userId, babyId).doc(entryId).delete();

  Stream<List<GrowthEntry>> watchGrowths(String userId, String babyId) => _growths(userId, babyId)
      .orderBy('measuredAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(GrowthEntry.fromFirestore).toList());

  // ---- Milk stash ----

  Future<void> addMilkStash(MilkStashEntry entry) =>
      _milkStash(entry.userId, entry.babyId).doc(entry.id).set(entry.toFirestore());

  Future<void> updateMilkStash(MilkStashEntry entry) =>
      _milkStash(entry.userId, entry.babyId).doc(entry.id).update(entry.toFirestore());

  Future<void> deleteMilkStash(String userId, String babyId, String entryId) =>
      _milkStash(userId, babyId).doc(entryId).delete();

  Stream<List<MilkStashEntry>> watchMilkStash(String userId, String babyId) =>
      _milkStash(userId, babyId)
          .orderBy('pumpedAt', descending: true)
          .snapshots()
          .map((s) => s.docs.map(MilkStashEntry.fromFirestore).toList());

  // ---- Milestones ----

  Future<void> addMilestone(String userId, MilestoneEntry entry) =>
      _milestones(userId, entry.babyId).doc(entry.id).set(entry.toFirestore());

  Future<void> updateMilestone(String userId, MilestoneEntry entry) =>
      _milestones(userId, entry.babyId).doc(entry.id).update(entry.toFirestore());

  Future<void> deleteMilestone(String userId, String babyId, String entryId) =>
      _milestones(userId, babyId).doc(entryId).delete();

  Stream<List<MilestoneEntry>> watchMilestones(String userId, String babyId) =>
      _milestones(userId, babyId)
          .orderBy('expectedWeekMin')
          .snapshots()
          .map((s) => s.docs.map(MilestoneEntry.fromFirestore).toList());

  // ---- Vaccines ----

  Future<void> addVaccine(String userId, VaccineEntry entry) =>
      _vaccines(userId, entry.babyId).doc(entry.id).set(entry.toFirestore());

  Future<void> updateVaccine(String userId, VaccineEntry entry) =>
      _vaccines(userId, entry.babyId).doc(entry.id).update(entry.toFirestore());

  Future<void> deleteVaccine(String userId, String babyId, String entryId) =>
      _vaccines(userId, babyId).doc(entryId).delete();

  Stream<List<VaccineEntry>> watchVaccines(String userId, String babyId) =>
      _vaccines(userId, babyId)
          .orderBy('scheduledDate')
          .snapshots()
          .map((s) => s.docs.map(VaccineEntry.fromFirestore).toList());

  // ---- Teeth ----

  Stream<Map<String, DateTime>> watchTeeth(String userId, String babyId) =>
      _teethDoc(userId, babyId).snapshots().map((doc) {
        final data = doc.data();
        if (data == null) return {};
        return data.map((k, v) => MapEntry(k, (v as Timestamp).toDate()));
      });

  Future<void> markToothErupted(String userId, String babyId, String toothId, DateTime at) =>
      _teethDoc(userId, babyId).set(
        {toothId: Timestamp.fromDate(at)},
        SetOptions(merge: true),
      );

  Future<void> unmarkToothErupted(String userId, String babyId, String toothId) =>
      _teethDoc(userId, babyId).update({toothId: FieldValue.delete()});

  // ---- Mood ----

  Stream<List<MoodEntry>> watchMoods(String userId, String babyId) =>
      _moods(userId, babyId)
          .orderBy('time', descending: true)
          .snapshots()
          .map((s) => s.docs.map(MoodEntry.fromFirestore).toList());

  Future<void> addMood(MoodEntry entry) =>
      _moods(entry.userId, entry.babyId).doc(entry.id).set(entry.toFirestore());

  Future<void> deleteMood(String userId, String babyId, String entryId) =>
      _moods(userId, babyId).doc(entryId).delete();

  // ---- Motor Activities ----

  Stream<List<MotorEntry>> watchMotors(String userId, String babyId) =>
      _motors(userId, babyId)
          .orderBy('startTime', descending: true)
          .snapshots()
          .map((s) => s.docs.map(MotorEntry.fromFirestore).toList());

  Future<void> addMotor(MotorEntry entry) =>
      _motors(entry.userId, entry.babyId).doc(entry.id).set(entry.toFirestore());

  Future<void> deleteMotor(String userId, String babyId, String entryId) =>
      _motors(userId, babyId).doc(entryId).delete();

  // ---- Prenatal ----

  Stream<List<PrenatalEntry>> watchPrenatal(String userId) =>
      _prenatal(userId)
          .orderBy('date', descending: true)
          .snapshots()
          .map((s) => s.docs.map(PrenatalEntry.fromFirestore).toList());

  Future<void> addPrenatalEntry(PrenatalEntry entry) =>
      _prenatal(entry.userId).doc(entry.id).set(entry.toFirestore());

  Future<void> deletePrenatalEntry(String userId, String entryId) =>
      _prenatal(userId).doc(entryId).delete();

  // ---- Health: Temperature ----

  CollectionReference<Map<String, dynamic>> _temperatures(
          String userId, String babyId) =>
      _baby(userId, babyId).collection('temperatures');

  CollectionReference<Map<String, dynamic>> _medicines(
          String userId, String babyId) =>
      _baby(userId, babyId).collection('medicines');

  CollectionReference<Map<String, dynamic>> _illnesses(
          String userId, String babyId) =>
      _baby(userId, babyId).collection('illnesses');

  Stream<List<TemperatureReading>> watchTemperatures(
          String userId, String babyId) =>
      _temperatures(userId, babyId)
          .orderBy('recordedAt', descending: true)
          .limit(30)
          .snapshots()
          .map((s) => s.docs.map(TemperatureReading.fromFirestore).toList());

  Future<void> addTemperature(TemperatureReading entry) =>
      _temperatures(entry.userId, entry.babyId)
          .doc(entry.id)
          .set(entry.toFirestore());

  Future<void> deleteTemperature(
          String userId, String babyId, String entryId) =>
      _temperatures(userId, babyId).doc(entryId).delete();

  Stream<List<MedicineRecord>> watchMedicines(
          String userId, String babyId) =>
      _medicines(userId, babyId)
          .orderBy('givenAt', descending: true)
          .limit(50)
          .snapshots()
          .map((s) => s.docs.map(MedicineRecord.fromFirestore).toList());

  Future<void> addMedicine(MedicineRecord entry) =>
      _medicines(entry.userId, entry.babyId)
          .doc(entry.id)
          .set(entry.toFirestore());

  Future<void> deleteMedicine(String userId, String babyId, String entryId) =>
      _medicines(userId, babyId).doc(entryId).delete();

  Stream<List<IllnessEpisode>> watchIllnesses(
          String userId, String babyId) =>
      _illnesses(userId, babyId)
          .orderBy('startedAt', descending: true)
          .snapshots()
          .map((s) => s.docs.map(IllnessEpisode.fromFirestore).toList());

  Future<void> addIllness(IllnessEpisode entry) =>
      _illnesses(entry.userId, entry.babyId)
          .doc(entry.id)
          .set(entry.toFirestore());

  Future<void> updateIllness(IllnessEpisode entry) =>
      _illnesses(entry.userId, entry.babyId)
          .doc(entry.id)
          .update(entry.toFirestore());

  Future<void> deleteIllness(String userId, String babyId, String entryId) =>
      _illnesses(userId, babyId).doc(entryId).delete();

  // ---- Subscription ----

  DocumentReference<Map<String, dynamic>> _subscription(String userId) =>
      _firestore.collection('users').doc(userId).collection('meta').doc('subscription');

  Future<void> updateSubscription(String userId, Map<String, dynamic> data) =>
      _subscription(userId).set(data, SetOptions(merge: true));

  Stream<Map<String, dynamic>?> watchSubscription(String userId) =>
      _subscription(userId).snapshots().map((doc) => doc.data());
}
