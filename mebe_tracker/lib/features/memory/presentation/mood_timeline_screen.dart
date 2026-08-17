import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/bunny_header.dart';
import '../../../shared/providers/subscription_provider.dart';
import '../data/mood_timeline_provider.dart';

const _gradientMood = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFFCD34D), Color(0xFFF59E0B)],
);

class MoodTimelineScreen extends ConsumerStatefulWidget {
  const MoodTimelineScreen({super.key});

  @override
  ConsumerState<MoodTimelineScreen> createState() =>
      _MoodTimelineScreenState();
}

class _MoodTimelineScreenState extends ConsumerState<MoodTimelineScreen> {
  final DateTime _today = DateTime.now();
  late DateTime _from;
  late DateTime _to;

  @override
  void initState() {
    super.initState();
    _to = _today;
    _from = _today.subtract(const Duration(days: 89));
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(isPremiumProvider);
    final effectiveFrom = isPremium ? _from : _today.subtract(const Duration(days: 29));
    final args = (from: effectiveFrom, to: _to);
    final async_ = ref.watch(moodTimelineProvider(args));

    return Scaffold(
      backgroundColor: AppColors.powder,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: BunnyHeader(
              gradient: _gradientMood,
              earLeftColor: const Color(0xFFFDE68A),
              earRightColor: const Color(0xFFFBBF24),
              title: 'Tâm trạng theo ngày 🌈',
              subtitle: isPremium ? '90 ngày' : '30 ngày miễn phí',
              actions: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => context.pop(),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: _Legend(),
            ),
          ),

          async_.when(
            loading: () => const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Center(
                child: Text('Lỗi: $e'),
              ),
            ),
            data: (days) => SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: _HeatmapGrid(days: days),
                ),
                const SizedBox(height: AppSpacing.lg),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: _InsightCard(insights: computeInsights(days)),
                ),
                if (!isPremium) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: _UpgradeBanner(
                      onUpgrade: () => context.push('/home/subscription'),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xxxl),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeatmapGrid extends StatelessWidget {
  const _HeatmapGrid({required this.days});

  final List<DayMood> days;

  @override
  Widget build(BuildContext context) {
    // Group by month
    final byMonth = <String, List<DayMood>>{};
    for (final d in days) {
      final key = '${d.date.year}-${d.date.month}';
      (byMonth[key] ??= []).add(d);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: byMonth.entries.map((entry) {
        final parts = entry.key.split('-');
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _monthLabel(month, year),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.body,
              ),
            ),
            const SizedBox(height: 8),
            _MonthGrid(days: entry.value),
            const SizedBox(height: AppSpacing.md),
          ],
        );
      }).toList(),
    );
  }

  String _monthLabel(int month, int year) {
    const months = [
      '', 'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4',
      'Tháng 5', 'Tháng 6', 'Tháng 7', 'Tháng 8',
      'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12',
    ];
    return '${months[month]} $year';
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({required this.days});

  final List<DayMood> days;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: days.map((d) {
        return Tooltip(
          message: _tooltip(d),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: d.color,
              borderRadius: BorderRadius.circular(6),
              border: d.isLeapStorm
                  ? Border.all(color: AppColors.error, width: 1.5)
                  : null,
            ),
            child: Center(
              child: Text(
                '${d.date.day}',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _tooltip(DayMood d) {
    if (d.isLeapStorm) return 'Leap Storm: ${d.leapName ?? ''}';
    if (d.momMood == null) return 'Không có dữ liệu';
    return 'Tâm trạng mẹ: ${d.momMood}/5';
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insights});

  final MoodInsights insights;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phân tích tâm trạng 💡',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _Row(emoji: '🟢', label: 'Ngày tâm trạng tốt', value: '${insights.greenDays} ngày'),
          _Row(emoji: '🔴', label: 'Ngày leap storm', value: '${insights.redDays} ngày'),
          _Row(emoji: '⭐', label: 'Tháng vui nhất', value: insights.bestMonth),
          if (insights.crankiestWeekday != null)
            _Row(
              emoji: '😤',
              label: 'Ngày bé hay quấy nhất',
              value: insights.crankiestWeekday!,
            ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.emoji,
    required this.label,
    required this.value,
  });

  final String emoji;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppColors.body),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(color: const Color(0xFF68D391), label: 'Tốt'),
        _LegendItem(color: const Color(0xFFF6E05E), label: 'Bình thường'),
        _LegendItem(color: const Color(0xFFFBD38D), label: 'Mệt'),
        _LegendItem(color: const Color(0xFFFC8181), label: 'Leap storm'),
        _LegendItem(color: const Color(0xFFE2E8F0), label: 'Không có'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(fontSize: 9, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _UpgradeBanner extends StatelessWidget {
  const _UpgradeBanner({required this.onUpgrade});

  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF8E1), Color(0xFFFEF3C7)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFCD34D), width: 1.5),
      ),
      child: Row(
        children: [
          const Text('⭐', style: TextStyle(fontSize: 22)),
          const SizedBox(width: AppSpacing.md),
          const Expanded(
            child: Text(
              'Xem toàn bộ lịch sử với Premium',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
          ),
          TextButton(
            onPressed: onUpgrade,
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
            ),
            child: const Text('Nâng cấp'),
          ),
        ],
      ),
    );
  }
}
