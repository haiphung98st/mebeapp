import 'package:cloud_firestore/cloud_firestore.dart';

class TemperatureReading {
  const TemperatureReading({
    required this.id,
    required this.userId,
    required this.babyId,
    required this.recordedAt,
    required this.tempCelsius,
    this.notes,
  });

  final String id;
  final String userId;
  final String babyId;
  final DateTime recordedAt;
  final double tempCelsius;
  final String? notes;

  factory TemperatureReading.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return TemperatureReading(
      id: doc.id,
      userId: d['userId'] as String,
      babyId: d['babyId'] as String,
      recordedAt: (d['recordedAt'] as Timestamp).toDate(),
      tempCelsius: (d['tempCelsius'] as num).toDouble(),
      notes: d['notes'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'babyId': babyId,
        'recordedAt': Timestamp.fromDate(recordedAt),
        'tempCelsius': tempCelsius,
        if (notes != null) 'notes': notes,
      };

  bool get isFever => tempCelsius >= 38.0;
}

class MedicineRecord {
  const MedicineRecord({
    required this.id,
    required this.userId,
    required this.babyId,
    required this.medicineName,
    required this.givenAt,
    this.doseMg,
    this.doseUnit = 'mg',
    this.nextDoseAt,
    this.notes,
  });

  final String id;
  final String userId;
  final String babyId;
  final String medicineName;
  final DateTime givenAt;
  final double? doseMg;
  final String doseUnit;
  final DateTime? nextDoseAt;
  final String? notes;

  factory MedicineRecord.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return MedicineRecord(
      id: doc.id,
      userId: d['userId'] as String,
      babyId: d['babyId'] as String,
      medicineName: d['medicineName'] as String,
      givenAt: (d['givenAt'] as Timestamp).toDate(),
      doseMg: d['doseMg'] != null ? (d['doseMg'] as num).toDouble() : null,
      doseUnit: d['doseUnit'] as String? ?? 'mg',
      nextDoseAt: d['nextDoseAt'] != null
          ? (d['nextDoseAt'] as Timestamp).toDate()
          : null,
      notes: d['notes'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'babyId': babyId,
        'medicineName': medicineName,
        'givenAt': Timestamp.fromDate(givenAt),
        if (doseMg != null) 'doseMg': doseMg,
        'doseUnit': doseUnit,
        if (nextDoseAt != null) 'nextDoseAt': Timestamp.fromDate(nextDoseAt!),
        if (notes != null) 'notes': notes,
      };
}

class IllnessEpisode {
  const IllnessEpisode({
    required this.id,
    required this.userId,
    required this.babyId,
    required this.title,
    required this.startedAt,
    this.endedAt,
    this.symptoms = const [],
    this.notes,
  });

  final String id;
  final String userId;
  final String babyId;
  final String title;
  final DateTime startedAt;
  final DateTime? endedAt;
  final List<String> symptoms;
  final String? notes;

  bool get isActive => endedAt == null;

  factory IllnessEpisode.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return IllnessEpisode(
      id: doc.id,
      userId: d['userId'] as String,
      babyId: d['babyId'] as String,
      title: d['title'] as String,
      startedAt: (d['startedAt'] as Timestamp).toDate(),
      endedAt:
          d['endedAt'] != null ? (d['endedAt'] as Timestamp).toDate() : null,
      symptoms: List<String>.from(d['symptoms'] as List? ?? []),
      notes: d['notes'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'babyId': babyId,
        'title': title,
        'startedAt': Timestamp.fromDate(startedAt),
        if (endedAt != null) 'endedAt': Timestamp.fromDate(endedAt!),
        'symptoms': symptoms,
        if (notes != null) 'notes': notes,
      };
}
