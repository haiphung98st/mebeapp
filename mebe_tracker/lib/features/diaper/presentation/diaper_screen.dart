import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/widgets/bunny_header.dart';
import '../../../shared/providers/diaper_provider.dart';
import '../../../shared/providers/home_provider.dart';
import 'diaper_manual_sheet.dart';
import 'widgets/daily_count_row.dart';
import 'widgets/diaper_color_guide.dart';
import 'widgets/diaper_log_list.dart';
import 'widgets/mood_section.dart';
import 'widgets/quick_log_section.dart';

class DiaperScreen extends ConsumerWidget {
  const DiaperScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allDiapers = ref.watch(allDiapersProvider).value ?? const [];

    ref.listen(lowDiaperAlertProvider, (previous, next) {
      if (!next) return;
      if (previous == true) return;
      NotificationService.instance.showLowDiaperCountNotification();
    });

    return Scaffold(
      backgroundColor: AppColors.powder,
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Nhập tay'),
        backgroundColor: AppColors.mint,
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const DiaperManualSheet(),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: BunnyHeader(
              gradient: AppColors.gradientDiaper,
              earLeftColor: AppColors.diaperEarLeft,
              earRightColor: AppColors.diaperEarRight,
              title: 'Thay tã',
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
                const QuickLogSection(),
                const SizedBox(height: AppSpacing.lg),
                const DailyCountRow(),
                const SizedBox(height: AppSpacing.lg),
                const MoodSection(),
                const SizedBox(height: AppSpacing.lg),
                const DiaperColorGuide(),
                const SizedBox(height: AppSpacing.lg),
                DiaperLogList(entries: allDiapers),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
