import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/widgets/bunny_header.dart';
import '../../../shared/providers/home_provider.dart';
import '../../../shared/providers/notification_config_provider.dart';
import '../../../shared/providers/pump_provider.dart';
import 'pump_manual_sheet.dart';
import 'widgets/milk_stash_card.dart';
import 'widgets/pump_log_list.dart';
import 'widgets/pump_session_card.dart';
import 'widgets/weekly_chart_card.dart';

class PumpingScreen extends ConsumerWidget {
  const PumpingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(pumpTimerProvider);
    final allPumps = ref.watch(allPumpsProvider).value ?? const [];

    ref.listen(expiringStashProvider, (previous, next) {
      if (next.isEmpty) return;
      if (previous != null && previous.isNotEmpty) return;
      if (!ref.read(notificationConfigProvider).milkStashEnabled) return;
      final totalMl = next.fold<double>(0, (sum, e) => sum + e.amountMl);
      NotificationService.instance.showExpiringMilkNotification(totalMl);
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
          builder: (context) => const PumpManualSheet(),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: BunnyHeader(
              gradient: AppColors.gradientPump,
              earLeftColor: AppColors.pumpEarLeft,
              earRightColor: AppColors.pumpEarRight,
              title: 'Hút sữa',
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
                timer.hasSession ? const CurrentSessionCard() : const NewSessionButton(),
                const SizedBox(height: AppSpacing.lg),
                const MilkStashCard(),
                const SizedBox(height: AppSpacing.lg),
                const WeeklyChartCard(),
                const SizedBox(height: AppSpacing.lg),
                Text('Lịch sử', style: AppTextStyles.headingMd),
                const SizedBox(height: AppSpacing.md),
                PumpLogList(entries: allPumps),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
