import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/bunny_header.dart';
import '../../../shared/providers/subscription_provider.dart';
import '../data/milestone_map_provider.dart';

const _gradientMilestone = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFDFC8FF), Color(0xFFA67CD8)],
);

class MilestoneMapScreen extends ConsumerWidget {
  const MilestoneMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async_ = ref.watch(milestoneMapProvider);
    final isPremium = ref.watch(isPremiumProvider);

    return Scaffold(
      backgroundColor: AppColors.powder,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: BunnyHeader(
              gradient: _gradientMilestone,
              earLeftColor: AppColors.petal,
              earRightColor: AppColors.lilac,
              title: 'Bản đồ cột mốc 🗺️',
              subtitle: isPremium ? 'Tất cả cột mốc' : '3 cột mốc miễn phí',
              actions: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => context.pop(),
              ),
            ),
          ),

          async_.when(
            loading: () => const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Center(child: Text('Lỗi: $e')),
            ),
            data: (items) {
              final displayItems =
                  isPremium ? items : items.take(3).toList();
              return SliverList(
                delegate: SliverChildListDelegate([
                  if (displayItems.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(AppSpacing.xl),
                      child: Center(
                        child: Column(
                          children: [
                            Text('🗺️', style: TextStyle(fontSize: 56)),
                            SizedBox(height: AppSpacing.md),
                            Text(
                              'Chưa có cột mốc nào',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.body,
                              ),
                            ),
                            SizedBox(height: AppSpacing.sm),
                            Text(
                              'Khi bé đạt thành tích, chúng sẽ hiện ở đây',
                              style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    _TimelineWidget(items: displayItems),
                  if (!isPremium && items.length > 3) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: _UpgradeBanner(
                        remaining: items.length - 3,
                        onUpgrade: () => context.push('/home/subscription'),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xxxl),
                ]),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TimelineWidget extends StatelessWidget {
  const _TimelineWidget({required this.items});

  final List<MilestoneMapItem> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        0,
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isLast = i == items.length - 1;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline line + dot
              Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: item.color, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        item.emoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 48,
                      color: item.color.withValues(alpha: 0.3),
                    ),
                ],
              ),
              const SizedBox(width: AppSpacing.md),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.titleVi,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        if (item.shareText != null)
                          GestureDetector(
                            onTap: () => Share.share(
                              '${item.emoji} ${item.titleVi}\n${item.shareText!}\n\nMeBé ✨',
                            ),
                            child: const Icon(
                              Icons.share_rounded,
                              size: 16,
                              color: AppColors.muted,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.date.day}/${item.date.month}/${item.date.year}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                    ),
                    SizedBox(height: isLast ? 0 : 16),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _UpgradeBanner extends StatelessWidget {
  const _UpgradeBanner({required this.remaining, required this.onUpgrade});

  final int remaining;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.lilac,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lavender, width: 1.5),
      ),
      child: Row(
        children: [
          const Text('🔒', style: TextStyle(fontSize: 22)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              '$remaining cột mốc đang bị khoá',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.lavender,
              ),
            ),
          ),
          TextButton(
            onPressed: onUpgrade,
            style: TextButton.styleFrom(
              backgroundColor: AppColors.lavender,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              textStyle:
                  const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
            ),
            child: const Text('Mở khoá'),
          ),
        ],
      ),
    );
  }
}
