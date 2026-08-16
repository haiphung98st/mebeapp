import 'package:cloud_firestore/cloud_firestore.dart';

class PrenatalEntry {
  const PrenatalEntry({
    required this.id,
    required this.userId,
    required this.week,
    required this.date,
    this.notes,
    this.weightKg,
    this.bloodPressureSystolic,
    this.bloodPressureDiastolic,
    this.symptoms = const [],
  });

  final String id;
  final String userId;
  final int week;
  final DateTime date;
  final String? notes;
  final double? weightKg;
  final int? bloodPressureSystolic;
  final int? bloodPressureDiastolic;
  final List<String> symptoms;

  factory PrenatalEntry.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return PrenatalEntry(
      id: doc.id,
      userId: data['userId'] as String,
      week: data['week'] as int,
      date: (data['date'] as Timestamp).toDate(),
      notes: data['notes'] as String?,
      weightKg: (data['weightKg'] as num?)?.toDouble(),
      bloodPressureSystolic: data['bloodPressureSystolic'] as int?,
      bloodPressureDiastolic: data['bloodPressureDiastolic'] as int?,
      symptoms: List<String>.from(data['symptoms'] as List? ?? []),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'week': week,
    'date': Timestamp.fromDate(date),
    if (notes != null) 'notes': notes,
    if (weightKg != null) 'weightKg': weightKg,
    if (bloodPressureSystolic != null) 'bloodPressureSystolic': bloodPressureSystolic,
    if (bloodPressureDiastolic != null) 'bloodPressureDiastolic': bloodPressureDiastolic,
    'symptoms': symptoms,
  };
}

const prenatalSymptoms = [
  'Buồn nôn', 'Đau lưng', 'Phù chân', 'Mệt mỏi', 'Ợ chua',
  'Đau đầu', 'Chóng mặt', 'Chuột rút', 'Đau ngực', 'Khó ngủ',
];
