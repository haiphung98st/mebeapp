import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/widgets/bunny_header.dart';
import '../../../shared/providers/pump_provider.dart';
import 'widgets/milk_stash_card.dart';
import 'widgets/pump_session_card.dart';
import 'widgets/weekly_chart_card.dart';

class PumpingScreen extends ConsumerWidget {
  const PumpingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(pumpTimerProvider);

    ref.listen(expiringStashProvider, (previous, next) {
      if (next.isEmpty) return;
      if (previous != null && previous.isNotEmpty) return;
      final totalMl = next.fold<double>(0, (sum, e) => sum + e.amountMl);
      NotificationService.instance.showExpiringMilkNotification(totalMl);
    });

    return Scaffold(
      backgroundColor: AppColors.powder,
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
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
