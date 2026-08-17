import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/bunny_header.dart';
import '../data/community_stats_provider.dart';

class CommunityStatsScreen extends ConsumerStatefulWidget {
  const CommunityStatsScreen({super.key});

  @override
  ConsumerState<CommunityStatsScreen> createState() =>
      _CommunityStatsScreenState();
}

class _CommunityStatsScreenState extends ConsumerState<CommunityStatsScreen> {
  bool _publishing = false;
  bool _published = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _publish());
  }

  Future<void> _publish() async {
    if (_publishing) return;
    setState(() => _publishing = true);
    try {
      await publishCommunityStats(ref);
      if (mounted) setState(() => _published = true);
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final percentilesAsync = ref.watch(communityStatsEntriesProvider);
    final percentiles = ref.watch(communityPercentilesProvider);

    return Scaffold(
      backgroundColor: AppColors.powder,
      body: Column(
        children: [
          BunnyHeader(
            gradient: const LinearGradient(
              colors: [Color(0xFF9B59B6), Color(0xFFF472A0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            earLeftColor: AppColors.lavender,
            earRightColor: AppColors.blossom,
            title: 'Thống kê nhóm',
            subtitle: 'So sánh ẩn danh cùng tuần sinh',
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          // Privacy note
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            color: AppColors.lavender.withOpacity(0.12),
            child: Text(
              '🔒 Dữ liệu ẩn danh · Không ai biết số liệu là của bạn',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.muted),
              textAlign: TextAlign.center,
            ),
          ),

          Expanded(
            child: percentilesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('Không tải được dữ liệu',
                    style: AppTextStyles.bodyMd),
              ),
              data: (_) {
                if (percentiles == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _buildContent(context, percentiles);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, CommunityPercentiles p) {
    final my = p.myEntry;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // Contributor banner
        _ContributorBanner(
          count: p.totalContributors,
          publishing: _publishing,
          published: _published,
          onRefresh: _publish,
        ),
        const SizedBox(height: AppSpacing.md),

        if (my == null) ...[
          _EmptyContrib(),
        ] else ...[
          _StatCard(
            icon: '🍼',
            label: 'Số lần bú hôm nay',
            value: '${my.feedingCount} lần',
            percentile: p.feedingPct,
            color: AppColors.blossom,
          ),
          const SizedBox(height: AppSpacing.sm),
          _StatCard(
            icon: '😴',
            label: 'Tổng giấc ngủ hôm nay',
            value: _formatMinutes(my.totalSleepMinutes),
            percentile: p.sleepPct,
            color: AppColors.lavender,
          ),
          const SizedBox(height: AppSpacing.sm),
          _StatCard(
            icon: '🧷',
            label: 'Số tã thay hôm nay',
            value: '${my.diaperCount} cái',
            percentile: p.diaperPct,
            color: AppColors.mint,
          ),
          const SizedBox(height: AppSpacing.lg),
          _InfoNote(),
        ],
      ],
    );
  }

  String _formatMinutes(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}p';
    if (m == 0) return '${h}g';
    return '${h}g ${m}p';
  }
}

// ── Contributor banner ────────────────────────────────────────────────────────

class _ContributorBanner extends StatelessWidget {
  const _ContributorBanner({
    required this.count,
    required this.publishing,
    required this.published,
    required this.onRefresh,
  });

  final int count;
  final bool publishing;
  final bool published;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.lilac,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('👶', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count > 0
                      ? '$count mẹ đã đóng góp số liệu hôm nay'
                      : 'Bạn là người đầu tiên hôm nay!',
                  style: AppTextStyles.bodyMd.copyWith(
                      fontWeight: FontWeight.w700, color: AppColors.ink),
                ),
                Text(
                  published ? 'Đã cập nhật số liệu của bạn ✓' : 'Đang xử lý...',
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
          IconButton(
            icon: publishing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded, color: AppColors.blossom),
            onPressed: publishing ? null : onRefresh,
            tooltip: 'Cập nhật số liệu',
          ),
        ],
      ),
    );
  }
}

// ── Stat card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.percentile,
    required this.color,
  });

  final String icon;
  final String label;
  final String value;
  final double percentile; // 0..100
  final Color color;

  @override
  Widget build(BuildContext context) {
    final pct = percentile.clamp(0, 100).toInt();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.muted),
                ),
              ),
              Text(
                value,
                style: AppTextStyles.bodyMd.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _PercentileBar(percentile: percentile, color: color),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _label(pct),
            style: AppTextStyles.bodySm.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  String _label(int pct) {
    if (pct <= 10) return 'Ít hơn hầu hết nhóm ($pct%)';
    if (pct <= 40) return 'Dưới mức trung bình của nhóm ($pct%)';
    if (pct <= 60) return 'Gần mức trung bình của nhóm ($pct%)';
    if (pct <= 90) return 'Nhiều hơn $pct% các bé trong nhóm';
    return 'Thuộc top nhóm cao nhất ($pct%)';
  }
}

// ── Percentile bar ────────────────────────────────────────────────────────────

class _PercentileBar extends StatelessWidget {
  const _PercentileBar({required this.percentile, required this.color});

  final double percentile;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final fraction = (percentile / 100).clamp(0.0, 1.0);
    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth;
        final markerX = barWidth * fraction;
        return SizedBox(
          height: 28,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Track
              Positioned(
                top: 10,
                left: 0,
                right: 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withOpacity(0.15),
                          color.withOpacity(0.4),
                          color,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Marker
              Positioned(
                top: 4,
                left: (markerX - 10).clamp(0, barWidth - 20),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: AppColors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Empty contrib ─────────────────────────────────────────────────────────────

class _EmptyContrib extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Column(
          children: [
            const Text('📊', style: TextStyle(fontSize: 48)),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Chưa có dữ liệu để so sánh',
              style: AppTextStyles.headingSm.copyWith(color: AppColors.ink),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Hãy ghi nhật ký hôm nay để\nso sánh với các bé trong nhóm',
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.muted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Info note ─────────────────────────────────────────────────────────────────

class _InfoNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.lilac.withOpacity(0.4),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ℹ️', style: TextStyle(fontSize: 16)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Số liệu được tổng hợp từ nhật ký hôm nay của bạn. '
              'Danh tính được ẩn danh hoàn toàn — chỉ có số liệu tổng hợp được chia sẻ.',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.body),
            ),
          ),
        ],
      ),
    );
  }
}
