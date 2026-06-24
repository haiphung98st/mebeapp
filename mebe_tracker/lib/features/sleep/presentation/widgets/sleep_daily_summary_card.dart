import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/models/sleep_entry.dart';
import '../../../../shared/providers/home_provider.dart';
import '../../../../shared/providers/sleep_provider.dart';

class SleepDailySummaryCard extends ConsumerWidget {
  const SleepDailySummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dailySleepSummaryProvider);
    final todaySleeps = ref.watch(todaySleepsProvider);
    final totalHours = summary.totalMinutes / 60;
    final nightHours = summary.nightMinutes / 60;

    return Container(
      width: double.infinity,
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
          Text('Hôm nay', style: AppTextStyles.headingMd),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SummaryNumber(value: '${totalHours.toStringAsFixed(1)}h', label: 'Tổng cộng'),
              _SummaryNumber(value: '${summary.sessionCount}', label: 'Số giấc'),
              _SummaryNumber(value: '${nightHours.toStringAsFixed(1)}h', label: 'Ngủ đêm'),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _DayTimeline(sleeps: todaySleeps),
        ],
      ),
    );
  }
}

class _SummaryNumber extends StatelessWidget {
  const _SummaryNumber({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.displaySm.copyWith(color: AppColors.nightMid)),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.bodySm),
      ],
    );
  }
}

class _DayTimeline extends StatelessWidget {
  const _DayTimeline({required this.sleeps});

  final List<SleepEntry> sleeps;

  @override
  Widget build(BuildContext context) {
    final today = startOfDay(DateTime.now());
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return SizedBox(
          height: 20,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.powder,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
              ),
              for (final entry in sleeps)
                ..._segmentsFor(entry, today, width),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _segmentsFor(SleepEntry entry, DateTime today, double width) {
    const dayMinutes = 24 * 60;
    final startMinutes = entry.startTime.difference(today).inMinutes.clamp(0, dayMinutes);
    final end = entry.endTime ?? DateTime.now();
    final endMinutes = end.difference(today).inMinutes.clamp(0, dayMinutes);
    if (endMinutes <= startMinutes) return const [];

    final left = width * startMinutes / dayMinutes;
    final segmentWidth = width * (endMinutes - startMinutes) / dayMinutes;
    final color = entry.type == SleepType.night ? AppColors.nightMid : AppColors.lavender;

    return [
      Positioned(
        left: left,
        width: segmentWidth,
        top: 0,
        bottom: 0,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
        ),
      ),
    ];
  }
}
