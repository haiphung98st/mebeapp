import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_toast.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../data/admin_provider.dart';
import '../admin_shell.dart';
import '../widgets/grant_bottom_sheet.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  final _searchController = TextEditingController();
  Map<String, dynamic>? _userResult;
  bool _isSearching = false;
  bool _isRevoking = false;
  String? _errorMessage;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _userResult = null;
      _errorMessage = null;
    });

    try {
      final isEmail = query.contains('@');
      final result = await ref.read(adminNotifierProvider.notifier).getUser(
            uid: isEmail ? null : query,
            email: isEmail ? query : null,
          );
      if (mounted) setState(() => _userResult = result);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'Không tìm thấy người dùng: $e');
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _revoke(String uid) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Thu hồi Premium',
      content: 'Xác nhận thu hồi Premium của người dùng này?',
      confirmLabel: 'Thu hồi',
      confirmColor: AdminColors.danger,
    );
    if (confirmed != true) return;

    setState(() => _isRevoking = true);
    try {
      await ref.read(adminNotifierProvider.notifier).revokePremium(uid: uid);
      if (mounted) {
        AppToast.success(context, 'Đã thu hồi Premium');
        _search();
      }
    } catch (e) {
      if (mounted) AppToast.error(context, 'Lỗi: $e');
    } finally {
      if (mounted) setState(() => _isRevoking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Email hoặc UID',
                    hintText: 'user@example.com hoặc uid...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onSubmitted: (_) => _search(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isSearching ? null : _search,
                child: _isSearching
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Tìm'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AdminColors.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AdminColors.danger.withValues(alpha: 0.3)),
              ),
              child: Text(_errorMessage!, style: const TextStyle(color: AdminColors.danger)),
            ),
          if (_userResult != null)
            _UserResultCard(
              data: _userResult!,
              isRevoking: _isRevoking,
              onGrant: () => showGrantBottomSheet(
                context,
                uid: _userResult!['uid'] as String,
                displayName: _userResult!['displayName'] as String? ??
                    _userResult!['email'] as String? ??
                    'User',
              ).then((_) => _search()),
              onRevoke: () => _revoke(_userResult!['uid'] as String),
            ),
          if (_userResult == null && !_isSearching && _errorMessage == null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person_search_outlined,
                        size: 64, color: AdminColors.textSecondary),
                    const SizedBox(height: 12),
                    Text('Nhập email hoặc UID để tìm người dùng',
                        style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _UserResultCard extends StatelessWidget {
  const _UserResultCard({
    required this.data,
    required this.onGrant,
    required this.onRevoke,
    required this.isRevoking,
  });

  final Map<String, dynamic> data;
  final VoidCallback onGrant;
  final VoidCallback onRevoke;
  final bool isRevoking;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sub = data['subscription'] as Map<String, dynamic>?;
    final isActive = sub?['isActive'] == true;

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AdminColors.primary.withValues(alpha: 0.2),
                child: Text(
                  ((data['displayName'] as String?)?.isNotEmpty == true
                          ? (data['displayName'] as String)[0]
                          : (data['email'] as String? ?? 'U')[0])
                      .toUpperCase(),
                  style: const TextStyle(color: AdminColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['displayName'] as String? ?? 'Chưa đặt tên',
                        style: theme.textTheme.titleMedium),
                    Text(data['email'] as String? ?? '', style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive
                      ? AdminColors.success.withValues(alpha: 0.15)
                      : AdminColors.textSecondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isActive ? 'PREMIUM' : 'FREE',
                  style: TextStyle(
                    color: isActive ? AdminColors.success : AdminColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AdminColors.divider, height: 1),
          const SizedBox(height: 12),
          _Row('UID', data['uid'] as String? ?? ''),
          _Row('Vai trò', (data['role'] as String? ?? 'user').toUpperCase()),
          _Row('Ngày tạo', _formatDate(data['createdAt'] as String?)),
          if (isActive && sub != null) ...[
            _Row('Premium bắt đầu', _formatDate(sub['startedAt'] as String?)),
            _Row('Hết hạn', _formatDate(sub['expiresAt'] as String?)),
            if (sub['isManualGrant'] == true) _Row('Lý do', sub['grantReason'] as String? ?? ''),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onGrant,
                  icon: const Icon(Icons.star_outline, size: 18),
                  label: const Text('Cấp Premium'),
                ),
              ),
              if (isActive) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isRevoking ? null : onRevoke,
                    icon: isRevoking
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child:
                                CircularProgressIndicator(strokeWidth: 2, color: AdminColors.danger))
                        : const Icon(Icons.remove_circle_outline, size: 18,
                            color: AdminColors.danger),
                    label: const Text('Thu hồi', style: TextStyle(color: AdminColors.danger)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AdminColors.danger),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  static String _formatDate(String? iso) {
    if (iso == null) return '--';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: const TextStyle(color: AdminColors.textSecondary, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(color: AdminColors.textPrimary, fontSize: 13),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
