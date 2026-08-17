import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/sound_memory.dart';
import '../../../shared/models/voice_entry.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/baby_provider.dart';

final _fs = FirebaseFirestore.instance;

// ── Voice Entries ─────────────────────────────────────────────────────────────

CollectionReference<Map<String, dynamic>> _voiceCol(
        String userId, String babyId) =>
    _fs
        .collection('users')
        .doc(userId)
        .collection('babies')
        .doc(babyId)
        .collection('voiceEntries');

final voiceEntriesProvider = StreamProvider<List<VoiceEntry>>((ref) {
  final user = ref.watch(currentUserProvider);
  final baby = ref.watch(activeBabyProvider);
  if (user == null || baby == null) return Stream.value(const []);
  return _voiceCol(user.uid, baby.id)
      .orderBy('recordedAt', descending: true)
      .limit(30)
      .snapshots()
      .map((s) => s.docs.map(VoiceEntry.fromFirestore).toList());
});

Future<void> saveVoiceEntry(
        String userId, String babyId, VoiceEntry entry) =>
    _voiceCol(userId, babyId).doc(entry.id).set(entry.toFirestore());

Future<void> deleteVoiceEntry(
        String userId, String babyId, String entryId) =>
    _voiceCol(userId, babyId).doc(entryId).delete();

// ── Sound Memories ────────────────────────────────────────────────────────────

CollectionReference<Map<String, dynamic>> _soundCol(
        String userId, String babyId) =>
    _fs
        .collection('users')
        .doc(userId)
        .collection('babies')
        .doc(babyId)
        .collection('soundMemories');

final soundMemoriesProvider = StreamProvider<List<SoundMemory>>((ref) {
  final user = ref.watch(currentUserProvider);
  final baby = ref.watch(activeBabyProvider);
  if (user == null || baby == null) return Stream.value(const []);
  return _soundCol(user.uid, baby.id)
      .orderBy('recordedAt', descending: true)
      .limit(50)
      .snapshots()
      .map((s) => s.docs.map(SoundMemory.fromFirestore).toList());
});

Future<void> saveSoundMemory(
        String userId, String babyId, SoundMemory memory) =>
    _soundCol(userId, babyId).doc(memory.id).set(memory.toFirestore());

Future<void> deleteSoundMemory(
        String userId, String babyId, String memoryId) =>
    _soundCol(userId, babyId).doc(memoryId).delete();

Future<void> toggleFavoriteSoundMemory(
    String userId, String babyId, SoundMemory memory) =>
    _soundCol(userId, babyId).doc(memory.id).update({
      'isFavorite': !memory.isFavorite,
    });
