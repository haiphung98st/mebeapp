import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/admin_provider.dart';
import '../admin_utils.dart';

class AdminAuditScreen extends ConsumerStatefulWidget {
  const AdminAuditScreen({super.key});

  @override
  ConsumerState<AdminAuditScreen> createState() => _AdminAuditScreenState();
}

class _AdminAuditScreenState extends ConsumerState<AdminAuditScreen> {
  String _filter = 'all';

  static const _filters = [
    (value: 'all', label: 'Tất cả'),
    (value: 'grant_premium', label: 'Cấp'),
    (value: 'revoke_premium', label: 'Thu hồi'),
    (value: 'set_role', label: 'Vai trò'),
    (value: 'update_config', label: 'Config'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logsAsync = ref.watch(adminAuditLogsProvider);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters.map((f) {
                final selected = _filter == f.value;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(f.label),
                    selected: selected,
                    onSelected: (_) => setState(() => _filter = f.value),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: logsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text('Lỗi tải nhật ký: $e',
                  style: TextStyle(color: theme.colorScheme.error)),
            ),
            data: (logs) {
              final filtered = _filter == 'all'
                  ? logs
                  : logs.where((l) => l.action == _filter).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.history, size: 64, color: Color(0xFF9999BB)),
                      const SizedBox(height: 12),
                      Text('Không có nhật ký', style: theme.textTheme.bodySmall),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filtered.length,
                itemBuilder: (_, i) => LogTile(log: filtered[i]),
              );
            },
          ),
        ),
      ],
    );
  }
}
