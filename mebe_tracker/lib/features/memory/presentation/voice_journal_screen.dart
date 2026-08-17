import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/bunny_header.dart';
import '../../../shared/models/voice_entry.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/baby_provider.dart';
import '../../../shared/providers/subscription_provider.dart';
import '../data/voice_provider.dart';

const _gradientVoice = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF7DE8C8), Color(0xFF34A880)],
);

class VoiceJournalScreen extends ConsumerStatefulWidget {
  const VoiceJournalScreen({super.key});

  @override
  ConsumerState<VoiceJournalScreen> createState() =>
      _VoiceJournalScreenState();
}

class _VoiceJournalScreenState extends ConsumerState<VoiceJournalScreen> {
  final _recorder = AudioRecorder();
  bool _isRecording = false;
  bool _uploading = false;
  int _elapsedSeconds = 0;
  Timer? _timer;
  String? _recordingPath;

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) return;
    final dir = Directory.systemTemp;
    final path = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
    setState(() {
      _isRecording = true;
      _elapsedSeconds = 0;
      _recordingPath = path;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsedSeconds++);
    });
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    final path = await _recorder.stop();
    setState(() => _isRecording = false);
    if (path == null) return;
    await _uploadEntry(path, _elapsedSeconds);
  }

  Future<void> _uploadEntry(String filePath, int duration) async {
    setState(() => _uploading = true);
    final user = ref.read(currentUserProvider);
    final baby = ref.read(activeBabyProvider);
    if (user == null || baby == null) {
      setState(() => _uploading = false);
      return;
    }

    try {
      final id = const Uuid().v4();
      final storagePath = 'voiceJournal/${user.uid}/${baby.id}/$id.m4a';
      final ref_ = FirebaseStorage.instance.ref(storagePath);
      await ref_.putFile(File(filePath));
      final url = await ref_.getDownloadURL();

      final entry = VoiceEntry(
        id: id,
        babyId: baby.id,
        userId: user.uid,
        recordedAt: DateTime.now(),
        durationSeconds: duration,
        audioUrl: url,
        createdAt: DateTime.now(),
        transcriptPending: true,
      );
      await saveVoiceEntry(user.uid, baby.id, entry);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải lên: $e')),
        );
      }
    }
    if (mounted) setState(() => _uploading = false);
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(voiceEntriesProvider).value ?? [];
    final isPremium = ref.watch(isPremiumProvider);

    return Scaffold(
      backgroundColor: AppColors.powder,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: BunnyHeader(
              gradient: _gradientVoice,
              earLeftColor: AppColors.mint,
              earRightColor: AppColors.mintLight,
              title: 'Nhật ký giọng nói 🎙️',
              subtitle: '${entries.length} bản ghi',
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
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: _RecorderCard(
                  isRecording: _isRecording,
                  uploading: _uploading,
                  elapsedSeconds: _elapsedSeconds,
                  onStart: _startRecording,
                  onStop: _stopRecording,
                ),
              ),
            ),

            if (entries.isNotEmpty) ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Các bản ghi (${entries.length})',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.body,
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _EntryTile(entry: entries[i]),
                  childCount: entries.length,
                ),
              ),
            ] else
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: Center(
                    child: Text(
                      'Chưa có bản ghi nào.\nNhấn nút ghi âm bên trên.',
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

class _RecorderCard extends StatelessWidget {
  const _RecorderCard({
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

  String get _timeLabel {
    final m = elapsedSeconds ~/ 60;
    final s = elapsedSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.mint.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          if (isRecording)
            Text(
              _timeLabel,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: AppColors.error,
              ),
            )
          else
            const Text(
              '🎙️',
              style: TextStyle(fontSize: 48),
            ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isRecording ? 'Đang ghi âm...' : 'Ghi nhật ký giọng nói',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isRecording ? AppColors.error : AppColors.body,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (uploading)
            const CircularProgressIndicator(color: AppColors.mint)
          else
            GestureDetector(
              onTap: isRecording ? onStop : onStart,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isRecording ? AppColors.error : AppColors.mint,
                  boxShadow: [
                    BoxShadow(
                      color: (isRecording ? AppColors.error : AppColors.mint)
                          .withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isRecording ? 'Nhấn để dừng' : 'Nhấn để bắt đầu',
            style: const TextStyle(fontSize: 11, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _EntryTile extends ConsumerStatefulWidget {
  const _EntryTile({required this.entry});

  final VoiceEntry entry;

  @override
  ConsumerState<_EntryTile> createState() => _EntryTileState();
}

class _EntryTileState extends ConsumerState<_EntryTile> {
  final _player = AudioPlayer();
  bool _playing = false;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_playing) {
      await _player.stop();
      setState(() => _playing = false);
    } else {
      await _player.setUrl(widget.entry.audioUrl);
      await _player.play();
      setState(() => _playing = true);
      _player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          if (mounted) setState(() => _playing = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 4,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.mint.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: _togglePlay,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.mint.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _playing
                      ? Icons.stop_rounded
                      : Icons.play_arrow_rounded,
                  color: AppColors.mint,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.displayTitle,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        e.durationLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.muted,
                        ),
                      ),
                      if (e.transcriptPending) ...[
                        const SizedBox(width: 6),
                        const Text(
                          'Đang phân tích...',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.lavender,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (e.transcriptText != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      e.transcriptText!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.body,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Text(
              '${e.recordedAt.day}/${e.recordedAt.month}',
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
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
          const Text('🎙️', style: TextStyle(fontSize: 56)),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Nhật ký giọng nói',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Ghi lại cảm xúc của mẹ bằng giọng nói.\nAI sẽ tự động chuyển thành văn bản.',
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
