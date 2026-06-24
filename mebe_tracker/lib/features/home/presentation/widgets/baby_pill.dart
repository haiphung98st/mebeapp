import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/bunny_avatar.dart';
import '../../../../shared/models/baby_profile.dart';

class BabyPill extends StatelessWidget {
  const BabyPill({super.key, required this.baby, this.nextFeedingTime});

  final BabyProfile baby;
  final DateTime? nextFeedingTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.blossom.withValues(alpha: 0.14),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const BunnyAvatar(size: 44),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(baby.name, style: AppTextStyles.headingMd),
                const SizedBox(height: 2),
                Text(
                  [
                    formatBabyAge(baby.dateOfBirth),
                    if (baby.weightKg != null) '${baby.weightKg} kg',
                  ].join(' · '),
                  style: AppTextStyles.bodySm,
                ),
              ],
            ),
          ),
          if (nextFeedingTime != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Cữ tiếp theo', style: AppTextStyles.label),
                const SizedBox(height: 2),
                Text(
                  formatTime(nextFeedingTime!),
                  style: AppTextStyles.headingSm.copyWith(color: AppColors.blossom),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
