import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/widgets/bunny_header.dart';
import '../../../shared/providers/baby_provider.dart';
import '../../../shared/providers/notification_config_provider.dart';
import '../../../shared/providers/vaccine_provider.dart';
import '../../subscription/presentation/premium_gate.dart';
import '../data/motor_provider.dart';
import '../data/teeth_provider.dart';
import '../../wonder_weeks/data/wonder_weeks_data.dart';
import '../../wonder_weeks/data/wonder_weeks_provider.dart';
import '../../../core/constants/who_growth_data.dart';
import '../../../shared/providers/growth_provider.dart';
import 'widgets/add_growth_dialog.dart';
import 'widgets/growth_chart_card.dart';
import 'widgets/growth_stats_row.dart';
import 'widgets/milestones_section.dart';
import 'widgets/vaccine_section.dart';
import 'widgets/who_arc_chart.dart';

class GrowthScreen extends ConsumerStatefulWidget {
  const GrowthScreen({super.key});

  @override
  ConsumerState<GrowthScreen> createState() => _GrowthScreenState();
}

class _GrowthScreenState extends ConsumerState<GrowthScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    ref.listen(upcomingVaccineAlertProvider, (previous, next) {
      if (next == null) return;
      if (previous?.def.key == next.def.key) return;
      if (!ref.read(notificationConfigProvider).vaccineEnabled) return;
      NotificationService.instance.showUpcomingVaccineNotification(next.def.nameVi);
    });

    ref.listen(vaccineViewListProvider, (previous, next) {
      if (!ref.read(notificationConfigProvider).vaccineEnabled) return;
      for (final item in next) {
        if (item.isCompleted) continue;
        final baseId = 4000 + (item.def.key.hashCode.abs() % 1000) * 2;
        final title = '💉 Bé sắp đến lịch tiêm!';
        final body = '${item.def.nameVi} · Ngày ${_formatDmy(item.scheduledDate)}';
        NotificationService.instance.scheduleNotification(
          baseId,
          title,
          body,
          item.scheduledDate.subtract(const Duration(days: 7)),
        );
        NotificationService.instance.scheduleNotification(
          baseId + 1,
          title,
          body,
          item.scheduledDate.subtract(const Duration(days: 1)),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.powder,
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              backgroundColor: AppColors.mint,
              onPressed: () => showDialog(
                context: context,
                builder: (context) => const AddGrowthDialog(),
              ),
              child: const Icon(Icons.add),
            )
          : null,
      body: Column(
        children: [
          BunnyHeader(
            gradient: AppColors.gradientGrowth,
            earLeftColor: AppColors.growthEarLeft,
            earRightColor: AppColors.growthEarRight,
            title: 'Phát triển',
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.lg),
              child: _GrowthSegmentedTabs(
                selectedIndex: _selectedIndex,
                onTap: (index) => setState(() => _selectedIndex = index),
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        final baby = ref.watch(activeBabyProvider);
        final latest = ref.watch(latestGrowthProvider);
        final ageMonths = (baby != null && latest != null)
            ? ageInMonthsAt(baby.dateOfBirth, latest.measuredAt)
            : null;
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xxxl,
          ),
          child: Column(
            children: [
              const GrowthStatsRow(),
              const SizedBox(height: AppSpacing.lg),
              if (ageMonths != null && latest != null)
                ...GrowthMetric.values.map((metric) {
                  final value = valueForMetric(latest, metric);
                  if (value == null) return const SizedBox.shrink();
                  final percentile = WhoGrowthStandard.percentileFor(
                      metric, ageMonths, value);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: WhoArcChartCard(
                      metric: metric,
                      value: value,
                      percentile: percentile,
                      ageMonths: ageMonths,
                    ),
                  );
                }),
              const GrowthChartCard(),
              const SizedBox(height: AppSpacing.lg),
              _TeethQuickCard(onTap: () => context.push('/home/growth/teeth')),
              const SizedBox(height: AppSpacing.sm),
              _MotorQuickCard(onTap: () => context.push('/home/growth/motor')),
              const SizedBox(height: AppSpacing.sm),
              _PrenatalQuickCard(onTap: () => context.push('/prenatal')),
            ],
          ),
        );
      case 1:
        return const MilestonesSection();
      case 2:
        return const Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: PremiumGate(feature: 'vaccine_schedule', child: VaccineSection()),
        );
      default:
        return const _WonderWeeksTab();
    }
  }
}

String _formatDmy(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

class _WonderWeeksTab extends ConsumerWidget {
  const _WonderWeeksTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baby = ref.watch(activeBabyProvider);
    final allStates = ref.watch(wonderWeeksAllStatesProvider);
    final currentWeek = ref.watch(wonderWeeksCurrentWeekProvider);
    final currentLeap = ref.watch(wonderWeeksCurrentLeapProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xxxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WwSummaryCard(
            currentWeek: currentWeek,
            currentLeap: currentLeap,
            hasEdd: baby?.edd != null,
          ),
          const SizedBox(height: AppSpacing.lg),
          ...allStates.take(5).map(
                (state) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _WwMiniCard(
                    state: state,
                    onTap: () => context.push(
                      '/home/growth/wonder-weeks/leap',
                      extra: state.leap,
                    ),
                  ),
                ),
              ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () => context.push('/home/growth/wonder-weeks'),
            icon: const Icon(Icons.auto_awesome, color: Color(0xFF7B5AAA)),
            label: const Text('Xem tất cả 10 Leap'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF7B5AAA),
              side: const BorderSide(color: Color(0xFF7B5AAA)),
            ),
          ),
        ],
      ),
    );
  }
}

class _WwSummaryCard extends StatelessWidget {
  const _WwSummaryCard({
    required this.currentWeek,
    required this.currentLeap,
    required this.hasEdd,
  });

  final int currentWeek;
  final LeapData? currentLeap;
  final bool hasEdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7B5AAA), Color(0xFF5B3A8A)],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🧠', style: TextStyle(fontSize: 28)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wonder Weeks · Tuần $currentWeek',
                      style: AppTextStyles.bodyMd.copyWith(color: const Color(0xFFEEE0FF)),
                    ),
                    Text(
                      currentLeap != null
                          ? 'Đang ở Leap ${currentLeap!.number}: ${currentLeap!.name}'
                          : 'Giai đoạn bình yên ☀️',
                      style: AppTextStyles.headingSm.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!hasEdd) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Thêm ngày dự sinh để tính chính xác hơn',
              style: AppTextStyles.bodySm.copyWith(color: const Color(0xFFEEE0FF)),
            ),
          ],
        ],
      ),
    );
  }
}

class _WwMiniCard extends StatelessWidget {
  const _WwMiniCard({required this.state, required this.onTap});
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
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF5B3A8A).withOpacity(0.08)
                : AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: isActive
                  ? const Color(0xFF7B5AAA)
                  : AppColors.divider,
            ),
          ),
          child: Row(
            children: [
              Text(
                isDone ? '✓' : '${leap.number}',
                style: TextStyle(
                  color: isDone ? AppColors.success : const Color(0xFF5B3A8A),
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Leap ${leap.number}: ${leap.name}',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: isDone ? AppColors.muted : AppColors.ink,
                  ),
                ),
              ),
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
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    state.status == LeapStatus.stormy ? '⛈️' : '☀️',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              const Icon(Icons.chevron_right, size: 16, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeethQuickCard extends ConsumerWidget {
  const _TeethQuickCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eruptions = ref.watch(teethProvider).value ?? {};
    final count = eruptions.length;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: [
            BoxShadow(
              color: AppColors.mint.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.mintLight,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: const Center(
                child: Text('🦷', style: TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theo dõi răng sữa',
                    style: AppTextStyles.bodyMd.copyWith(color: AppColors.ink),
                  ),
                  Text(
                    '$count / 20 răng đã mọc',
                    style: AppTextStyles.bodySm.copyWith(color: AppColors.muted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

class _MotorQuickCard extends ConsumerWidget {
  const _MotorQuickCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(weeklyMotorSummaryProvider);
    final totalSecs = summary.values.fold<int>(0, (a, b) => a + b);
    final totalMins = totalSecs ~/ 60;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: [
            BoxShadow(
              color: AppColors.mint.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.mintLight,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: const Center(
                child: Text('🐢', style: TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vận động & Nằm sấp',
                    style: AppTextStyles.bodyMd.copyWith(color: AppColors.ink),
                  ),
                  Text(
                    totalMins > 0 ? '$totalMins phút tuần này' : 'Chưa có hoạt động',
                    style: AppTextStyles.bodySm.copyWith(color: AppColors.muted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

class _PrenatalQuickCard extends StatelessWidget {
  const _PrenatalQuickCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: [
            BoxShadow(
              color: AppColors.petal.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.blush,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: const Center(
                child: Text('🤰', style: TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nhật ký thai kỳ',
                    style: AppTextStyles.bodyMd.copyWith(color: AppColors.ink),
                  ),
                  Text(
                    'Ghi chép tuần thai, triệu chứng',
                    style: AppTextStyles.bodySm.copyWith(color: AppColors.muted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

class _GrowthSegmentedTabs extends StatelessWidget {
  const _GrowthSegmentedTabs({required this.selectedIndex, required this.onTap});

  final int selectedIndex;
  final void Function(int) onTap;

  static const _segments = [
    (icon: '📈', label: 'Phát triển'),
    (icon: '🎯', label: 'Mốc phát triển'),
    (icon: '💉', label: 'Tiêm chủng'),
    (icon: '🧠', label: 'Wonder Weeks'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_segments.length, (index) {
        final segment = _segments[index];
        final isActive = index == selectedIndex;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: InkWell(
              onTap: () => onTap(index),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.white : Colors.white24,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(segment.icon, style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 2),
                    Text(
                      segment.label,
                      style: AppTextStyles.label.copyWith(
                        color: isActive ? AppColors.blossom : AppColors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
