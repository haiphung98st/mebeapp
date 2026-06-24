import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/providers/stats_provider.dart';

const _tabs = [
  (StatsRangeType.today, 'Hôm nay'),
  (StatsRangeType.week, '7 ngày'),
  (StatsRangeType.month, 'Tháng này'),
  (StatsRangeType.custom, 'Tùy chọn'),
];

class DateRangeSelector extends ConsumerWidget {
  const DateRangeSelector({super.key});

  Future<void> _pickCustomRange(BuildContext context, WidgetRef ref) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: ref.read(statsCustomRangeProvider),
    );
    if (picked != null) {
      ref.read(statsCustomRangeProvider.notifier).state = DateTimeRange(
        start: DateTime(picked.start.year, picked.start.month, picked.start.day),
        end: DateTime(picked.end.year, picked.end.month, picked.end.day).add(const Duration(days: 1)),
      );
      ref.read(statsRangeTypeProvider.notifier).state = StatsRangeType.custom;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(statsRangeTypeProvider);
    return Row(
      children: _tabs.map((tab) {
        final isActive = tab.$1 == selected;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: InkWell(
              onTap: () {
                if (tab.$1 == StatsRangeType.custom) {
                  _pickCustomRange(context, ref);
                } else {
                  ref.read(statsRangeTypeProvider.notifier).state = tab.$1;
                }
              },
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.blossom : AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  border: Border.all(color: AppColors.petal),
                ),
                child: Text(
                  tab.$2,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySm.copyWith(
                    color: isActive ? AppColors.white : AppColors.body,
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
