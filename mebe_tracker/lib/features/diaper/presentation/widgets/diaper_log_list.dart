import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/models/diaper_entry.dart';
import '../../../../shared/providers/diaper_provider.dart';

String _dateGroupLabel(DateTime date) {
  final today = DateTime.now();
  if (isSameDay(date, today)) return 'Hôm nay';
  final yesterday = today.subtract(const Duration(days: 1));
  if (isSameDay(date, yesterday)) return 'Hôm qua';
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
}

class DiaperLogList extends ConsumerWidget {
  const DiaperLogList({super.key, required this.entries});

  final List<DiaperEntry> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: Center(child: Text('Chưa có lần thay tã nào', style: AppTextStyles.bodyMd)),
      );
    }

    final sorted = [...entries]..sort((a, b) => b.time.compareTo(a.time));
    final grouped = <String, List<DiaperEntry>>{};
    for (final entry in sorted) {
      final key = _dateGroupLabel(startOfDay(entry.time));
      grouped.putIfAbsent(key, () => []).add(entry);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grouped.entries.map((group) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(group.key, style: AppTextStyles.label),
              ),
              ...group.value.map((entry) => _DiaperLogItem(entry: entry)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _DiaperLogItem extends ConsumerWidget {
  const _DiaperLogItem({required this.entry});

  final DiaperEntry entry;

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
          ref.read(diaperRepositoryProvider).deleteDiaper(entry.userId, entry.babyId, entry.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          boxShadow: [
            BoxShadow(
              color: AppColors.mint.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: diaperTypeColor(entry.type), shape: BoxShape.circle),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(diaperTypeIcon(entry.type), style: const TextStyle(fontSize: 18)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    diaperTypeLabel(entry.type) + (entry.color != null ? ' · ${entry.color}' : ''),
                    style: AppTextStyles.bodyLg,
                  ),
                  if (entry.notes != null && entry.notes!.isNotEmpty)
                    Text(entry.notes!, style: AppTextStyles.bodySm),
                ],
              ),
            ),
            Text(formatTime(entry.time), style: AppTextStyles.bodySm),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xoá lần thay tã?'),
        content: const Text('Bạn có chắc muốn xoá lần thay tã này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Huỷ')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Xoá')),
        ],
      ),
    );
    return result ?? false;
  }
}
