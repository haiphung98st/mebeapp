import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/bedtime_story.dart';
import '../../../shared/providers/auth_provider.dart';

// ── Repository ────────────────────────────────────────────────────────────────

class BedtimeStoryRepository {
  BedtimeStoryRepository(this._db);

  final FirebaseFirestore _db;

  Stream<List<StoryCategory>> watchCategories() => _db
      .collection('bedtime_categories')
      .where('isActive', isEqualTo: true)
      .orderBy('sortOrder')
      .snapshots()
      .map((s) => s.docs.map(StoryCategory.fromFirestore).toList());

  Stream<List<BedtimeStory>> watchPublishedStories() => _db
      .collection('bedtime_stories')
      .where('status', isEqualTo: 'published')
      .orderBy('sortOrder')
      .snapshots()
      .map((s) => s.docs.map(BedtimeStory.fromFirestore).toList());

  Future<StoryContent?> getStoryContent(String storyId) async {
    final snap = await _db
        .collection('bedtime_stories')
        .doc(storyId)
        .collection('content')
        .doc('body')
        .get();
    if (!snap.exists || snap.data() == null) return null;
    return StoryContent.fromFirestore(storyId, snap.data()!);
  }
}

class BedtimeUserRepository {
  BedtimeUserRepository(this._db, this._uid);

  final FirebaseFirestore _db;
  final String _uid;

  CollectionReference<Map<String, dynamic>> get _favCol =>
      _db.collection('users').doc(_uid).collection('bedtime_favorites');

  CollectionReference<Map<String, dynamic>> get _histCol =>
      _db.collection('users').doc(_uid).collection('bedtime_history');

  Stream<List<String>> watchFavoriteIds() => _favCol.snapshots().map(
        (s) => s.docs.map((d) => d.id).toList(),
      );

  Future<void> toggleFavorite(String storyId) async {
    final ref = _favCol.doc(storyId);
    final snap = await ref.get();
    if (snap.exists) {
      await ref.delete();
    } else {
      await ref.set({'addedAt': FieldValue.serverTimestamp()});
    }
  }

  Stream<List<ListeningHistory>> watchHistory() => _histCol
      .orderBy('updatedAt', descending: true)
      .limit(50)
      .snapshots()
      .map((s) => s.docs.map(ListeningHistory.fromFirestore).toList());

  Future<void> upsertHistory(ListeningHistory h) async {
    await _histCol.doc(h.storyId).set(h.toFirestore(), SetOptions(merge: true));
  }
}

// ── Core providers ────────────────────────────────────────────────────────────

final _firestoreProvider = Provider<FirebaseFirestore>(
  (_) => FirebaseFirestore.instance,
);

final bedtimeStoryRepositoryProvider = Provider<BedtimeStoryRepository>((ref) {
  return BedtimeStoryRepository(ref.watch(_firestoreProvider));
});

final bedtimeUserRepositoryProvider = Provider<BedtimeUserRepository?>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) return null;
  return BedtimeUserRepository(ref.watch(_firestoreProvider), uid);
});

// ── Story/category streams ────────────────────────────────────────────────────

final bedtimeCategoriesProvider = StreamProvider<List<StoryCategory>>((ref) {
  return ref.watch(bedtimeStoryRepositoryProvider).watchCategories();
});

final bedtimeAllStoriesProvider = StreamProvider<List<BedtimeStory>>((ref) {
  return ref.watch(bedtimeStoryRepositoryProvider).watchPublishedStories();
});

final storiesByCategoryProvider =
    StreamProvider.family<List<BedtimeStory>, String>((ref, categoryId) {
  return ref.watch(bedtimeAllStoriesProvider.stream).map(
        (list) => list.where((s) => s.categoryId == categoryId).toList(),
      );
});

final storiesByAgeGroupProvider =
    StreamProvider.family<List<BedtimeStory>, AgeGroup>((ref, group) {
  return ref.watch(bedtimeAllStoriesProvider.stream).map(
        (list) =>
            list.where((s) => s.ageGroups.contains(group)).toList(),
      );
});

final searchStoriesProvider =
    Provider.family<List<BedtimeStory>, String>((ref, query) {
  final stories = ref.watch(bedtimeAllStoriesProvider).value ?? [];
  if (query.trim().isEmpty) return stories;
  final norm = _normalize(query.trim().toLowerCase());
  return stories.where((s) {
    return _normalize(s.title.toLowerCase()).contains(norm) ||
        _normalize(s.summary.toLowerCase()).contains(norm) ||
        s.tags.any((t) => _normalize(t.toLowerCase()).contains(norm));
  }).toList();
});

String _normalize(String input) {
  const from =
      'àáảãạăắặẳẵằâấậẩẫầèéẻẽẹêếệểễềìíỉĩịòóỏõọôốộổỗồơớợởỡờùúủũụưứựửữừỳýỷỹỵđ'
      'ÀÁẢÃẠĂẮẶẲẴẰÂẤẬẨẪẦÈÉẺẼẸÊẾỆỂỄỀÌÍỈĨỊÒÓỎÕỌÔỐỘỔỖỒƠỚỢỞỠỜÙÚỦŨỤƯỨỰỬỮỪỲÝỶỸỴĐ';
  const to =
      'aaaaaaaaaaaaaaaaaeeeeeeeeeeeeiiiiioooooooooooooooouuuuuuuuuuuyyyyyd'
      'AAAAAAAAAAAAAAAAAEEEEEEEEEEEEIIIIIOOOOOOOOOOOOOOOOUUUUUUUUUUUYYYYYD';
  final buf = StringBuffer();
  for (final ch in input.runes) {
    final c = String.fromCharCode(ch);
    final idx = from.indexOf(c);
    buf.write(idx >= 0 ? to[idx] : c);
  }
  return buf.toString();
}

// ── User data providers ───────────────────────────────────────────────────────

final bedtimeFavoritesProvider = StreamProvider<List<String>>((ref) {
  final repo = ref.watch(bedtimeUserRepositoryProvider);
  if (repo == null) return Stream.value([]);
  return repo.watchFavoriteIds();
});

final bedtimeHistoryProvider = StreamProvider<List<ListeningHistory>>((ref) {
  final repo = ref.watch(bedtimeUserRepositoryProvider);
  if (repo == null) return Stream.value([]);
  return repo.watchHistory();
});
