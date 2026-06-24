import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/providers/stats_provider.dart';
import '../../subscription/presentation/premium_gate.dart';
import 'widgets/date_range_selector.dart';
import 'widgets/diaper_summary_card.dart';
import 'widgets/feeding_summary_card.dart';
import 'widgets/insight_card.dart';
import 'widgets/pump_summary_card.dart';
import 'widgets/sleep_summary_card.dart';

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
          Text('🐰 AI INSIGHTS', style: AppTextStyles.label),
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
                    child: Text(
                      'Chưa đủ dữ liệu để phân tích. Ghi nhật ký thêm vài ngày nhé 🐰',
                      style: AppTextStyles.bodyMd,
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
