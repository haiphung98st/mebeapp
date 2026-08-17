import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/bunny_header.dart';
import '../../../shared/models/sound_memory.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/baby_provider.dart';
import '../../../shared/providers/subscription_provider.dart';
import '../data/voice_provider.dart';

const _gradientSound = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF7DE8C8), Color(0xFF34A880)],
);

class SoundscapeScreen extends ConsumerStatefulWidget {
  const SoundscapeScreen({super.key});

  @override
  ConsumerState<SoundscapeScreen> createState() => _SoundscapeScreenState();
}

class _SoundscapeScreenState extends ConsumerState<SoundscapeScreen> {
  final _recorder = AudioRecorder();
  bool _isRecording = false;
  bool _uploading = false;
  int _elapsedSeconds = 0;
  String? _selectedType = 'laugh';
  String? _playingId;
  final _players = <String, AudioPlayer>{};

  static const _soundTypes = [
    ('laugh', '😂', 'Tiếng cười'),
    ('babble', '🗣️', 'Bi bô'),
    ('first_word', '💬', 'Từ đầu tiên'),
    ('cry', '😢', 'Tiếng khóc'),
    ('other', '🎵', 'Khác'),
  ];

  @override
  void dispose() {
    _recorder.dispose();
    for (final p in _players.values) {
      p.dispose();
    }
    super.dispose();
  }

  Future<void> _startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) return;
    final path =
        '${Directory.systemTemp.path}/sound_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
    setState(() {
      _isRecording = true;
      _elapsedSeconds = 0;
    });
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stop();
    setState(() => _isRecording = false);
    if (path == null) return;

    final title = await _showTitleDialog();
    if (title == null || !mounted) return;

    await _upload(path, title, _elapsedSeconds);
  }

  Future<String?> _showTitleDialog() async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Đặt tên âm thanh'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'VD: Lần đầu gọi mama'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _upload(String filePath, String title, int duration) async {
    setState(() => _uploading = true);
    final user = ref.read(currentUserProvider);
    final baby = ref.read(activeBabyProvider);
    if (user == null || baby == null) {
      setState(() => _uploading = false);
      return;
    }

    try {
      final id = const Uuid().v4();
      final storagePath = 'soundscape/${user.uid}/${baby.id}/$id.m4a';
      final ref_ = FirebaseStorage.instance.ref(storagePath);
      await ref_.putFile(File(filePath));
      final url = await ref_.getDownloadURL();

      final memory = SoundMemory(
        id: id,
        babyId: baby.id,
        userId: user.uid,
        type: _selectedType ?? 'other',
        titleVi: title,
        audioUrl: url,
        durationSeconds: duration,
        recordedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );
      await saveSoundMemory(user.uid, baby.id, memory);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
    if (mounted) setState(() => _uploading = false);
  }

  Future<void> _togglePlay(SoundMemory memory) async {
    if (_playingId == memory.id) {
      await _players[memory.id]?.stop();
      setState(() => _playingId = null);
      return;
    }

    // Stop current
    if (_playingId != null) {
      await _players[_playingId!]?.stop();
    }

    _players[memory.id] ??= AudioPlayer();
    await _players[memory.id]!.setUrl(memory.audioUrl);
    await _players[memory.id]!.play();
    setState(() => _playingId = memory.id);

    _players[memory.id]!.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (mounted) setState(() => _playingId = null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final memories = ref.watch(soundMemoriesProvider).value ?? [];
    final isPremium = ref.watch(isPremiumProvider);
    final user = ref.watch(currentUserProvider);
    final baby = ref.watch(activeBabyProvider);

    return Scaffold(
      backgroundColor: AppColors.powder,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: BunnyHeader(
              gradient: _gradientSound,
              earLeftColor: AppColors.mint,
              earRightColor: AppColors.mintLight,
              title: 'Âm thanh kỷ niệm 🎵',
              subtitle: '${memories.length} âm thanh',
              actions: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => context.pop(),
              ),
            ),
          ),

          if (!isPremium)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: _PremiumGate(
                  onUpgrade: () => context.push('/home/subscription'),
                ),
              ),
            )
          else ...[
            // Type selector
            SliverToBoxAdapter(
              child: SizedBox(
                height: 52,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 8, AppSpacing.lg, 0),
                  children: _soundTypes.map((t) {
                    final selected = _selectedType == t.$1;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedType = t.$1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.mint : AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected ? AppColors.mint : AppColors.divider,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(t.$2),
                            const SizedBox(width: 4),
                            Text(
                              t.$3,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: selected ? Colors.white : AppColors.body,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Record button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: _RecordButton(
                  isRecording: _isRecording,
                  uploading: _uploading,
                  elapsedSeconds: _elapsedSeconds,
                  onStart: _startRecording,
                  onStop: _stopRecording,
                ),
              ),
            ),

            // Sounds grid
            if (memories.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppSpacing.md,
                    crossAxisSpacing: AppSpacing.md,
                    childAspectRatio: 1.3,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _SoundCard(
                      memory: memories[i],
                      isPlaying: _playingId == memories[i].id,
                      onPlay: () => _togglePlay(memories[i]),
                      onFavorite: () async {
                        if (user != null && baby != null) {
                          await toggleFavoriteSoundMemory(
                            user.uid,
                            baby.id,
                            memories[i],
                          );
                        }
                      },
                    ),
                    childCount: memories.length,
                  ),
                ),
              )
            else
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: Center(
                    child: Text(
                      'Chưa có âm thanh nào.\nNhấn nút ghi âm để bắt đầu.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.muted, fontSize: 13),
                    ),
                  ),
                ),
              ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxxl)),
        ],
      ),
    );
  }
}

class _RecordButton extends StatelessWidget {
  const _RecordButton({
    required this.isRecording,
    required this.uploading,
    required this.elapsedSeconds,
    required this.onStart,
    required this.onStop,
  });

  final bool isRecording;
  final bool uploading;
  final int elapsedSeconds;
  final VoidCallback onStart;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          if (uploading)
            const CircularProgressIndicator(color: AppColors.mint)
          else
            GestureDetector(
              onTap: isRecording ? onStop : onStart,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isRecording ? AppColors.error : AppColors.mint,
                  boxShadow: [
                    BoxShadow(
                      color: (isRecording ? AppColors.error : AppColors.mint)
                          .withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            isRecording
                ? '${elapsedSeconds}s — Nhấn để dừng'
                : 'Nhấn để ghi âm',
            style: TextStyle(
              fontSize: 12,
              color: isRecording ? AppColors.error : AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SoundCard extends StatelessWidget {
  const _SoundCard({
    required this.memory,
    required this.isPlaying,
    required this.onPlay,
    required this.onFavorite,
  });

  final SoundMemory memory;
  final bool isPlaying;
  final VoidCallback onPlay;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isPlaying
            ? AppColors.mint.withValues(alpha: 0.1)
            : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPlaying ? AppColors.mint : AppColors.divider,
          width: isPlaying ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.mint.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(memory.typeEmoji, style: const TextStyle(fontSize: 22)),
              const Spacer(),
              GestureDetector(
                onTap: onFavorite,
                child: Icon(
                  memory.isFavorite ? Icons.favorite : Icons.favorite_border,
                  size: 18,
                  color: memory.isFavorite ? AppColors.blossom : AppColors.muted,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            memory.titleVi,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            memory.durationLabel,
            style: const TextStyle(fontSize: 10, color: AppColors.muted),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: onPlay,
            child: Container(
              height: 32,
              decoration: BoxDecoration(
                color: isPlaying ? AppColors.error : AppColors.mint,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  Text(
                    isPlaying ? 'Dừng' : 'Phát',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumGate extends StatelessWidget {
  const _PremiumGate({required this.onUpgrade});

  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFDFFAF2), Color(0xFFBFF5E5)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text('🎵', style: TextStyle(fontSize: 56)),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Âm thanh kỷ niệm',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Lưu giữ tiếng cười, tiếng bi bô của bé.\nCần Premium.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.body),
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton(
            onPressed: onUpgrade,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mint,
            ),
            child: const Text('Nâng cấp Premium ✨'),
          ),
        ],
      ),
    );
  }
}
