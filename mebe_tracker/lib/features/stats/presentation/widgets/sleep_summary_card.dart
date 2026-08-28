import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/providers/stats_provider.dart';
import '../../../sleep/presentation/widgets/sleep_history_list.dart';
import 'stat_metric.dart';

class SleepSummaryCard extends ConsumerWidget {
  const SleepSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(sleepSummaryProvider);
    final period = ref.watch(statsRangeTypeProvider);
    final entries = ref.watch(statsSleepsProvider);
    final hasData = summary.totalHours > 0;
    final trendHours = (summary.trendMinutesVsPrevious.abs() / 60);
    final trendArrow = summary.trendMinutesVsPrevious >= 0 ? '↑' : '↓';
    final trendLabel = summary.trendMinutesVsPrevious >= 0 ? 'nhiều hơn' : 'ít hơn';
    final napChart = period == StatsRangeType.year ? bucketByMonth(summary.dailyNapHours) : summary.dailyNapHours;
    final nightChart =
        period == StatsRangeType.year ? bucketByMonth(summary.dailyNightHours) : summary.dailyNightHours;

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
          Text('🌙 Giấc ngủ', style: AppTextStyles.headingMd),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              StatMetric(label: 'Tổng giờ ngủ', value: '${summary.totalHours.toStringAsFixed(1)}h'),
              StatMetric(label: 'TB/ngày', value: '${summary.avgHoursPerDay.toStringAsFixed(1)}h'),
              StatMetric(
                label: 'Đêm/Ngày',
                value: '${(summary.nightRatio * 100).toStringAsFixed(0)}/${(summary.dayRatio * 100).toStringAsFixed(0)}%',
              ),
            ],
          ),
          if (hasData) ...[
            if (period != StatsRangeType.today) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                period == StatsRangeType.year ? 'Giờ ngủ theo tháng' : 'Giờ ngủ theo ngày',
                style: AppTextStyles.bodySm,
              ),
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
                    barGroups: List.generate(napChart.length, (i) {
                      final nap = napChart[i].value;
                      final night = nightChart[i].value;
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: nap + night,
                            width: 10,
                            borderRadius: BorderRadius.circular(4),
                            rodStackItems: [
                              BarChartRodStackItem(0, nap, AppColors.mint),
                              BarChartRodStackItem(nap, nap + night, AppColors.lavender),
                            ],
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  _LegendDot(color: AppColors.mint, label: 'Ngủ ngày'),
                  const SizedBox(width: AppSpacing.md),
                  _LegendDot(color: AppColors.lavender, label: 'Ngủ đêm'),
                ],
              ),
            ],
            if (summary.trendMinutesVsPrevious != 0) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                '$trendArrow Ngủ $trendLabel ${trendHours.toStringAsFixed(1)} giờ so với kỳ trước',
                style: AppTextStyles.bodySm.copyWith(color: AppColors.mauve, fontWeight: FontWeight.w700),
              ),
            ],
            if (entries.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              const Divider(color: AppColors.divider),
              const SizedBox(height: AppSpacing.sm),
              Text(
                entries.length > 20 ? 'Nhật ký (20 gần nhất)' : 'Nhật ký',
                style: AppTextStyles.bodySm,
              ),
              const SizedBox(height: AppSpacing.sm),
              SleepHistoryList(entries: entries.take(20).toList()),
            ],
          ] else
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Text('Chưa có giấc ngủ nào trong khoảng thời gian này', style: AppTextStyles.bodySm),
            ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.bodySm),
      ],
    );
  }
}
