import 'package:cloud_firestore/cloud_firestore.dart';

class VoiceEntry {
  const VoiceEntry({
    required this.id,
    required this.babyId,
    required this.userId,
    required this.recordedAt,
    required this.durationSeconds,
    required this.audioUrl,
    required this.createdAt,
    this.transcriptText,
    this.title,
    this.mood,
    this.transcriptPending = false,
  });

  final String id;
  final String babyId;
  final String userId;
  final DateTime recordedAt;
  final int durationSeconds;
  final String audioUrl;
  final DateTime createdAt;
  final String? transcriptText;
  final String? title;
  final String? mood; // 'happy'|'tired'|'grateful'|'worried'|'love'
  final bool transcriptPending;

  String get displayTitle =>
      title ??
      'Ngày ${recordedAt.day}/${recordedAt.month}/${recordedAt.year}';

  String get durationLabel {
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toFirestore() => {
        'babyId': babyId,
        'userId': userId,
        'recordedAt': Timestamp.fromDate(recordedAt),
        'durationSeconds': durationSeconds,
        'audioUrl': audioUrl,
        'createdAt': Timestamp.fromDate(createdAt),
        if (transcriptText != null) 'transcriptText': transcriptText,
        if (title != null) 'title': title,
        if (mood != null) 'mood': mood,
        'transcriptPending': transcriptPending,
      };

  factory VoiceEntry.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return VoiceEntry(
      id: doc.id,
      babyId: d['babyId'] as String,
      userId: d['userId'] as String,
      recordedAt: (d['recordedAt'] as Timestamp).toDate(),
      durationSeconds: (d['durationSeconds'] as num?)?.toInt() ?? 0,
      audioUrl: d['audioUrl'] as String? ?? '',
      createdAt: (d['createdAt'] as Timestamp).toDate(),
      transcriptText: d['transcriptText'] as String?,
      title: d['title'] as String?,
      mood: d['mood'] as String?,
      transcriptPending: d['transcriptPending'] as bool? ?? false,
    );
  }
}
