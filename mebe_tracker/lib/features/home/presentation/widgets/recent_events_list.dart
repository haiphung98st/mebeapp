import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/icons/mebe_icons.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/providers/home_provider.dart';

class RecentEventsList extends StatelessWidget {
  const RecentEventsList({super.key, required this.events});

  final List<RecentEvent> events;

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
          Text('Gần đây', style: AppTextStyles.headingMd),
          const SizedBox(height: AppSpacing.md),
          if (events.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Text('Chưa có hoạt động nào hôm nay', style: AppTextStyles.bodySm),
            )
          else
            ...events.map(
              (event) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(
                  children: [
                    ClipOval(child: MeBeIcon(type: event.icon, size: 36)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(event.title, style: AppTextStyles.bodyLg),
                          Text(event.subtitle, style: AppTextStyles.bodySm),
                        ],
                      ),
                    ),
                    Text(formatTime(event.time), style: AppTextStyles.bodySm),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
