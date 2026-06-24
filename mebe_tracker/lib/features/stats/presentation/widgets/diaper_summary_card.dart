import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/providers/stats_provider.dart';
import 'stat_metric.dart';

class DiaperSummaryCard extends ConsumerWidget {
  const DiaperSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(diaperSummaryProvider);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [BoxShadow(color: AppColors.divider, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🌸 Thay tã', style: AppTextStyles.headingMd),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              StatMetric(label: 'Tổng lần', value: '${summary.totalCount}'),
              StatMetric(label: 'Ướt', value: '${summary.wetCount}'),
              StatMetric(label: 'Bẩn', value: '${summary.dirtyCount}'),
              StatMetric(label: 'Cả hai', value: '${summary.bothCount}'),
            ],
          ),
          if (summary.totalCount > 0) ...[
            const SizedBox(height: AppSpacing.lg),
            Text('Số lần theo ngày', style: AppTextStyles.bodySm),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 120,
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: const FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  barGroups: summary.dailyCounts.asMap().entries.map((e) {
                    return BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: e.value.value,
                          color: AppColors.mint,
                          width: 10,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Text('Chưa có lần thay tã nào trong khoảng thời gian này', style: AppTextStyles.bodySm),
            ),
        ],
      ),
    );
  }
}
