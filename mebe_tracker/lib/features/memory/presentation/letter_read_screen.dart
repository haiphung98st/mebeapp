import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/models/future_letter.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/baby_provider.dart';
import '../data/letter_provider.dart';

class LetterReadScreen extends ConsumerStatefulWidget {
  const LetterReadScreen({super.key, required this.letter});

  final FutureLetter letter;

  @override
  ConsumerState<LetterReadScreen> createState() => _LetterReadScreenState();
}

class _LetterReadScreenState extends ConsumerState<LetterReadScreen> {
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    if (widget.letter.isUnlocked && !widget.letter.isOpened) {
      _markOpened();
    }
  }

  Future<void> _markOpened() async {
    final user = ref.read(currentUserProvider);
    final baby = ref.read(activeBabyProvider);
    if (user == null || baby == null) return;
    await markLetterOpened(user.uid, baby.id, widget.letter.id);
  }

  @override
  Widget build(BuildContext context) {
    final letter = widget.letter;
    final isUnlocked = letter.isUnlocked;

    return Scaffold(
      backgroundColor: const Color(0xFFF5EEFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFA67CD8),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          letter.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: isUnlocked
          ? _OpenedView(letter: letter)
          : _LockedView(
              letter: letter,
              revealed: _revealed,
              onReveal: () => setState(() => _revealed = true),
            ),
    );
  }
}

class _OpenedView extends StatelessWidget {
  const _OpenedView({required this.letter});

  final FutureLetter letter;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          const Text('💌', style: TextStyle(fontSize: 56)),
          const SizedBox(height: AppSpacing.md),
          Text(
            letter.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Gửi ngày ${letter.createdAt.day}/${letter.createdAt.month}/${letter.createdAt.year}',
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.lavender.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              letter.content,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.ink,
                height: 1.8,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.mintLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  letter.isOpened
                      ? 'Đã mở thư này 💕'
                      : 'Thư đã mở khoá',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }
}

class _LockedView extends StatelessWidget {
  const _LockedView({
    required this.letter,
    required this.revealed,
    required this.onReveal,
  });

  final FutureLetter letter;
  final bool revealed;
  final VoidCallback onReveal;

  @override
  Widget build(BuildContext context) {
    final remaining = letter.timeUntilUnlock;
    final days = remaining.inDays;
    final hours = remaining.inHours % 24;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(
                revealed ? '💌' : '🔒',
                key: ValueKey(revealed),
                style: const TextStyle(fontSize: 72),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              letter.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              letter.unlockAgeLabel ?? 'Thư chưa đến thời điểm mở',
              style: const TextStyle(color: AppColors.lavender, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.lilac,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'Còn',
                    style: TextStyle(
                      color: AppColors.lavender,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    days > 0
                        ? '$days ngày $hours giờ'
                        : '$hours giờ',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColors.lavender,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mở khoá: ${letter.unlockDate.day}/${letter.unlockDate.month}/${letter.unlockDate.year}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
