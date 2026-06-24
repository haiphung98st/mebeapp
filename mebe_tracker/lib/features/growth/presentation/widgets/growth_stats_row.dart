import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/who_growth_data.dart';
import '../../../../shared/providers/baby_provider.dart';
import '../../../../shared/providers/growth_provider.dart';

class GrowthStatsRow extends ConsumerWidget {
  const GrowthStatsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baby = ref.watch(activeBabyProvider);
    final latest = ref.watch(latestGrowthProvider);

    return Row(
      children: GrowthMetric.values.map((metric) {
        final value = latest != null ? valueForMetric(latest, metric) : null;
        final percentile = (value != null && baby != null)
            ? WhoGrowthStandard.percentileFor(
                metric,
                ageInMonthsAt(baby.dateOfBirth, latest!.measuredAt),
                value,
              )
            : null;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: _StatCard(metric: metric, value: value, percentile: percentile),
          ),
        );
      }).toList(),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.metric, required this.value, required this.percentile});

  final GrowthMetric metric;
  final double? value;
  final int? percentile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.mint.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(growthMetricIcon(metric), style: const TextStyle(fontSize: 20)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value != null
                ? '${value!.toStringAsFixed(1)} ${growthMetricUnit(metric)}'
                : '—',
            style: AppTextStyles.headingMd,
          ),
          const SizedBox(height: 2),
          Text(
            percentile != null ? 'P$percentile' : growthMetricLabel(metric),
            style: AppTextStyles.bodySm,
          ),
        ],
      ),
    );
  }
}
