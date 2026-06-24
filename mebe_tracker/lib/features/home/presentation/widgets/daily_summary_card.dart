import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/ring_chart.dart';

class DailySummaryCard extends StatelessWidget {
  const DailySummaryCard({
    super.key,
    required this.feedingCount,
    required this.sleepHours,
    required this.diaperCount,
    required this.pumpMl,
  });

  final int feedingCount;
  final double sleepHours;
  final int diaperCount;
  final double pumpMl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.blossom.withValues(alpha: 0.1),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hôm nay', style: AppTextStyles.headingMd),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RingChart(
                value: feedingCount.toDouble(),
                maxValue: 8,
                color: AppColors.blossom,
                trackColor: AppColors.blush,
                label: 'Cữ bú',
                valueText: '$feedingCount',
              ),
              RingChart(
                value: sleepHours,
                maxValue: 14,
                color: AppColors.lavender,
                trackColor: AppColors.lilac,
                label: 'Giấc ngủ',
                valueText: '${sleepHours.toStringAsFixed(1)}h',
              ),
              RingChart(
                value: diaperCount.toDouble(),
                maxValue: 8,
                color: AppColors.mint,
                trackColor: AppColors.mintLight,
                label: 'Thay tã',
                valueText: '$diaperCount',
              ),
              RingChart(
                value: pumpMl,
                maxValue: 500,
                color: AppColors.mauve,
                trackColor: AppColors.lilac,
                label: 'Hút sữa',
                valueText: pumpMl.toStringAsFixed(0),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
