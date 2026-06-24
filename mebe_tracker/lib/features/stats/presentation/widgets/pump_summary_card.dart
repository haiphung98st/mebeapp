import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/providers/stats_provider.dart';
import 'stat_metric.dart';

class PumpSummaryCard extends ConsumerWidget {
  const PumpSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(pumpSummaryProvider);

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
          Text('🥛 Hút sữa', style: AppTextStyles.headingMd),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              StatMetric(label: 'Tổng ml', value: summary.totalMl.toStringAsFixed(0)),
              StatMetric(label: 'TB ml/ngày', value: summary.avgMlPerDay.toStringAsFixed(0)),
              StatMetric(label: 'Số phiên', value: '${summary.sessionCount}'),
            ],
          ),
          if (summary.sessionCount > 0) ...[
            const SizedBox(height: AppSpacing.lg),
            Text('Sản lượng theo ngày', style: AppTextStyles.bodySm),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 120,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: const FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: summary.dailyMl
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value.value))
                          .toList(),
                      isCurved: true,
                      color: AppColors.lavender,
                      barWidth: 2.5,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(show: true, color: AppColors.lilac.withValues(alpha: 0.4)),
                    ),
                  ],
                ),
              ),
            ),
            if (summary.peakDay != null || summary.lowestDay != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  if (summary.peakDay != null)
                    Expanded(
                      child: Text(
                        'Cao nhất: ${summary.peakDay!.day.day}/${summary.peakDay!.day.month} '
                        '(${summary.peakDay!.value.toStringAsFixed(0)}ml)',
                        style: AppTextStyles.bodySm,
                      ),
                    ),
                ],
              ),
              if (summary.lowestDay != null)
                Text(
                  'Thấp nhất: ${summary.lowestDay!.day.day}/${summary.lowestDay!.day.month} '
                  '(${summary.lowestDay!.value.toStringAsFixed(0)}ml)',
                  style: AppTextStyles.bodySm,
                ),
            ],
          ] else
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Text('Chưa có phiên hút sữa nào trong khoảng thời gian này', style: AppTextStyles.bodySm),
            ),
        ],
      ),
    );
  }
}
