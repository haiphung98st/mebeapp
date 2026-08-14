import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/widgets/bunny_header.dart';
import '../../../shared/providers/notification_config_provider.dart';
import '../../../shared/providers/vaccine_provider.dart';
import '../../subscription/presentation/premium_gate.dart';
import 'widgets/add_growth_dialog.dart';
import 'widgets/growth_chart_card.dart';
import 'widgets/growth_stats_row.dart';
import 'widgets/milestones_section.dart';
import 'widgets/vaccine_section.dart';

class GrowthScreen extends ConsumerStatefulWidget {
  const GrowthScreen({super.key});

  @override
  ConsumerState<GrowthScreen> createState() => _GrowthScreenState();
}

class _GrowthScreenState extends ConsumerState<GrowthScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    ref.listen(upcomingVaccineAlertProvider, (previous, next) {
      if (next == null) return;
      if (previous?.def.key == next.def.key) return;
      if (!ref.read(notificationConfigProvider).vaccineEnabled) return;
      NotificationService.instance.showUpcomingVaccineNotification(next.def.nameVi);
    });

    ref.listen(vaccineViewListProvider, (previous, next) {
      if (!ref.read(notificationConfigProvider).vaccineEnabled) return;
      for (final item in next) {
        if (item.isCompleted) continue;
        final baseId = 4000 + (item.def.key.hashCode.abs() % 1000) * 2;
        final title = '💉 Bé sắp đến lịch tiêm!';
        final body = '${item.def.nameVi} · Ngày ${_formatDmy(item.scheduledDate)}';
        NotificationService.instance.scheduleNotification(
          baseId,
          title,
          body,
          item.scheduledDate.subtract(const Duration(days: 7)),
        );
        NotificationService.instance.scheduleNotification(
          baseId + 1,
          title,
          body,
          item.scheduledDate.subtract(const Duration(days: 1)),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.powder,
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              backgroundColor: AppColors.mint,
              onPressed: () => showDialog(
                context: context,
                builder: (context) => const AddGrowthDialog(),
              ),
              child: const Icon(Icons.add),
            )
          : null,
      body: Column(
        children: [
          BunnyHeader(
            gradient: AppColors.gradientGrowth,
            earLeftColor: AppColors.growthEarLeft,
            earRightColor: AppColors.growthEarRight,
            title: 'Phát triển',
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.lg),
              child: _GrowthSegmentedTabs(
                selectedIndex: _selectedIndex,
                onTap: (index) => setState(() => _selectedIndex = index),
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xxxl,
          ),
          child: Column(
            children: [
              const GrowthStatsRow(),
              const SizedBox(height: AppSpacing.lg),
              const GrowthChartCard(),
            ],
          ),
        );
      case 1:
        return const MilestonesSection();
      default:
        return const Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: PremiumGate(feature: 'vaccine_schedule', child: VaccineSection()),
        );
    }
  }
}

String _formatDmy(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

class _GrowthSegmentedTabs extends StatelessWidget {
  const _GrowthSegmentedTabs({required this.selectedIndex, required this.onTap});

  final int selectedIndex;
  final void Function(int) onTap;

  static const _segments = [
    (icon: '📈', label: 'Phát triển'),
    (icon: '🎯', label: 'Mốc phát triển'),
    (icon: '💉', label: 'Tiêm chủng'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_segments.length, (index) {
        final segment = _segments[index];
        final isActive = index == selectedIndex;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: InkWell(
              onTap: () => onTap(index),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.white : Colors.white24,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(segment.icon, style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 2),
                    Text(
                      segment.label,
                      style: AppTextStyles.label.copyWith(
                        color: isActive ? AppColors.blossom : AppColors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
