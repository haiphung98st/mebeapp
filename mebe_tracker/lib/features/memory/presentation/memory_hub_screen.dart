import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
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

    // Compute upcoming monthly milestone for notification card
    String? notifTitle;
    String? notifSub;
    if (baby != null) {
      final now = DateTime.now();
      final ageMonths = (now.year - baby.dateOfBirth.year) * 12 +
          (now.month - baby.dateOfBirth.month);
      final nextMonth = ageMonths + 1;
      final nextDate = DateTime(
        baby.dateOfBirth.year,
        baby.dateOfBirth.month + nextMonth,
        baby.dateOfBirth.day,
      );
      final daysLeft = nextDate.difference(now).inDays;
      if (daysLeft >= 0 && daysLeft <= 14) {
        notifTitle = 'Video tháng thứ $nextMonth của con sắp sẵn sàng';
        notifSub = 'Còn $daysLeft ngày nữa, hãy chuẩn bị ảnh đẹp nhé 🌸';
      }
    }

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
              subtitle: baby != null
                  ? 'Hành trình của ${baby.name}'
                  : 'Hành trình của bé',
              actions: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => context.pop(),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              0,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (!isPremium) ...[
                  _PremiumBanner(
                    onUpgrade: () => context.push('/home/subscription'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                // Notification card for upcoming milestone
                if (notifTitle != null) ...[
                  _NotifCard(title: notifTitle!, subtitle: notifSub!),
                  const SizedBox(height: AppSpacing.md),
                ],

                _FeatureCard(
                  emoji: '📖',
                  label: 'Thẻ kỷ niệm',
                  subtitle: cards.isEmpty
                      ? 'Lưu giữ khoảnh khắc đặc biệt'
                      : '${cards.length} thẻ đã tạo',
                  color: const Color(0xFFFFE4EF),
                  accent: AppColors.blossom,
                  iconBg: const Color(0xFFFFCCE0),
                  isPremium: false,
                  onTap: () => context.push('/memory/story-cards'),
                ),
                const SizedBox(height: AppSpacing.sm),

                _FeatureCard(
                  emoji: '🌈',
                  label: 'Năm đầu đời của con',
                  subtitle: 'Những con số đáng nhớ, gói thành từng trang như story.',
                  color: const Color(0xFFFFF0E8),
                  accent: const Color(0xFFE07800),
                  iconBg: const Color(0xFFFFDEC0),
                  isPremium: true,
                  onTap: () => context.push('/memory/digest'),
                ),
                const SizedBox(height: AppSpacing.sm),

                _FeatureCard(
                  emoji: '👶',
                  label: 'Con lớn lên',
                  subtitle: 'Khuôn mặt con thay đổi qua từng cột mốc, gói trong vài giây.',
                  color: const Color(0xFFE8F5FF),
                  accent: AppColors.info,
                  iconBg: const Color(0xFFBDE4FF),
                  isPremium: true,
                  onTap: () => context.push('/memory/growth-poster'),
                ),
                const SizedBox(height: AppSpacing.sm),

                _FeatureCard(
                  emoji: '🎬',
                  label: 'Video tổng kết',
                  subtitle: 'Tự dựng video có nhạc từ các cột mốc, lưu về máy để gửi cả nhà.',
                  color: const Color(0xFFDFFAF2),
                  accent: AppColors.mint,
                  iconBg: const Color(0xFFB0F0DC),
                  isPremium: true,
                  onTap: () => context.push('/memory/baby-book'),
                ),
                const SizedBox(height: AppSpacing.sm),

                _FeatureCard(
                  emoji: '🚂',
                  label: 'Xem phim hành trình',
                  subtitle: 'Lướt lại từng cột mốc, có nhạc hộp nhạc.',
                  color: const Color(0xFFFFFBE6),
                  accent: const Color(0xFFD4A017),
                  iconBg: const Color(0xFFFFEDA0),
                  isPremium: false,
                  onTap: () => context.push('/memory/milestone-map'),
                ),
                const SizedBox(height: AppSpacing.sm),

                _FeatureCard(
                  emoji: '🖼️',
                  label: 'Ảnh đẹp nhất mỗi tháng',
                  subtitle: 'Ảnh được chọn lọc tự động từ khoảnh khắc của bé.',
                  color: const Color(0xFFF0E8FF),
                  accent: AppColors.lavender,
                  iconBg: const Color(0xFFDDC8FF),
                  isPremium: true,
                  onTap: () => context.push('/memory/story-card/editor'),
                ),
                const SizedBox(height: AppSpacing.sm),

                _FeatureCard(
                  emoji: '💌',
                  label: 'Thư cho tương lai',
                  subtitle: 'Viết thư cho bé đọc khi lớn.',
                  color: const Color(0xFFF0E8FF),
                  accent: AppColors.lavender,
                  iconBg: const Color(0xFFDDC8FF),
                  isPremium: true,
                  onTap: () => context.push('/memory/letters'),
                ),
                const SizedBox(height: AppSpacing.sm),

                _FeatureCard(
                  emoji: '🎙️',
                  label: 'Nhật ký giọng nói',
                  subtitle: 'Ghi âm tâm tư mẹ, nghe lại sau bao năm.',
                  color: const Color(0xFFDFFAF2),
                  accent: AppColors.mint,
                  iconBg: const Color(0xFFB0F0DC),
                  isPremium: true,
                  onTap: () => context.push('/memory/voice-journal'),
                ),
                const SizedBox(height: AppSpacing.sm),

                _FeatureCard(
                  emoji: '📚',
                  label: 'Baby Book PDF',
                  subtitle: 'In kỷ niệm thành cuốn sách bé nhớ mãi.',
                  color: const Color(0xFFFFF0E8),
                  accent: AppColors.mauve,
                  iconBg: const Color(0xFFFFD4BC),
                  isPremium: true,
                  onTap: () => context.push('/memory/baby-book'),
                ),
                const SizedBox(height: AppSpacing.sm),

                _FeatureCard(
                  emoji: '🎁',
                  label: 'Hộp thời gian',
                  subtitle: 'Gửi quà cho bé mở vào một ngày đặc biệt.',
                  color: const Color(0xFFFFE4EF),
                  accent: AppColors.blossom,
                  iconBg: const Color(0xFFFFCCE0),
                  isPremium: true,
                  onTap: () => context.push('/memory/time-capsule'),
                ),
                const SizedBox(height: AppSpacing.sm),

                _FeatureCard(
                  emoji: '✨',
                  label: 'Story Card',
                  subtitle: 'Tạo card đẹp để chia sẻ lên mạng xã hội.',
                  color: const Color(0xFFFFE4EF),
                  accent: AppColors.blossom,
                  iconBg: const Color(0xFFFFCCE0),
                  isPremium: false,
                  onTap: () => context.push('/memory/story-card/editor'),
                ),
                const SizedBox(height: AppSpacing.sm),

                _FeatureCard(
                  emoji: '🗺️',
                  label: 'Bản đồ cột mốc',
                  subtitle: 'Hành trình bé qua từng cột mốc đáng nhớ.',
                  color: const Color(0xFFF0E8FF),
                  accent: AppColors.lavender,
                  iconBg: const Color(0xFFDDC8FF),
                  isPremium: false,
                  onTap: () => context.push('/memory/milestone-map'),
                ),

                const SizedBox(height: AppSpacing.xxxl),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Large list card ──────────────────────────────────────────────────────────

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.emoji,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.accent,
    required this.iconBg,
    required this.isPremium,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final String subtitle;
  final Color color;
  final Color accent;
  final Color iconBg;
  final bool isPremium;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 30)),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: AppTextStyles.headingSm.copyWith(
                            color: accent.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                      if (isPremium) _PremiumChip(accent: accent),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySm.copyWith(
                      color: accent.withValues(alpha: 0.65),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              Icons.chevron_right_rounded,
              color: accent.withValues(alpha: 0.4),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumChip extends StatelessWidget {
  const _PremiumChip({required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        'Premium',
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w800,
          color: accent,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ── Notification/alert card (dashed border) ──────────────────────────────────

class _NotifCard extends StatelessWidget {
  const _NotifCard({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: AppColors.petal,
          width: 1.5,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
      ),
      child: Row(
        children: [
          const Text('⭐', style: TextStyle(fontSize: 28)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.headingSm.copyWith(
                    color: AppColors.blossom,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySm,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Premium upgrade banner ────────────────────────────────────────────────────

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
                Text(
                  'Nâng lên Premium',
                  style: AppTextStyles.headingSm,
                ),
                Text(
                  'Mở khoá tất cả tính năng kỷ niệm',
                  style: AppTextStyles.bodySm,
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
