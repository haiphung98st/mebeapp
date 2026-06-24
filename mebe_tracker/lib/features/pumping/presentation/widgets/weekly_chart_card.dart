import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/providers/pump_provider.dart';

const _weekdayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

class WeeklyChartCard extends ConsumerWidget {
  const WeeklyChartCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekly = ref.watch(weeklyPumpSummaryProvider);
    final today = DateTime.now();
    final maxMl = weekly.fold<double>(50, (max, d) => d.totalMl > max ? d.totalMl : max);

    final pastDays = weekly.where((d) => !isSameDay(d.day, today)).toList();
    final avgMl = pastDays.isEmpty
        ? 0.0
        : pastDays.fold<double>(0, (sum, d) => sum + d.totalMl) / pastDays.length;

    final thisWeekTotal = weekly.fold<double>(0, (sum, d) => sum + d.totalMl);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.lavender.withValues(alpha: 0.1),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sữa hút 7 ngày', style: AppTextStyles.headingMd),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 140,
            child: BarChart(
              BarChartData(
                maxY: maxMl * 1.2,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= _weekdayLabels.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(_weekdayLabels[index], style: AppTextStyles.label),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(weekly.length, (index) {
                  final day = weekly[index];
                  final isToday = isSameDay(day.day, today);
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: day.totalMl,
                        width: 18,
                        borderRadius: BorderRadius.circular(6),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: isToday
                              ? [AppColors.lilac, AppColors.lilac.withValues(alpha: 0.6)]
                              : [AppColors.lavender, AppColors.mauve],
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'TB: ${avgMl.toStringAsFixed(0)}ml/ngày · Tổng tuần ${thisWeekTotal.toStringAsFixed(0)}ml',
            style: AppTextStyles.bodySm,
          ),
        ],
      ),
    );
  }
}
