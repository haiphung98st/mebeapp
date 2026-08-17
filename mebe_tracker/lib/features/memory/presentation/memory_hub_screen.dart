import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/bunny_header.dart';
import '../../../shared/providers/baby_provider.dart';
import '../../../shared/providers/subscription_provider.dart';
import '../data/story_card_provider.dart';

const _gradientMemory = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFFF85B3), Color(0xFFF472A0), Color(0xFFA67CD8)],
  stops: [0.0, 0.55, 1.0],
);

class MemoryHubScreen extends ConsumerWidget {
  const MemoryHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baby = ref.watch(activeBabyProvider);
    final isPremium = ref.watch(isPremiumProvider);
    final cards = ref.watch(storyCardsProvider).value ?? [];

    return Scaffold(
      backgroundColor: AppColors.powder,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: BunnyHeader(
              gradient: _gradientMemory,
              earLeftColor: AppColors.petal,
              earRightColor: AppColors.lilac,
              title: 'Kỷ niệm 💝',
              subtitle: baby != null ? 'Hành trình của ${baby.name}' : 'Hành trình của bé',
              actions: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => context.pop(),
              ),
            ),
          ),

          if (!isPremium)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  0,
                ),
                child: _PremiumBanner(
                  onUpgrade: () => context.push('/home/subscription'),
                ),
              ),
            ),

          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.15,
              ),
              delegate: SliverChildListDelegate([
                _FeatureCell(
                  emoji: '📖',
                  label: 'Thẻ kỷ niệm',
                  subtitle: '${cards.length} thẻ',
                  color: const Color(0xFFFFE4EF),
                  accent: AppColors.blossom,
                  isPremium: false,
                  onTap: () => context.push('/memory/story-cards'),
                ),
                _FeatureCell(
                  emoji: '💌',
                  label: 'Thư cho tương lai',
                  subtitle: 'Viết thư cho bé',
                  color: const Color(0xFFF0E8FF),
                  accent: AppColors.lavender,
                  isPremium: true,
                  onTap: () => context.push('/memory/letters'),
                ),
                _FeatureCell(
                  emoji: '🎙️',
                  label: 'Nhật ký giọng nói',
                  subtitle: 'Ghi âm tâm tư mẹ',
                  color: const Color(0xFFDFFAF2),
                  accent: AppColors.mint,
                  isPremium: true,
                  onTap: () => context.push('/memory/voice-journal'),
                ),
                _FeatureCell(
                  emoji: '🌈',
                  label: 'Tâm trạng theo ngày',
                  subtitle: '30 ngày miễn phí',
                  color: const Color(0xFFFFF8E1),
                  accent: const Color(0xFFD4A017),
                  isPremium: false,
                  onTap: () => context.push('/memory/mood-timeline'),
                ),
                _FeatureCell(
                  emoji: '📊',
                  label: 'Tổng kết tháng',
                  subtitle: 'Nhìn lại hành trình',
                  color: const Color(0xFFFFEDE3),
                  accent: AppColors.peach,
                  isPremium: true,
                  onTap: () => context.push('/memory/digest'),
                ),
                _FeatureCell(
                  emoji: '📏',
                  label: 'Poster phát triển',
                  subtitle: 'Biểu đồ tăng trưởng',
                  color: const Color(0xFFE8F5FF),
                  accent: AppColors.info,
                  isPremium: true,
                  onTap: () => context.push('/memory/growth-poster'),
                ),
                _FeatureCell(
                  emoji: '📚',
                  label: 'Baby Book PDF',
                  subtitle: 'In kỷ niệm',
                  color: const Color(0xFFFFF0E8),
                  accent: AppColors.mauve,
                  isPremium: true,
                  onTap: () => context.push('/memory/baby-book'),
                ),
                _FeatureCell(
                  emoji: '🎁',
                  label: 'Hộp thời gian',
                  subtitle: 'Gửi tương lai',
                  color: const Color(0xFFFFE4EF),
                  accent: AppColors.blossom,
                  isPremium: true,
                  onTap: () => context.push('/memory/time-capsule'),
                ),
                _FeatureCell(
                  emoji: '🗺️',
                  label: 'Bản đồ cột mốc',
                  subtitle: '3 miễn phí',
                  color: const Color(0xFFF0E8FF),
                  accent: AppColors.lavender,
                  isPremium: false,
                  onTap: () => context.push('/memory/milestone-map'),
                ),
                _FeatureCell(
                  emoji: '🎵',
                  label: 'Âm thanh kỷ niệm',
                  subtitle: 'Tiếng cười của bé',
                  color: const Color(0xFFDFFAF2),
                  accent: AppColors.mint,
                  isPremium: true,
                  onTap: () => context.push('/memory/soundscape'),
                ),
              ]),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxxl)),
        ],
      ),
    );
  }
}

class _FeatureCell extends StatelessWidget {
  const _FeatureCell({
    required this.emoji,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.accent,
    required this.isPremium,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final String subtitle;
  final Color color;
  final Color accent;
  final bool isPremium;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 28)),
                const Spacer(),
                if (isPremium)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Premium',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: accent,
                      ),
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: accent.withValues(alpha: 0.85),
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: accent.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumBanner extends StatelessWidget {
  const _PremiumBanner({required this.onUpgrade});

  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE4EF), Color(0xFFF0E8FF)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.petal, width: 1.5),
      ),
      child: Row(
        children: [
          const Text('✨', style: TextStyle(fontSize: 24)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nâng lên Premium',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  'Mở khoá tất cả tính năng kỷ niệm',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.body.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onUpgrade,
            style: TextButton.styleFrom(
              backgroundColor: AppColors.blossom,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            child: const Text('Nâng cấp'),
          ),
        ],
      ),
    );
  }
}
