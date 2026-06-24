import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/models/diaper_entry.dart';
import '../../../../shared/providers/diaper_provider.dart';
import '../../../../shared/providers/home_provider.dart';

class DailyCountRow extends ConsumerWidget {
  const DailyCountRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayDiapersProvider);
    final yesterdayCount = ref.watch(yesterdayDiaperCountProvider);
    final wetCount = today.where((e) => e.type != DiaperType.dirty).length;
    final dirtyCount = today.where((e) => e.type != DiaperType.wet).length;
    final total = today.length;

    final diff = total - yesterdayCount;
    final diffColor = diff >= 0 ? AppColors.success : AppColors.warning;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.mint.withValues(alpha: 0.15),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💧 $wetCount lần ướt · 💩 $dirtyCount lần bẩn · Tổng: $total lần',
            style: AppTextStyles.bodyLg,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Hôm qua: $yesterdayCount lần',
            style: AppTextStyles.bodySm.copyWith(color: diffColor),
          ),
        ],
      ),
    );
  }
}
