import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/bunny_header.dart';
import '../../../shared/models/future_letter.dart';
import '../../../shared/providers/subscription_provider.dart';
import '../data/letter_provider.dart';

const _gradientLetters = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFDFC8FF), Color(0xFFA67CD8)],
);

class LettersScreen extends ConsumerWidget {
  const LettersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final letters = ref.watch(futureLettersProvider).value ?? [];
    final isPremium = ref.watch(isPremiumProvider);
    final unlocked = letters.where((l) => l.isUnlocked).toList();
    final locked = letters.where((l) => !l.isUnlocked).toList();

    return Scaffold(
      backgroundColor: AppColors.powder,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: BunnyHeader(
              gradient: _gradientLetters,
              earLeftColor: AppColors.petal,
              earRightColor: AppColors.lilac,
              title: 'Thư cho tương lai 💌',
              subtitle: '${letters.length} lá thư',
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
            if (unlocked.isNotEmpty) ...[
              _SectionHeader(title: 'Đã mở khoá 🔓 (${unlocked.length})'),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _LetterTile(letter: unlocked[i], isUnlocked: true),
                  childCount: unlocked.length,
                ),
              ),
            ],
            if (locked.isNotEmpty) ...[
              _SectionHeader(title: 'Đang khoá 🔒 (${locked.length})'),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _LetterTile(letter: locked[i], isUnlocked: false),
                  childCount: locked.length,
                ),
              ),
            ],
            if (letters.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('💌', style: TextStyle(fontSize: 56)),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        'Chưa có thư nào',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.body,
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        'Viết thư đầu tiên cho bé',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: isPremium
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/memory/letters/write'),
              backgroundColor: AppColors.lavender,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.edit_note_rounded),
              label: const Text('Viết thư'),
            )
          : null,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.sm,
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.body,
          ),
        ),
      ),
    );
  }
}

class _LetterTile extends ConsumerWidget {
  const _LetterTile({required this.letter, required this.isUnlocked});

  final FutureLetter letter;
  final bool isUnlocked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm / 2,
      ),
      child: GestureDetector(
        onTap: () => context.push('/memory/letters/read', extra: letter),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.lavender.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? AppColors.mint.withValues(alpha: 0.2)
                      : AppColors.lilac,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    isUnlocked ? '💌' : '🔒',
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      letter.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isUnlocked
                          ? 'Đã mở — ${letter.unlockDate.day}/${letter.unlockDate.month}/${letter.unlockDate.year}'
                          : 'Mở khoá: ${letter.unlockAgeLabel ?? _dateLabel(letter.unlockDate)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isUnlocked ? AppColors.success : AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _dateLabel(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}';
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
          colors: [Color(0xFFF0E8FF), Color(0xFFFFE4EF)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text('💌', style: TextStyle(fontSize: 56)),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Viết thư cho tương lai',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Gửi yêu thương đến bé trong tương lai.\nMở khoá với Premium.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.body),
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton(
            onPressed: onUpgrade,
            child: const Text('Nâng cấp Premium ✨'),
          ),
        ],
      ),
    );
  }
}
