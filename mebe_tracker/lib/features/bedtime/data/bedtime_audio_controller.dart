import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';

/// Single shared player for the whole bedtime feature (ambient sounds and
/// lullabies both go through this).
///
/// just_audio_background backs the OS "now playing" session with exactly
/// one active MediaItem-tagged player — giving the sounds screen and the
/// lullaby screen their own AudioPlayer meant two players could end up
/// fighting over that single native session when a user switched screens
/// mid-playback, which crashed the app. Routing both through one instance
/// makes switching from a sound to a lullaby (or back) a plain source
/// swap on the same player instead.
class BedtimeAudioController {
  BedtimeAudioController._() {
    player.playerStateStream.listen((state) {
      // Drive the UI off the actual playback state rather than awaiting
      // play()'s Future — with a MediaItem-tagged (background) source,
      // that Future can take far longer to resolve than audio actually
      // takes to start, which left the loading spinner stuck until a
      // second tap happened to coincide with it finally completing.
      if (state.playing && _pendingTitle != null) {
        debugPrint('[bedtime_audio] playing started for "$_pendingTitle"');
        playingTitle.value = _pendingTitle;
        loadingTitle.value = null;
        _pendingTitle = null;
      }
      if (state.processingState == ProcessingState.completed) {
        playingTitle.value = null;
      }
    });
  }

  static final instance = BedtimeAudioController._();

  final AudioPlayer player = AudioPlayer();
  final ValueNotifier<String?> playingTitle = ValueNotifier(null);
  final ValueNotifier<String?> loadingTitle = ValueNotifier(null);
  String? _pendingTitle;

  /// Toggles [title]: stops it if already playing, otherwise stops
  /// whatever else is playing and starts this one.
  Future<void> toggle({
    required String title,
    required String audioUrl,
    required String album,
    required bool loop,
  }) async {
    if (playingTitle.value == title) {
      await player.stop();
      playingTitle.value = null;
      return;
    }

    if (playingTitle.value != null) {
      await player.stop();
      playingTitle.value = null;
    }

    loadingTitle.value = title;
    _pendingTitle = title;
    final sw = Stopwatch()..start();
    try {
      final file = await _cachedFile(audioUrl);
      debugPrint('[bedtime_audio] "$title" file ready at ${sw.elapsedMilliseconds}ms');
      await player.setAudioSource(AudioSource.uri(
        Uri.file(file.path),
        tag: MediaItem(id: title, album: album, title: title),
      ));
      debugPrint('[bedtime_audio] "$title" source set at ${sw.elapsedMilliseconds}ms');
      await player.setLoopMode(loop ? LoopMode.one : LoopMode.off);
      // Fire-and-forget: UI feedback comes from playerStateStream above,
      // not from this Future, since it can lag the real playback state.
      unawaited(player.play().then((_) {
        debugPrint('[bedtime_audio] "$title" play() future resolved at ${sw.elapsedMilliseconds}ms');
      }));
    } catch (e) {
      debugPrint('[bedtime_audio] "$title" failed at ${sw.elapsedMilliseconds}ms: $e');
      loadingTitle.value = null;
      _pendingTitle = null;
      rethrow;
    }
  }

  /// Downloads [url] to a plain on-disk cache once, then reuses the local
  /// file on every later play — the first play of a track pays the network
  /// cost, every one after is instant. Writes to a `.part` file and renames
  /// only once fully written, so a play interrupted mid-download never
  /// leaves a corrupt file behind that a later attempt would treat as cached.
  Future<File> _cachedFile(String url) async {
    final dir = await getTemporaryDirectory();
    final cacheDir = Directory('${dir.path}/bedtime_audio');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    final file = File('${cacheDir.path}/${_cacheFileName(url)}');
    if (await file.exists() && await file.length() > 0) {
      debugPrint('[bedtime_audio] cache HIT: ${file.path}');
      return file;
    }
    debugPrint('[bedtime_audio] cache MISS, downloading: $url');

    final request = await HttpClient().getUrl(Uri.parse(url));
    final response = await request.close();
    if (response.statusCode != 200) {
      throw Exception('Tải âm thanh thất bại (HTTP ${response.statusCode})');
    }
    final chunks = await response.toList();
    final bytes = chunks.expand((chunk) => chunk).toList();

    final partial = File('${file.path}.part');
    await partial.writeAsBytes(bytes);
    await partial.rename(file.path);
    return file;
  }

  String _cacheFileName(String url) {
    final path = Uri.parse(url).path;
    final decoded = Uri.decodeComponent(path.split('/').last);
    return decoded.replaceAll('/', '_');
  }
}
