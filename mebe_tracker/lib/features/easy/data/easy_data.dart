// EASY Schedule — Eat, Activity, Sleep, You
enum EasyBlockType { eat, activity, sleep, you, other }

extension EasyBlockTypeX on EasyBlockType {
  String get emoji {
    switch (this) {
      case EasyBlockType.eat: return '🍼';
      case EasyBlockType.activity: return '🐢';
      case EasyBlockType.sleep: return '😴';
      case EasyBlockType.you: return '☕';
      case EasyBlockType.other: return '⏱️';
    }
  }

  String get label {
    switch (this) {
      case EasyBlockType.eat: return 'Ăn (Eat)';
      case EasyBlockType.activity: return 'Hoạt động (Activity)';
      case EasyBlockType.sleep: return 'Ngủ (Sleep)';
      case EasyBlockType.you: return 'Me (You)';
      case EasyBlockType.other: return 'Khác';
    }
  }

  int get colorValue {
    switch (this) {
      case EasyBlockType.eat: return 0xFFF472A0;
      case EasyBlockType.activity: return 0xFF7DE8C8;
      case EasyBlockType.sleep: return 0xFF7B5AAA;
      case EasyBlockType.you: return 0xFFF59E0B;
      case EasyBlockType.other: return 0xFFB899AC;
    }
  }

  String get name => toString().split('.').last;
}

EasyBlockType blockTypeFromString(String s) =>
    EasyBlockType.values.firstWhere((t) => t.name == s,
        orElse: () => EasyBlockType.other);

class EasyBlock {
  const EasyBlock({
    required this.id,
    required this.type,
    required this.startMinute, // minutes since midnight
    required this.durationMinutes,
    this.label,
  });

  final String id;
  final EasyBlockType type;
  final int startMinute;
  final int durationMinutes;
  final String? label;

  int get endMinute => startMinute + durationMinutes;

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'startMinute': startMinute,
    'durationMinutes': durationMinutes,
    if (label != null) 'label': label,
  };

  factory EasyBlock.fromJson(Map<String, dynamic> json) => EasyBlock(
    id: json['id'] as String,
    type: blockTypeFromString(json['type'] as String),
    startMinute: json['startMinute'] as int,
    durationMinutes: json['durationMinutes'] as int,
    label: json['label'] as String?,
  );
}

// Suggested default EASY schedule for a 3–4 month old
final defaultEasySchedule = [
  EasyBlock(id: '1', type: EasyBlockType.eat, startMinute: 7 * 60, durationMinutes: 30),
  EasyBlock(id: '2', type: EasyBlockType.activity, startMinute: 7 * 60 + 30, durationMinutes: 45),
  EasyBlock(id: '3', type: EasyBlockType.sleep, startMinute: 9 * 60, durationMinutes: 90),
  EasyBlock(id: '4', type: EasyBlockType.you, startMinute: 9 * 60, durationMinutes: 60),
  EasyBlock(id: '5', type: EasyBlockType.eat, startMinute: 10 * 60 + 30, durationMinutes: 30),
  EasyBlock(id: '6', type: EasyBlockType.activity, startMinute: 11 * 60, durationMinutes: 45),
  EasyBlock(id: '7', type: EasyBlockType.sleep, startMinute: 12 * 60 + 30, durationMinutes: 90),
  EasyBlock(id: '8', type: EasyBlockType.eat, startMinute: 14 * 60, durationMinutes: 30),
  EasyBlock(id: '9', type: EasyBlockType.activity, startMinute: 14 * 60 + 30, durationMinutes: 45),
  EasyBlock(id: '10', type: EasyBlockType.sleep, startMinute: 16 * 60, durationMinutes: 60),
  EasyBlock(id: '11', type: EasyBlockType.eat, startMinute: 17 * 60 + 30, durationMinutes: 30),
  EasyBlock(id: '12', type: EasyBlockType.activity, startMinute: 18 * 60, durationMinutes: 30),
  EasyBlock(id: '13', type: EasyBlockType.eat, startMinute: 19 * 60, durationMinutes: 30),
  EasyBlock(id: '14', type: EasyBlockType.sleep, startMinute: 20 * 60, durationMinutes: 600),
];
