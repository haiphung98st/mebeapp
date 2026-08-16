import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../data/achievement_data.dart';
import '../data/achievement_provider.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementState = ref.watch(achievementNotifierProvider);
    final unlocked = achievementState.unlocked;

    final categories = AchievementCategory.values;

    return Scaffold(
      backgroundColor: AppColors.powder,
      appBar: AppBar(
        title: const Text('Thành tích'),
        backgroundColor: AppColors.blossom,
        foregroundColor: AppColors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Center(
              child: Text(
                '${unlocked.length}/${allAchievements.length}',
                style: AppTextStyles.bodyLg.copyWith(color: AppColors.white),
              ),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _ProgressHeader(
              unlocked: unlocked.length,
              total: allAchievements.length,
            ),
          ),
          ...categories.map((cat) {
            final catAchievements =
                allAchievements.where((a) => a.category == cat).toList();
            return _CategorySection(
              category: cat,
              achievements: catAchievements,
              unlocked: unlocked,
            );
          }),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.xxxl),
          ),
        ],
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.unlocked, required this.total});
  final int unlocked;
  final int total;

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : unlocked / total;
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.blossom, Color(0xFFD94F8A)],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🏆', style: TextStyle(fontSize: 32)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$unlocked / $total thành tích',
                      style: AppTextStyles.headingMd
                          .copyWith(color: AppColors.white),
                    ),
                    Text(
                      _motivationText(pct),
                      style: AppTextStyles.bodySm.copyWith(color: AppColors.blush),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(AppColors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  String _motivationText(double pct) {
    if (pct == 0) return 'Bắt đầu hành trình của bạn!';
    if (pct < 0.25) return 'Một khởi đầu tuyệt vời!';
    if (pct < 0.5) return 'Bạn đang tiến bộ rất tốt!';
    if (pct < 0.75) return 'Hơn nửa chặng đường rồi!';
    if (pct < 1.0) return 'Sắp hoàn thành! Cố lên!';
    return '🎉 Bạn đã mở khóa tất cả thành tích!';
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.category,
    required this.achievements,
    required this.unlocked,
  });

  final AchievementCategory category;
  final List<AchievementDef> achievements;
  final Set<String> unlocked;

  @override
  Widget build(BuildContext context) {
    final unlockedCount = achievements.where((a) => unlocked.contains(a.id)).length;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  _categoryIcon(category),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  _categoryName(category),
                  style: AppTextStyles.bodyLg.copyWith(color: AppColors.ink),
                ),
                const Spacer(),
                Text(
                  '$unlockedCount/${achievements.length}',
                  style: AppTextStyles.bodySm,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.85,
                crossAxisSpacing: AppSpacing.sm,
                mainAxisSpacing: AppSpacing.sm,
              ),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final ach = achievements[index];
                final isUnlocked = unlocked.contains(ach.id);
                return _AchievementBadge(
                  achievement: ach,
                  isUnlocked: isUnlocked,
                  onShare: isUnlocked ? () => _share(context, ach) : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _share(BuildContext context, AchievementDef ach) {
    Share.share(
      '🏆 Tôi vừa mở khóa thành tích "${ach.name}" ${ach.icon} trên MeBé Tracker!\n\n'
      '${ach.description}\n\n'
      'Tải MeBé Tracker để theo dõi hành trình cùng bé yêu 🐰',
      subject: 'MeBé Tracker — ${ach.name}',
    );
  }

  String _categoryName(AchievementCategory cat) {
    switch (cat) {
      case AchievementCategory.feeding:
        return 'Cho bú';
      case AchievementCategory.sleep:
        return 'Giấc ngủ';
      case AchievementCategory.diaper:
        return 'Thay tã';
      case AchievementCategory.pumping:
        return 'Hút sữa';
      case AchievementCategory.growth:
        return 'Phát triển';
      case AchievementCategory.app:
        return 'Dùng app';
      case AchievementCategory.special:
        return 'Đặc biệt';
    }
  }

  String _categoryIcon(AchievementCategory cat) {
    switch (cat) {
      case AchievementCategory.feeding:
        return '🍼';
      case AchievementCategory.sleep:
        return '🌙';
      case AchievementCategory.diaper:
        return '🌸';
      case AchievementCategory.pumping:
        return '🥛';
      case AchievementCategory.growth:
        return '📈';
      case AchievementCategory.app:
        return '📱';
      case AchievementCategory.special:
        return '⭐';
    }
  }
}

class _AchievementBadge extends StatelessWidget {
  const _AchievementBadge({
    required this.achievement,
    required this.isUnlocked,
    this.onShare,
  });

  final AchievementDef achievement;
  final bool isUnlocked;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUnlocked
          ? () => _showDetail(context)
          : () => _showLocked(context),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: isUnlocked ? AppColors.white : AppColors.divider.withOpacity(0.5),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isUnlocked
                ? _tierColor(achievement.tier).withOpacity(0.4)
                : AppColors.divider,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: _tierColor(achievement.tier).withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Text(
                  isUnlocked ? achievement.icon : '🔒',
                  style: TextStyle(
                    fontSize: 28,
                    color: isUnlocked ? null : Colors.transparent,
                  ),
                ),
                if (!isUnlocked)
                  Positioned.fill(
                    child: Center(
                      child: Text(
                        '🔒',
                        style: TextStyle(
                          fontSize: 28,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                if (isUnlocked)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _tierColor(achievement.tier),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              achievement.name,
              style: AppTextStyles.label.copyWith(
                color: isUnlocked ? AppColors.ink : AppColors.muted,
                fontSize: 9,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Color _tierColor(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.bronze:
        return const Color(0xFFCD7F32);
      case AchievementTier.silver:
        return const Color(0xFFC0C0C0);
      case AchievementTier.gold:
        return const Color(0xFFFFD700);
      case AchievementTier.platinum:
        return const Color(0xFFE5E4E2);
    }
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _AchievementSheet(
        achievement: achievement,
        onShare: onShare,
      ),
    );
  }

  void _showLocked(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${achievement.description}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _AchievementSheet extends StatelessWidget {
  const _AchievementSheet({required this.achievement, this.onShare});
  final AchievementDef achievement;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(achievement.icon, style: const TextStyle(fontSize: 52)),
            const SizedBox(height: AppSpacing.md),
            Text(
              achievement.name,
              style: AppTextStyles.headingLg.copyWith(color: AppColors.ink),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              achievement.description,
              style: AppTextStyles.bodyMd,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            _TierBadge(tier: achievement.tier),
            const SizedBox(height: AppSpacing.xl),
            if (onShare != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    onShare!();
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Chia sẻ thành tích'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blossom,
                    foregroundColor: AppColors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TierBadge extends StatelessWidget {
  const _TierBadge({required this.tier});
  final AchievementTier tier;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (tier) {
      AchievementTier.bronze => ('Đồng', const Color(0xFFCD7F32)),
      AchievementTier.silver => ('Bạc', const Color(0xFF888888)),
      AchievementTier.gold => ('Vàng', const Color(0xFFB8860B)),
      AchievementTier.platinum => ('Bạch Kim', const Color(0xFF666666)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        'Huy hiệu $label',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
