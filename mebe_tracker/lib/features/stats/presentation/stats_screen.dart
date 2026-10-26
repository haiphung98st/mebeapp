import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/icons/mebe_icons.dart';
import '../../../shared/providers/stats_provider.dart';
import '../../subscription/presentation/premium_gate.dart';
import 'widgets/date_range_selector.dart';
import 'widgets/diaper_summary_card.dart';
import 'widgets/feeding_summary_card.dart';
import 'widgets/insight_card.dart';
import 'widgets/pump_summary_card.dart';
import 'widgets/sleep_summary_card.dart';

class _WrappedBanner extends StatelessWidget {
  const _WrappedBanner({required this.year});
  final int year;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/wrapped'),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Row(
          children: [
            const MeBeIcon(type: MeBeIconType.mascotBunny, size: 32),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Năng Năm $year',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        'Xem lại hành trình cả năm ',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const MeBeIcon(type: MeBeIconType.premium, size: 14),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }
}

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insights = ref.watch(aiInsightsProvider);

    return Scaffold(
      backgroundColor: AppColors.powder,
      appBar: AppBar(title: const Text('Thống kê'), backgroundColor: AppColors.powder, elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _WrappedBanner(year: DateTime.now().year),
          const SizedBox(height: AppSpacing.lg),
          const DateRangeSelector(),
          const SizedBox(height: AppSpacing.lg),
          const FeedingSummaryCard(),
          const SizedBox(height: AppSpacing.lg),
          const SleepSummaryCard(),
          const SizedBox(height: AppSpacing.lg),
          const PumpSummaryCard(),
          const SizedBox(height: AppSpacing.lg),
          const DiaperSummaryCard(),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              const MeBeIcon(type: MeBeIconType.mascotBunny, size: 18),
              const SizedBox(width: 6),
              Text('AI INSIGHTS', style: AppTextStyles.label),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          PremiumGate(
            feature: 'ai_insights',
            child: insights.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            'Chưa đủ dữ liệu để phân tích. Ghi nhật ký thêm vài ngày nhé',
                            style: AppTextStyles.bodyMd,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const MeBeIcon(type: MeBeIconType.mascotBunny, size: 18),
                      ],
                    ),
                  )
                : Column(
                    children: insights.map((insight) => InsightCard(insight: insight)).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
