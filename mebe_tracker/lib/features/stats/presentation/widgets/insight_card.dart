import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/providers/stats_provider.dart';

class InsightCard extends StatelessWidget {
  const InsightCard({super.key, required this.insight});

  final Insight insight;

  @override
  Widget build(BuildContext context) {
    final isAnomaly = insight.type == InsightType.anomaly;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isAnomaly ? AppColors.peachLight : AppColors.lilac,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: isAnomaly ? AppColors.warning.withValues(alpha: 0.4) : AppColors.lavender.withValues(alpha: 0.3)),
      ),
      child: Text(
        insight.message,
        style: AppTextStyles.bodyMd.copyWith(color: AppColors.ink),
      ),
    );
  }
}
