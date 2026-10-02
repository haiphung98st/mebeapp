import 'package:cloud_firestore/cloud_firestore.dart';

enum AgeGroup {
  pregnancy,
  months0to12,
  years1to3,
  years3to6;

  String get labelVi => switch (this) {
        AgeGroup.pregnancy => 'Thai kỳ',
        AgeGroup.months0to12 => '0–12 tháng',
        AgeGroup.years1to3 => '1–3 tuổi',
        AgeGroup.years3to6 => '3–6 tuổi',
      };

  String get id => switch (this) {
        AgeGroup.pregnancy => 'pregnancy',
        AgeGroup.months0to12 => '0_12m',
        AgeGroup.years1to3 => '1_3y',
        AgeGroup.years3to6 => '3_6y',
      };

  static AgeGroup? fromId(String id) => switch (id) {
        'pregnancy' => AgeGroup.pregnancy,
        '0_12m' => AgeGroup.months0to12,
        '1_3y' => AgeGroup.years1to3,
        '3_6y' => AgeGroup.years3to6,
        _ => null,
      };
}

enum StoryStatus {
  draft,
  generating,
  ready,
  published,
  failed;

  static StoryStatus fromString(String s) => switch (s) {
        'generating' => StoryStatus.generating,
        'ready' => StoryStatus.ready,
        'published' => StoryStatus.published,
        'failed' => StoryStatus.failed,
        _ => StoryStatus.draft,
      };
}

class BedtimeStory {
  const BedtimeStory({
    required this.id,
    required this.title,
    required this.slug,
    required this.summary,
    required this.categoryId,
    required this.ageGroups,
    required this.tags,
    this.coverPath,
    required this.durationSec,
    required this.paragraphCount,
    required this.isPremium,
    required this.status,
    required this.version,
    this.voiceId,
    this.ttsProvider,
    required this.charCount,
    required this.sortOrder,
    this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
    this.updatedBy,
  });

  final String id;
  final String title;
  final String slug;
  final String summary;
  final String categoryId;
  final List<AgeGroup> ageGroups;
  final List<String> tags;
  final String? coverPath;
  final int durationSec;
  final int paragraphCount;
  final bool isPremium;
  final StoryStatus status;
  final int version;
  final String? voiceId;
  final String? ttsProvider;
  final int charCount;
  final int sortOrder;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? updatedBy;

  String get durationLabel {
    if (durationSec < 60) return '${durationSec}s';
    return '${(durationSec / 60).round()} phút';
  }

  factory BedtimeStory.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return BedtimeStory(
      id: doc.id,
      title: d['title'] as String? ?? '',
      slug: d['slug'] as String? ?? '',
      summary: d['summary'] as String? ?? '',
      categoryId: d['categoryId'] as String? ?? '',
      ageGroups: (d['ageGroups'] as List<dynamic>? ?? [])
          .map((e) => AgeGroup.fromId(e as String))
          .whereType<AgeGroup>()
          .toList(),
      tags: List<String>.from(d['tags'] as List<dynamic>? ?? []),
      coverPath: d['coverPath'] as String?,
      durationSec: (d['durationSec'] as num?)?.toInt() ?? 0,
      paragraphCount: (d['paragraphCount'] as num?)?.toInt() ?? 0,
      isPremium: d['isPremium'] as bool? ?? true,
      status: StoryStatus.fromString(d['status'] as String? ?? 'draft'),
      version: (d['version'] as num?)?.toInt() ?? 1,
      voiceId: d['voiceId'] as String?,
      ttsProvider: d['ttsProvider'] as String?,
      charCount: (d['charCount'] as num?)?.toInt() ?? 0,
      sortOrder: (d['sortOrder'] as num?)?.toInt() ?? 0,
      publishedAt: (d['publishedAt'] as Timestamp?)?.toDate(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedBy: d['updatedBy'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'slug': slug,
        'summary': summary,
        'categoryId': categoryId,
        'ageGroups': ageGroups.map((e) => e.id).toList(),
        'tags': tags,
        'coverPath': coverPath,
        'durationSec': durationSec,
        'paragraphCount': paragraphCount,
        'isPremium': isPremium,
        'status': status.name,
        'version': version,
        'voiceId': voiceId,
        'ttsProvider': ttsProvider,
        'charCount': charCount,
        'sortOrder': sortOrder,
        'publishedAt': publishedAt != null ? Timestamp.fromDate(publishedAt!) : null,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
        'updatedBy': updatedBy,
      };
}

class StoryCategory {
  const StoryCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.iconKey,
    required this.sortOrder,
    required this.isActive,
  });

  final String id;
  final String name;
  final String slug;
  final String iconKey;
  final int sortOrder;
  final bool isActive;

  factory StoryCategory.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return StoryCategory(
      id: doc.id,
      name: d['name'] as String? ?? '',
      slug: d['slug'] as String? ?? '',
      iconKey: d['iconKey'] as String? ?? '',
      sortOrder: (d['sortOrder'] as num?)?.toInt() ?? 0,
      isActive: d['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'slug': slug,
        'iconKey': iconKey,
        'sortOrder': sortOrder,
        'isActive': isActive,
      };
}

class StoryParagraph {
  const StoryParagraph({
    required this.index,
    required this.text,
    this.audioPath,
    this.durationMs,
    this.textHash,
  });

  final int index;
  final String text;
  final String? audioPath;
  final int? durationMs;
  final String? textHash;

  factory StoryParagraph.fromMap(Map<String, dynamic> m) => StoryParagraph(
        index: (m['index'] as num?)?.toInt() ?? 0,
        text: m['text'] as String? ?? '',
        audioPath: m['audioPath'] as String?,
        durationMs: (m['durationMs'] as num?)?.toInt(),
        textHash: m['textHash'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'index': index,
        'text': text,
        'audioPath': audioPath,
        'durationMs': durationMs,
        'textHash': textHash,
      };
}

class StoryContent {
  const StoryContent({
    required this.storyId,
    required this.paragraphs,
    this.fullAudioPath,
  });

  final String storyId;
  final List<StoryParagraph> paragraphs;
  final String? fullAudioPath;

  factory StoryContent.fromFirestore(String storyId, Map<String, dynamic> data) =>
      StoryContent(
        storyId: storyId,
        paragraphs: (data['paragraphs'] as List<dynamic>? ?? [])
            .map((e) => StoryParagraph.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList(),
        fullAudioPath: data['fullAudioPath'] as String?,
      );

  Map<String, dynamic> toFirestore() => {
        'paragraphs': paragraphs.map((p) => p.toMap()).toList(),
        'fullAudioPath': fullAudioPath,
      };
}

class ListeningHistory {
  const ListeningHistory({
    required this.storyId,
    required this.lastParagraphIndex,
    required this.lastPositionMs,
    required this.completed,
    required this.updatedAt,
  });

  final String storyId;
  final int lastParagraphIndex;
  final int lastPositionMs;
  final bool completed;
  final DateTime updatedAt;

  factory ListeningHistory.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return ListeningHistory(
      storyId: doc.id,
      lastParagraphIndex: (d['lastParagraphIndex'] as num?)?.toInt() ?? 0,
      lastPositionMs: (d['lastPositionMs'] as num?)?.toInt() ?? 0,
      completed: d['completed'] as bool? ?? false,
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'lastParagraphIndex': lastParagraphIndex,
        'lastPositionMs': lastPositionMs,
        'completed': completed,
        'updatedAt': Timestamp.fromDate(updatedAt),
      };
}
