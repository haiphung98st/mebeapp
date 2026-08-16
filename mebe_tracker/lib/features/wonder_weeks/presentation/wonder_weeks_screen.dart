import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/providers/baby_provider.dart';
import '../data/wonder_weeks_data.dart';
import '../data/wonder_weeks_provider.dart';

class WonderWeeksScreen extends ConsumerWidget {
  const WonderWeeksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baby = ref.watch(activeBabyProvider);
    final allStates = ref.watch(wonderWeeksAllStatesProvider);
    final currentWeek = ref.watch(wonderWeeksCurrentWeekProvider);
    final currentLeap = ref.watch(wonderWeeksCurrentLeapProvider);
    final nextLeap = ref.watch(wonderWeeksNextLeapProvider);

    return Scaffold(
      backgroundColor: AppColors.powder,
      appBar: AppBar(
        title: const Text('Wonder Weeks'),
        backgroundColor: const Color(0xFF7B5AAA),
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _WonderWeeksHeader(
              currentWeek: currentWeek,
              currentLeap: currentLeap,
              nextLeap: nextLeap,
              hasEdd: baby?.edd != null,
              babyName: baby?.name ?? 'bé',
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xxxl,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final state = allStates[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _LeapCard(
                      state: state,
                      onTap: () => context.push(
                        '/home/growth/wonder-weeks/leap',
                        extra: state.leap,
                      ),
                    ),
                  );
                },
                childCount: allStates.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WonderWeeksHeader extends StatelessWidget {
  const _WonderWeeksHeader({
    required this.currentWeek,
    required this.currentLeap,
    required this.nextLeap,
    required this.hasEdd,
    required this.babyName,
  });

  final int currentWeek;
  final LeapData? currentLeap;
  final LeapData? nextLeap;
  final bool hasEdd;
  final String babyName;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7B5AAA), Color(0xFF5B3A8A)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.xl,
        AppSpacing.xxl,
        AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🧠', style: TextStyle(fontSize: 32)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tuần ${currentWeek} từ dự sinh',
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.lilac,
                      ),
                    ),
                    Text(
                      _headerTitle(),
                      style: AppTextStyles.headingLg.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!hasEdd) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.lilac, size: 16),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Thêm ngày dự sinh để tính Wonder Weeks chính xác hơn',
                      style: AppTextStyles.bodySm.copyWith(color: AppColors.lilac),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (currentLeap != null) ...[
            const SizedBox(height: AppSpacing.lg),
            _StormBanner(leap: currentLeap!),
          ] else if (nextLeap != null) ...[
            const SizedBox(height: AppSpacing.lg),
            _NextLeapBanner(leap: nextLeap!, currentWeek: currentWeek),
          ],
        ],
      ),
    );
  }

  String _headerTitle() {
    if (currentLeap != null) return 'Đang ở Leap ${currentLeap!.number}';
    if (nextLeap != null) return 'Giai đoạn bình yên';
    return 'Qua tất cả các Leap!';
  }
}

class _StormBanner extends StatelessWidget {
  const _StormBanner({required this.leap});
  final LeapData leap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.lilac.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Text('⛈️', style: TextStyle(fontSize: 24)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Leap ${leap.number}: ${leap.name}',
                  style: AppTextStyles.bodyLg.copyWith(color: AppColors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tuần ${leap.stormStartWeek}–${leap.sunnyEndWeek} · Bé đang trải qua giai đoạn phát triển mới',
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.lilac),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NextLeapBanner extends StatelessWidget {
  const _NextLeapBanner({required this.leap, required this.currentWeek});
  final LeapData leap;
  final int currentWeek;

  @override
  Widget build(BuildContext context) {
    final weeksUntil = leap.stormStartWeek - currentWeek;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          const Text('☀️', style: TextStyle(fontSize: 24)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Leap ${leap.number} sau $weeksUntil tuần nữa',
                  style: AppTextStyles.bodyLg.copyWith(color: AppColors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  leap.name,
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.lilac),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LeapCard extends StatelessWidget {
  const _LeapCard({required this.state, required this.onTap});

  final LeapState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final leap = state.leap;
    final isActive = state.status == LeapStatus.stormy || state.status == LeapStatus.sunny;
    final isDone = state.status == LeapStatus.done;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF5B3A8A).withOpacity(0.08)
                : AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: isActive ? const Color(0xFF7B5AAA) : AppColors.divider,
              width: isActive ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              _LeapBadge(
                number: leap.number,
                status: state.status,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Leap ${leap.number}',
                          style: AppTextStyles.bodyLg.copyWith(
                            color: isDone
                                ? AppColors.muted
                                : const Color(0xFF5B3A8A),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        if (isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: state.status == LeapStatus.stormy
                                  ? AppColors.warning.withOpacity(0.15)
                                  : AppColors.mint.withOpacity(0.15),
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusFull),
                            ),
                            child: Text(
                              state.status == LeapStatus.stormy
                                  ? '⛈️ Bão'
                                  : '☀️ Nắng',
                              style: AppTextStyles.label.copyWith(
                                color: state.status == LeapStatus.stormy
                                    ? AppColors.warning
                                    : AppColors.success,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      leap.name,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: isDone ? AppColors.muted : AppColors.ink,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tuần ${leap.stormStartWeek}–${leap.sunnyEndWeek}',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDone ? AppColors.muted : const Color(0xFF7B5AAA),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeapBadge extends StatelessWidget {
  const _LeapBadge({required this.number, required this.status});
  final int number;
  final LeapStatus status;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String icon;
    switch (status) {
      case LeapStatus.stormy:
        bg = AppColors.warning.withOpacity(0.15);
        fg = AppColors.warning;
        icon = '⛈️';
        break;
      case LeapStatus.sunny:
        bg = AppColors.mint.withOpacity(0.15);
        fg = AppColors.success;
        icon = '☀️';
        break;
      case LeapStatus.done:
        bg = AppColors.mintLight;
        fg = AppColors.success;
        icon = '✓';
        break;
      default:
        bg = AppColors.lilac;
        fg = const Color(0xFF5B3A8A);
        icon = number.toString();
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: status == LeapStatus.done
            ? Icon(Icons.check_circle_rounded, color: fg, size: 24)
            : status == LeapStatus.beforeFirst
                ? Text(
                    number.toString(),
                    style: TextStyle(
                      color: fg,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  )
                : Text(icon, style: const TextStyle(fontSize: 20)),
      ),
    );
  }
}
