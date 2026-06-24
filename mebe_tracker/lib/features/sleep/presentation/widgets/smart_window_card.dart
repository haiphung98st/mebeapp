import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/providers/sleep_provider.dart';

class SmartWindowCard extends ConsumerWidget {
  const SmartWindowCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final predictionAsync = ref.watch(sleepPredictionProvider);

    return predictionAsync.when(
      data: (prediction) {
        if (prediction == null) return const SizedBox.shrink();
        final progress = (prediction.confidencePercent / 100).clamp(0.0, 1.0);
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            boxShadow: [
              BoxShadow(
                color: AppColors.lavender.withValues(alpha: 0.15),
                blurRadius: 14,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🐰 AI dự báo · Cửa sổ ngủ tiếp theo', style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${formatTime(prediction.windowStart)} – ${formatTime(prediction.windowEnd)}',
                style: AppTextStyles.headingLg.copyWith(color: AppColors.lavender),
              ),
              const SizedBox(height: 2),
              Text(
                'Dựa trên lịch sử ${prediction.sampleDays} ngày · Độ chính xác ${prediction.confidencePercent}%',
                style: AppTextStyles.bodySm,
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppColors.lilac,
                  color: AppColors.lavender,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
