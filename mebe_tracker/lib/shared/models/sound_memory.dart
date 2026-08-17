import 'package:cloud_firestore/cloud_firestore.dart';

class SoundMemory {
  const SoundMemory({
    required this.id,
    required this.babyId,
    required this.userId,
    required this.type,
    required this.titleVi,
    required this.audioUrl,
    required this.durationSeconds,
    required this.recordedAt,
    required this.createdAt,
    this.descriptionVi,
    this.transcriptText,
    this.isFavorite = false,
  });

  final String id;
  final String babyId;
  final String userId;
  final String type; // 'laugh'|'babble'|'first_word'|'cry'|'other'
  final String titleVi;
  final String audioUrl;
  final int durationSeconds;
  final DateTime recordedAt;
  final DateTime createdAt;
  final String? descriptionVi;
  final String? transcriptText;
  final bool isFavorite;

  String get durationLabel {
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    return '${m.toString().padLeft(1, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get typeEmoji => switch (type) {
        'laugh' => '😂',
        'babble' => '🗣️',
        'first_word' => '💬',
        'cry' => '😢',
        _ => '🎵',
      };

  Map<String, dynamic> toFirestore() => {
        'babyId': babyId,
        'userId': userId,
        'type': type,
        'titleVi': titleVi,
        'audioUrl': audioUrl,
        'durationSeconds': durationSeconds,
        'recordedAt': Timestamp.fromDate(recordedAt),
        'createdAt': Timestamp.fromDate(createdAt),
        if (descriptionVi != null) 'descriptionVi': descriptionVi,
        if (transcriptText != null) 'transcriptText': transcriptText,
        'isFavorite': isFavorite,
      };

  factory SoundMemory.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return SoundMemory(
      id: doc.id,
      babyId: d['babyId'] as String,
      userId: d['userId'] as String,
      type: d['type'] as String? ?? 'other',
      titleVi: d['titleVi'] as String? ?? '',
      audioUrl: d['audioUrl'] as String? ?? '',
      durationSeconds: (d['durationSeconds'] as num?)?.toInt() ?? 0,
      recordedAt: (d['recordedAt'] as Timestamp).toDate(),
      createdAt: (d['createdAt'] as Timestamp).toDate(),
      descriptionVi: d['descriptionVi'] as String?,
      transcriptText: d['transcriptText'] as String?,
      isFavorite: d['isFavorite'] as bool? ?? false,
    );
  }

  SoundMemory copyWith({bool? isFavorite}) => SoundMemory(
        id: id,
        babyId: babyId,
        userId: userId,
        type: type,
        titleVi: titleVi,
        audioUrl: audioUrl,
        durationSeconds: durationSeconds,
        recordedAt: recordedAt,
        createdAt: createdAt,
        descriptionVi: descriptionVi,
        transcriptText: transcriptText,
        isFavorite: isFavorite ?? this.isFavorite,
      );
}
