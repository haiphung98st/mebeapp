import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/providers/sleep_provider.dart';

const _weekdayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

class WeeklySleepChart extends ConsumerWidget {
  const WeeklySleepChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyAsync = ref.watch(weeklySleepProvider);

    return weeklyAsync.when(
      data: (weekly) {
        final maxMinutes = weekly.fold<double>(
          60,
          (max, d) => [d.napMinutes, d.nightMinutes, max].reduce((a, b) => a > b ? a : b).toDouble(),
        );

        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            boxShadow: [
              BoxShadow(
                color: AppColors.nightMid.withValues(alpha: 0.1),
                blurRadius: 14,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Giấc ngủ 7 ngày', style: AppTextStyles.headingMd),
                  const Row(
                    children: [
                      _LegendDot(color: AppColors.lavender, label: 'Ngày'),
                      SizedBox(width: AppSpacing.sm),
                      _LegendDot(color: AppColors.nightMid, label: 'Đêm'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                height: 140,
                child: BarChart(
                  BarChartData(
                    maxY: maxMinutes * 1.2,
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
                            if (index < 0 || index >= _weekdayLabels.length) {
                              return const SizedBox.shrink();
                            }
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
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: day.napMinutes.toDouble(),
                            width: 8,
                            borderRadius: BorderRadius.circular(4),
                            color: AppColors.lavender,
                          ),
                          BarChartRodData(
                            toY: day.nightMinutes.toDouble(),
                            width: 8,
                            borderRadius: BorderRadius.circular(4),
                            color: AppColors.nightMid,
                          ),
                        ],
                        barsSpace: 4,
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(height: 140, child: Center(child: CircularProgressIndicator())),
      error: (_, __) => const SizedBox.shrink(),
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
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.bodySm),
      ],
    );
  }
}
