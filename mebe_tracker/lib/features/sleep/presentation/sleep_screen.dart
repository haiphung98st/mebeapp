import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/widgets/bunny_header.dart';
import '../../../shared/providers/home_provider.dart';
import '../../../shared/providers/notification_config_provider.dart';
import '../../../shared/providers/sleep_provider.dart';
import 'sleep_manual_sheet.dart';
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

    ref.listen(sleepPredictionProvider, (previous, next) {
      final prediction = next.value;
      if (prediction == null) return;
      if (previous?.value?.windowStart == prediction.windowStart) return;
      if (!ref.read(notificationConfigProvider).sleepEnabled) return;
      final reminderTime = prediction.windowStart.subtract(const Duration(minutes: 15));
      NotificationService.instance.cancelNotification(2002);
      NotificationService.instance.scheduleNotification(
        2002,
        '🌙 Chuẩn bị cho bé ngủ nhé!',
        'Cửa sổ ngủ tiếp theo: ${_formatHm(prediction.windowStart)} – ${_formatHm(prediction.windowEnd)}',
        reminderTime,
      );
    });

    return Scaffold(
      backgroundColor: AppColors.powder,
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Nhập tay'),
        backgroundColor: AppColors.lavender,
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const SleepManualSheet(),
        ),
      ),
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

String _formatHm(DateTime time) =>
    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
