import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/admin_provider.dart';
import '../admin_utils.dart';

final _adminStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) {
  return ref.read(adminNotifierProvider.notifier).getStats();
});

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statsAsync = ref.watch(_adminStatsProvider);
    final logsAsync = ref.watch(adminAuditLogsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tổng quan', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          statsAsync.when(
            loading: () => const _StatsGrid(loading: true, stats: {}),
            error: (e, _) => Center(
              child: Text('Lỗi tải stats: $e', style: const TextStyle(color: Color(0xFFFF4757))),
            ),
            data: (stats) => _StatsGrid(stats: stats),
          ),
          const SizedBox(height: 24),
          Text('Hoạt động gần đây', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          logsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Lỗi: $e'),
            data: (logs) {
              final recent = logs.take(5).toList();
              if (recent.isEmpty) {
                return const Center(child: Text('Chưa có hoạt động nào'));
              }
              return Column(children: recent.map((l) => LogTile(log: l)).toList());
            },
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats, this.loading = false});
  final Map<String, dynamic> stats;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatItem('Tổng người dùng', '${stats['totalUsers'] ?? '--'}', Icons.people_outline,
          const Color(0xFF6C63FF)),
      _StatItem('Premium', '${stats['premiumUsers'] ?? '--'}', Icons.star_outline,
          const Color(0xFF2ED573)),
      _StatItem('Miễn phí', '${stats['freeUsers'] ?? '--'}', Icons.person_outline,
          const Color(0xFF9999BB)),
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.0,
      children: items.map((item) => _StatCard(item: item, loading: loading)).toList(),
    );
  }
}

class _StatItem {
  const _StatItem(this.label, this.value, this.icon, this.color);
  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.item, required this.loading});
  final _StatItem item;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: item.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: item.color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(item.icon, color: item.color, size: 22),
          loading
              ? Container(
                  width: 40,
                  height: 22,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                )
              : Text(
                  item.value,
                  style: TextStyle(
                    color: item.color,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          Text(item.label,
              style: theme.textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
