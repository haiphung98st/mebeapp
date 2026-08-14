import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_toast.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../data/admin_provider.dart';
import '../admin_shell.dart';

class AdminRolesScreen extends ConsumerStatefulWidget {
  const AdminRolesScreen({super.key});

  @override
  ConsumerState<AdminRolesScreen> createState() => _AdminRolesScreenState();
}

class _AdminRolesScreenState extends ConsumerState<AdminRolesScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;
  Map<String, dynamic>? _foundUser;
  String? _searchError;
  String? _selectedRole;
  bool _isSaving = false;

  static const _roleOptions = [
    (value: 'user', label: 'User', desc: 'Người dùng thông thường'),
    (value: 'support', label: 'Support', desc: 'Xem & cấp Premium'),
    (value: 'admin', label: 'Admin', desc: 'Quản lý cấu hình'),
    (value: 'superadmin', label: 'Superadmin', desc: 'Toàn quyền'),
  ];

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
      _foundUser = null;
      _searchError = null;
      _selectedRole = null;
    });

    try {
      final isEmail = query.contains('@');
      final result = await ref.read(adminNotifierProvider.notifier).getUser(
            uid: isEmail ? null : query,
            email: isEmail ? query : null,
          );
      if (mounted) {
        setState(() {
          _foundUser = result;
          _selectedRole = result['role'] as String? ?? 'user';
        });
      }
    } catch (e) {
      if (mounted) setState(() => _searchError = 'Không tìm thấy: $e');
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _save() async {
    if (_foundUser == null || _selectedRole == null) return;

    final currentUser = ref.read(currentUserProvider);
    if (_foundUser!['uid'] == currentUser?.uid) {
      AppToast.error(context, 'Không thể tự thay đổi vai trò của mình');
      return;
    }

    final confirmed = await showConfirmDialog(
      context,
      title: 'Thay đổi vai trò',
      content:
          'Đặt vai trò "${_selectedRole!.toUpperCase()}" cho ${_foundUser!["email"] ?? _foundUser!["uid"]}?',
      confirmLabel: 'Xác nhận',
    );
    if (confirmed != true) return;

    setState(() => _isSaving = true);
    try {
      await ref.read(adminNotifierProvider.notifier).setRole(
            uid: _foundUser!['uid'] as String,
            role: _selectedRole!,
          );
      if (mounted) AppToast.success(context, 'Đã đặt vai trò $_selectedRole');
    } catch (e) {
      if (mounted) AppToast.error(context, 'Lỗi: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final roleAsync = ref.watch(adminRoleProvider);
    final myRole = roleAsync.value ?? AdminRole.user;

    if (myRole != AdminRole.superadmin) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 64, color: AdminColors.textSecondary),
            SizedBox(height: 12),
            Text('Chỉ Superadmin mới có quyền truy cập',
                style: TextStyle(color: AdminColors.textSecondary)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tìm người dùng để thay đổi vai trò', style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Email hoặc UID',
                    prefixIcon: Icon(Icons.person_search_outlined),
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
          if (_searchError != null) ...[
            const SizedBox(height: 12),
            Text(_searchError!, style: const TextStyle(color: AdminColors.danger)),
          ],
          if (_foundUser != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AdminColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AdminColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AdminColors.primary.withValues(alpha: 0.2),
                      child: Text(
                        ((_foundUser!['displayName'] as String?)?.isNotEmpty == true
                                ? (_foundUser!['displayName'] as String)[0]
                                : (_foundUser!['email'] as String? ?? 'U')[0])
                            .toUpperCase(),
                        style: const TextStyle(color: AdminColors.primary),
                      ),
                    ),
                    title: Text(_foundUser!['displayName'] as String? ?? 'Chưa đặt tên',
                        style: theme.textTheme.titleMedium),
                    subtitle: Text(_foundUser!['email'] as String? ?? ''),
                  ),
                  const SizedBox(height: 16),
                  Text('Vai trò mới', style: theme.textTheme.bodySmall),
                  const SizedBox(height: 8),
                  ..._roleOptions.map((opt) {
                    return RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      value: opt.value,
                      groupValue: _selectedRole,
                      onChanged: (v) => setState(() => _selectedRole = v),
                      title: Text(opt.label),
                      subtitle: Text(opt.desc, style: theme.textTheme.bodySmall),
                      activeColor: AdminColors.primary,
                    );
                  }),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      child: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Lưu thay đổi'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
