import 'package:flutter/material.dart';

import '../data/admin_provider.dart';

// ── Grant constants ───────────────────────────────────────────────────────────

const kGrantReasons = [
  'Beta tester',
  'Influencer / KOL',
  'Bug report',
  'Customer support',
  'Partnership',
  'Internal testing',
  'Khác',
];

const kGrantDurations = [
  (label: '7 ngày', days: 7),
  (label: '30 ngày', days: 30),
  (label: '3 tháng', days: 90),
  (label: '6 tháng', days: 180),
  (label: '1 năm', days: 365),
  (label: 'Vĩnh viễn', days: 36500),
];

// ── Audit action metadata ─────────────────────────────────────────────────────

class ActionMeta {
  const ActionMeta({required this.icon, required this.color, required this.label});
  final IconData icon;
  final Color color;
  final String label;
}

ActionMeta actionMeta(String action) {
  switch (action) {
    case 'grant_premium':
      return const ActionMeta(icon: Icons.star, color: Color(0xFF2ED573), label: 'Cấp Premium');
    case 'revoke_premium':
      return const ActionMeta(
          icon: Icons.star_border, color: Color(0xFFFF4757), label: 'Thu hồi Premium');
    case 'set_role':
      return const ActionMeta(
          icon: Icons.admin_panel_settings, color: Color(0xFF6C63FF), label: 'Đặt vai trò');
    case 'update_config':
      return const ActionMeta(
          icon: Icons.settings, color: Color(0xFFFFA502), label: 'Cập nhật cấu hình');
    default:
      return const ActionMeta(
          icon: Icons.history, color: Color(0xFF9999BB), label: 'Hoạt động');
  }
}

// ── Log tile ──────────────────────────────────────────────────────────────────

class LogTile extends StatefulWidget {
  const LogTile({super.key, required this.log});
  final AuditLog log;

  @override
  State<LogTile> createState() => _LogTileState();
}

class _LogTileState extends State<LogTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final meta = actionMeta(widget.log.action);
    final theme = Theme.of(context);
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.dividerColor),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: meta.color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(meta.icon, color: meta.color, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(meta.label,
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          Text(
                            widget.log.targetEmail ?? widget.log.targetUid ?? widget.log.adminEmail,
                            style: theme.textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _formatTime(widget.log.timestamp),
                      style: theme.textTheme.bodySmall,
                    ),
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      size: 18,
                      color: theme.hintColor,
                    ),
                  ],
                ),
                if (_expanded) ...[
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  _DetailRow('Admin', widget.log.adminEmail),
                  if (widget.log.targetEmail != null)
                    _DetailRow('Target', widget.log.targetEmail!),
                  if (widget.log.targetUid != null)
                    _DetailRow('UID', widget.log.targetUid!),
                  ...widget.log.details.entries
                      .where((e) => e.value != null)
                      .map((e) => _DetailRow(e.key, '${e.value}')),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}p';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${dt.day}/${dt.month}';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
