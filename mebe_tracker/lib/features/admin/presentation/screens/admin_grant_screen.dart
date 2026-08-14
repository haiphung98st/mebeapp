import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_toast.dart';
import '../../data/admin_provider.dart';
import '../admin_utils.dart';
import '../widgets/grant_bottom_sheet.dart';

class AdminGrantScreen extends ConsumerStatefulWidget {
  const AdminGrantScreen({super.key});

  @override
  ConsumerState<AdminGrantScreen> createState() => _AdminGrantScreenState();
}

class _AdminGrantScreenState extends ConsumerState<AdminGrantScreen>
    with SingleTickerProviderStateMixin {
  late final _tabController = TabController(length: 2, vsync: this);
  final _singleController = TextEditingController();
  final _bulkController = TextEditingController();
  int _selectedDurationIndex = 1;
  String _selectedReason = kGrantReasons.first;
  bool _isSingleSearching = false;
  Map<String, dynamic>? _foundUser;
  String? _singleError;
  bool _isBulkGranting = false;
  Map<String, String> _bulkResults = {};

  @override
  void dispose() {
    _tabController.dispose();
    _singleController.dispose();
    _bulkController.dispose();
    super.dispose();
  }

  Future<void> _singleSearch() async {
    final query = _singleController.text.trim();
    if (query.isEmpty) return;
    setState(() {
      _isSingleSearching = true;
      _foundUser = null;
      _singleError = null;
    });
    try {
      final isEmail = query.contains('@');
      final result = await ref.read(adminNotifierProvider.notifier).getUser(
            uid: isEmail ? null : query,
            email: isEmail ? query : null,
          );
      if (mounted) setState(() => _foundUser = result);
    } catch (e) {
      if (mounted) setState(() => _singleError = 'Không tìm thấy: $e');
    } finally {
      if (mounted) setState(() => _isSingleSearching = false);
    }
  }

  Future<void> _bulkGrant() async {
    final lines = _bulkController.text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    if (lines.isEmpty) return;

    setState(() {
      _isBulkGranting = true;
      _bulkResults = {};
    });

    final duration = kGrantDurations[_selectedDurationIndex];
    final results = <String, String>{};

    for (final line in lines) {
      try {
        final isEmail = line.contains('@');
        Map<String, dynamic> user;
        try {
          user = await ref.read(adminNotifierProvider.notifier).getUser(
                uid: isEmail ? null : line,
                email: isEmail ? line : null,
              );
        } catch (_) {
          results[line] = '❌ Không tìm thấy';
          continue;
        }
        await ref.read(adminNotifierProvider.notifier).grantPremium(
              uid: user['uid'] as String,
              durationDays: duration.days,
              reason: _selectedReason,
            );
        results[line] = '✅ OK';
      } catch (e) {
        results[line] = '❌ $e';
      }
    }

    if (mounted) {
      setState(() {
        _isBulkGranting = false;
        _bulkResults = results;
      });
      final success = results.values.where((v) => v.startsWith('✅')).length;
      AppToast.success(context, 'Cấp Premium: $success/${lines.length} thành công');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.hintColor,
          indicatorColor: theme.colorScheme.primary,
          tabs: const [
            Tab(text: 'Cấp đơn'),
            Tab(text: 'Cấp nhiều'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildSingleTab(theme),
              _buildBulkTab(theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSingleTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _singleController,
                  decoration: const InputDecoration(
                    labelText: 'Email hoặc UID',
                    prefixIcon: Icon(Icons.person_search_outlined),
                  ),
                  onSubmitted: (_) => _singleSearch(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isSingleSearching ? null : _singleSearch,
                child: _isSingleSearching
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Tìm'),
              ),
            ],
          ),
          if (_singleError != null) ...[
            const SizedBox(height: 12),
            Text(_singleError!, style: const TextStyle(color: Color(0xFFFF4757))),
          ],
          if (_foundUser != null) ...[
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                child: Text(
                  ((_foundUser!['displayName'] as String?)?.isNotEmpty == true
                          ? (_foundUser!['displayName'] as String)[0]
                          : (_foundUser!['email'] as String? ?? 'U')[0])
                      .toUpperCase(),
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
              ),
              title: Text(_foundUser!['displayName'] as String? ?? 'Chưa đặt tên'),
              subtitle: Text(_foundUser!['email'] as String? ?? ''),
              trailing: ElevatedButton(
                onPressed: () => showGrantBottomSheet(
                  context,
                  uid: _foundUser!['uid'] as String,
                  displayName:
                      _foundUser!['displayName'] as String? ?? _foundUser!['email'] as String? ?? 'User',
                ),
                child: const Text('Cấp'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBulkTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Thời hạn', style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(kGrantDurations.length, (i) {
              final d = kGrantDurations[i];
              return ChoiceChip(
                label: Text(d.label),
                selected: _selectedDurationIndex == i,
                onSelected: (_) => setState(() => _selectedDurationIndex = i),
              );
            }),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedReason,
            dropdownColor: theme.colorScheme.surface,
            items: kGrantReasons.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
            onChanged: (v) => setState(() => _selectedReason = v!),
            decoration: const InputDecoration(labelText: 'Lý do cấp'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _bulkController,
            maxLines: 8,
            decoration: const InputDecoration(
              labelText: 'Danh sách email / UID (mỗi dòng một)',
              hintText: 'user1@example.com\nuser2@example.com\n...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isBulkGranting ? null : _bulkGrant,
              icon: _isBulkGranting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.star_outline, size: 18),
              label: Text(_isBulkGranting ? 'Đang cấp...' : 'Cấp Premium hàng loạt'),
            ),
          ),
          if (_bulkResults.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text('Kết quả', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            ..._bulkResults.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(e.key,
                          style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    Text(e.value, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
