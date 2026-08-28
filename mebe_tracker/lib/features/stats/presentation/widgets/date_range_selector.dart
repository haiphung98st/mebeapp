import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/providers/stats_provider.dart';

const _tabs = [
  (StatsRangeType.today, 'Ngày'),
  (StatsRangeType.week, 'Tuần'),
  (StatsRangeType.month, 'Tháng'),
  (StatsRangeType.year, 'Năm'),
  (StatsRangeType.custom, 'Tùy chọn'),
];

String _rangeLabel(StatsRangeType type, DateTime anchor, DateTimeRange range) {
  switch (type) {
    case StatsRangeType.today:
      return DateFormat('dd/MM/yyyy').format(anchor);
    case StatsRangeType.week:
      final end = range.end.subtract(const Duration(days: 1));
      return '${DateFormat('dd/MM').format(range.start)} – ${DateFormat('dd/MM/yyyy').format(end)}';
    case StatsRangeType.month:
      return DateFormat('MM/yyyy').format(anchor);
    case StatsRangeType.year:
      return '${anchor.year}';
    case StatsRangeType.custom:
      return '${DateFormat('dd/MM/yyyy').format(range.start)} – '
          '${DateFormat('dd/MM/yyyy').format(range.end.subtract(const Duration(days: 1)))}';
  }
}

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

  Future<void> _pickAnchor(BuildContext context, WidgetRef ref, StatsRangeType type) async {
    final anchor = ref.read(statsAnchorDateProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: anchor,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: switch (type) {
        StatsRangeType.year => 'Chọn năm',
        StatsRangeType.month => 'Chọn tháng',
        _ => 'Chọn ngày',
      },
    );
    if (picked != null) {
      ref.read(statsAnchorDateProvider.notifier).state = picked;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(statsRangeTypeProvider);
    final anchor = ref.watch(statsAnchorDateProvider);
    final range = ref.watch(statsDateRangeProvider);
    final canForward = canShiftStatsForward(ref);

    return Column(
      children: [
        if (selected != StatsRangeType.custom)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: AppColors.blossom),
                  onPressed: () => shiftStatsAnchor(ref, -1),
                ),
                GestureDetector(
                  onTap: () => _pickAnchor(context, ref, selected),
                  child: Text(
                    _rangeLabel(selected, anchor, range),
                    style: AppTextStyles.headingSm,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  color: canForward ? AppColors.blossom : AppColors.muted,
                  onPressed: canForward ? () => shiftStatsAnchor(ref, 1) : null,
                ),
              ],
            ),
          ),
        Row(
          children: _tabs.map((tab) {
            final isActive = tab.$1 == selected;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
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
        ),
      ],
    );
  }
}
