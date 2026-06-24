import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/who_growth_data.dart';
import '../../../../shared/providers/growth_provider.dart';

class GrowthChartCard extends ConsumerStatefulWidget {
  const GrowthChartCard({super.key});

  @override
  ConsumerState<GrowthChartCard> createState() => _GrowthChartCardState();
}

class _GrowthChartCardState extends ConsumerState<GrowthChartCard> {
  GrowthMetric _metric = GrowthMetric.weight;

  @override
  Widget build(BuildContext context) {
    final points = ref.watch(growthChartDataProvider(_metric));
    final maxAge = points.isEmpty
        ? 6.0
        : (points.last.ageMonths + 2).clamp(6, 24).toDouble();

    final babySpots = points.map((p) => FlSpot(p.ageMonths, p.value)).toList();
    final who50Spots = List.generate(
      (maxAge ~/ 2) + 1,
      (i) => FlSpot((i * 2).toDouble(), WhoGrowthStandard.p50(_metric, (i * 2).toDouble())),
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.mint.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MetricSegmentedTabs(
            selected: _metric,
            onSelected: (metric) => setState(() => _metric = metric),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 200,
            child: babySpots.isEmpty
                ? Center(
                    child: Text('Chưa có dữ liệu đo', style: AppTextStyles.bodyMd),
                  )
                : LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: maxAge,
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) => Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text('${value.toInt()}m', style: AppTextStyles.label),
                            ),
                          ),
                        ),
                      ),
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (spots) => spots.map((s) {
                            return LineTooltipItem(
                              '${s.y.toStringAsFixed(1)} ${growthMetricUnit(_metric)}',
                              AppTextStyles.bodySm.copyWith(color: AppColors.white),
                            );
                          }).toList(),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: who50Spots,
                          isCurved: true,
                          color: AppColors.mint,
                          barWidth: 1.5,
                          dashArray: [6, 4],
                          dotData: const FlDotData(show: false),
                        ),
                        LineChartBarData(
                          spots: babySpots,
                          isCurved: true,
                          color: AppColors.blossom,
                          barWidth: 2.5,
                          dotData: const FlDotData(show: true),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _LegendDot(color: AppColors.blossom, label: 'Bé'),
              const SizedBox(width: AppSpacing.md),
              _LegendDot(color: AppColors.mint, label: 'WHO P50'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricSegmentedTabs extends StatelessWidget {
  const _MetricSegmentedTabs({required this.selected, required this.onSelected});

  final GrowthMetric selected;
  final void Function(GrowthMetric) onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: GrowthMetric.values.map((metric) {
        final isActive = metric == selected;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: InkWell(
              onTap: () => onSelected(metric),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.mintLight : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  border: Border.all(color: AppColors.mint.withValues(alpha: 0.4)),
                ),
                child: Text(
                  '${growthMetricIcon(metric)} ${growthMetricLabel(metric)}',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySm.copyWith(
                    color: isActive ? AppColors.body : AppColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
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
