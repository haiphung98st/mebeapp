import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/bunny_header.dart';
import '../../../shared/providers/home_provider.dart';
import '../../../shared/providers/sleep_provider.dart';
import 'widgets/active_sleep_card.dart';
import 'widgets/sleep_daily_summary_card.dart';
import 'widgets/sleep_history_list.dart';
import 'widgets/smart_window_card.dart';
import 'widgets/weekly_sleep_chart.dart';

class SleepScreen extends ConsumerWidget {
  const SleepScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeSleepProvider);
    final allSleeps = ref.watch(allSleepsProvider).value ?? const [];

    return Scaffold(
      backgroundColor: AppColors.powder,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: BunnyHeader(
              gradient: AppColors.gradientSleep,
              earLeftColor: AppColors.sleepEarLeft,
              earRightColor: AppColors.sleepEarRight,
              title: 'Giấc ngủ',
              titleColor: AppColors.white,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xxxl,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                active.isActive ? const ActiveSleepCard() : const StartSleepCard(),
                const SizedBox(height: AppSpacing.lg),
                const SmartWindowCard(),
                const SizedBox(height: AppSpacing.lg),
                const SleepDailySummaryCard(),
                const SizedBox(height: AppSpacing.lg),
                const WeeklySleepChart(),
                const SizedBox(height: AppSpacing.lg),
                SleepHistoryList(entries: allSleeps),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
