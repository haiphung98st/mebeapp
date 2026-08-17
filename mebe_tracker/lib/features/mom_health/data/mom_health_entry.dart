import 'package:cloud_firestore/cloud_firestore.dart';

class MomHealthEntry {
  const MomHealthEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.mood,
    this.waterGlasses = 0,
    this.sleepHours = 0,
    this.medicines = const [],
    this.notes,
  });

  final String id;
  final String userId;
  final DateTime date;
  // mood: 1 = very sad, 5 = very happy
  final int mood;
  final int waterGlasses;
  final double sleepHours;
  final List<String> medicines;
  final String? notes;

  String get dateKey =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  factory MomHealthEntry.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return MomHealthEntry(
      id: doc.id,
      userId: d['userId'] as String,
      date: (d['date'] as Timestamp).toDate(),
      mood: (d['mood'] as num).toInt(),
      waterGlasses: (d['waterGlasses'] as num?)?.toInt() ?? 0,
      sleepHours: (d['sleepHours'] as num?)?.toDouble() ?? 0,
      medicines: List<String>.from(d['medicines'] as List? ?? []),
      notes: d['notes'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'date': Timestamp.fromDate(date),
        'mood': mood,
        'waterGlasses': waterGlasses,
        'sleepHours': sleepHours,
        'medicines': medicines,
        if (notes != null) 'notes': notes,
      };

  MomHealthEntry copyWith({
    int? mood,
    int? waterGlasses,
    double? sleepHours,
    List<String>? medicines,
    String? notes,
  }) =>
      MomHealthEntry(
        id: id,
        userId: userId,
        date: date,
        mood: mood ?? this.mood,
        waterGlasses: waterGlasses ?? this.waterGlasses,
        sleepHours: sleepHours ?? this.sleepHours,
        medicines: medicines ?? this.medicines,
        notes: notes ?? this.notes,
      );
}

const epdsQuestions = [
  'Tôi có thể cười và nhìn thấy mặt hài hước của mọi thứ',
  'Tôi nhìn về phía trước với niềm vui',
  'Tôi đã tự trách mình không cần thiết khi mọi thứ không đúng',
  'Tôi đã lo lắng hoặc lo âu mà không có lý do chính đáng',
  'Tôi đã sợ hãi hoặc hoảng sợ mà không có lý do chính đáng',
  'Mọi thứ đã đổ dồn lên tôi',
  'Tôi cảm thấy rất buồn đến mức khó ngủ',
  'Tôi cảm thấy buồn hoặc khổ sở',
  'Tôi đã khóc vì cảm thấy không hạnh phúc',
  'Ý nghĩ tự làm hại bản thân đã xuất hiện trong đầu tôi',
];

const dailyMotivations = [
  'Bạn đang làm điều tuyệt vời nhất có thể — yêu thương con của mình 💖',
  'Mỗi ngày là một ngày mới để bắt đầu lại. Bạn đủ mạnh mẽ.',
  'Chăm sóc bản thân không phải ích kỷ — đó là cần thiết.',
  'Bạn không cần phải hoàn hảo. Con bạn chỉ cần bạn.',
  'Hãy tự hào về những bước nhỏ bạn đã đi hôm nay.',
  'Ngủ đủ giấc, uống đủ nước — bạn xứng đáng được chăm sóc.',
  'Bạn không đơn độc. Rất nhiều mẹ đang đi cùng hành trình với bạn.',
];
