import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/providers/stats_provider.dart';
import 'stat_metric.dart';

class FeedingSummaryCard extends ConsumerWidget {
  const FeedingSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(feedingSummaryProvider);

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
          Text('🍼 Cữ bú', style: AppTextStyles.headingMd),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              StatMetric(label: 'Tổng cữ bú', value: '${summary.totalCount}'),
              StatMetric(label: 'TB cữ/ngày', value: summary.avgPerDay.toStringAsFixed(1)),
              StatMetric(
                label: 'TB thời gian/cữ',
                value: '${summary.avgDurationPerSession.toStringAsFixed(0)} phút',
              ),
            ],
          ),
          if (summary.totalCount > 0) ...[
            const SizedBox(height: AppSpacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 96,
                  height: 96,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 24,
                      sections: [
                        PieChartSectionData(
                          value: summary.leftRatio,
                          color: AppColors.blossom,
                          showTitle: false,
                          radius: 18,
                        ),
                        PieChartSectionData(
                          value: summary.rightRatio,
                          color: AppColors.lavender,
                          showTitle: false,
                          radius: 18,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tỉ lệ bú trái/phải', style: AppTextStyles.bodySm),
                      const SizedBox(height: AppSpacing.sm),
                      _LegendRow(
                        color: AppColors.blossom,
                        label: 'Trái · ${(summary.leftRatio * 100).toStringAsFixed(0)}%',
                      ),
                      _LegendRow(
                        color: AppColors.lavender,
                        label: 'Phải · ${(summary.rightRatio * 100).toStringAsFixed(0)}%',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Tổng cữ theo ngày', style: AppTextStyles.bodySm),
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
                          color: AppColors.blossom,
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
              child: Text('Chưa có cữ bú nào trong khoảng thời gian này', style: AppTextStyles.bodySm),
            ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.bodySm),
        ],
      ),
    );
  }
}
