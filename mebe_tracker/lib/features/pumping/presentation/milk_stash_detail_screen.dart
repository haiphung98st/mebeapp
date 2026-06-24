import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/models/milk_stash_entry.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/baby_provider.dart';
import '../../../shared/providers/pump_provider.dart';

String _locationLabel(StashLocation location) =>
    location == StashLocation.freezer ? 'Tủ đông' : 'Tủ mát';

class MilkStashDetailScreen extends ConsumerWidget {
  const MilkStashDetailScreen({super.key, required this.location});

  final StashLocation location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stash = ref
        .watch(unusedMilkStashProvider)
        .where((e) => e.location == location)
        .toList()
      ..sort((a, b) => (a.expiresAt ?? a.pumpedAt).compareTo(b.expiresAt ?? b.pumpedAt));

    return Scaffold(
      backgroundColor: AppColors.powder,
      appBar: AppBar(
        title: Text(_locationLabel(location)),
        backgroundColor: AppColors.powder,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.lavender,
        onPressed: () => _showAddStashDialog(context, ref),
        child: const Icon(Icons.add, color: AppColors.white),
      ),
      body: stash.isEmpty
          ? Center(child: Text('Chưa có túi sữa nào', style: AppTextStyles.bodyMd))
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: stash.length,
              itemBuilder: (context, index) {
                final entry = stash[index];
                return _StashListItem(entry: entry);
              },
            ),
    );
  }

  Future<void> _showAddStashDialog(BuildContext context, WidgetRef ref) async {
    await showDialog<void>(
      context: context,
      builder: (context) => _AddStashDialog(location: location),
    );
  }
}

class _StashListItem extends ConsumerWidget {
  const _StashListItem({required this.entry});

  final MilkStashEntry entry;

  Color _badgeColor() {
    if (entry.expiresAt == null) return AppColors.muted;
    final daysLeft = entry.expiresAt!.difference(DateTime.now()).inDays;
    if (daysLeft <= 2) return AppColors.warning;
    return AppColors.mint;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: const Icon(Icons.delete, color: AppColors.white),
      ),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) =>
          ref.read(pumpRepositoryProvider).deleteMilkStash(entry.userId, entry.babyId, entry.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          boxShadow: [
            BoxShadow(
              color: AppColors.lavender.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 40,
              decoration: BoxDecoration(
                color: _badgeColor(),
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${entry.amountMl.toStringAsFixed(0)}ml', style: AppTextStyles.bodyLg),
                  Text(
                    'Hút ${_formatDate(entry.pumpedAt)}'
                    '${entry.expiresAt != null ? ' · HSD ${_formatDate(entry.expiresAt!)}' : ''}',
                    style: AppTextStyles.bodySm,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => ref.read(pumpRepositoryProvider).markStashUsed(entry),
              child: const Text('Đã dùng'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xoá túi sữa?'),
        content: const Text('Bạn có chắc muốn xoá túi sữa này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Huỷ')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Xoá')),
        ],
      ),
    );
    return result ?? false;
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}';
}

class _AddStashDialog extends ConsumerStatefulWidget {
  const _AddStashDialog({required this.location});

  final StashLocation location;

  @override
  ConsumerState<_AddStashDialog> createState() => _AddStashDialogState();
}

class _AddStashDialogState extends ConsumerState<_AddStashDialog> {
  final _amountController = TextEditingController(text: '100');
  late DateTime _pumpedAt;
  late StashLocation _location;

  @override
  void initState() {
    super.initState();
    _pumpedAt = DateTime.now();
    _location = widget.location;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thêm túi sữa'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Số ml'),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text('Tủ mát'),
                  selected: _location == StashLocation.fridge,
                  onSelected: (_) => setState(() => _location = StashLocation.fridge),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ChoiceChip(
                  label: const Text('Tủ đông'),
                  selected: _location == StashLocation.freezer,
                  onSelected: (_) => setState(() => _location = StashLocation.freezer),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Huỷ')),
        FilledButton(onPressed: () => _save(context), child: const Text('Lưu')),
      ],
    );
  }

  Future<void> _save(BuildContext context) async {
    final user = ref.read(currentUserProvider);
    final baby = ref.read(activeBabyProvider);
    if (user == null || baby == null) return;
    final amountMl = double.tryParse(_amountController.text) ?? 0;
    if (amountMl <= 0) return;
    final now = DateTime.now();
    final entry = MilkStashEntry(
      id: ref.read(firestoreServiceProvider).newId(),
      babyId: baby.id,
      userId: user.uid,
      pumpedAt: _pumpedAt,
      expiresAt: defaultExpiryFor(_location, _pumpedAt),
      amountMl: amountMl,
      location: _location,
      isUsed: false,
      createdAt: now,
    );
    await ref.read(pumpRepositoryProvider).addMilkStash(entry);
    if (context.mounted) Navigator.of(context).pop();
  }
}
