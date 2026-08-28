import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/models/pump_entry.dart';
import '../../../../shared/providers/pump_provider.dart';
import '../pump_manual_sheet.dart';

String _dateGroupLabel(DateTime date) {
  final today = DateTime.now();
  if (isSameDay(date, today)) return 'Hôm nay';
  final yesterday = today.subtract(const Duration(days: 1));
  if (isSameDay(date, yesterday)) return 'Hôm qua';
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
}

/// Recent pump sessions, grouped by day, newest first. Tap to edit, swipe to
/// delete.
class PumpLogList extends ConsumerWidget {
  const PumpLogList({super.key, required this.entries});

  final List<PumpEntry> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: Center(child: Text('Chưa có phiên hút sữa nào', style: AppTextStyles.bodyMd)),
      );
    }

    final sorted = [...entries]..sort((a, b) => b.startTime.compareTo(a.startTime));
    final grouped = <String, List<PumpEntry>>{};
    for (final entry in sorted) {
      final key = _dateGroupLabel(startOfDay(entry.startTime));
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
              ...group.value.map((entry) => _PumpLogItem(entry: entry)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _PumpLogItem extends ConsumerWidget {
  const _PumpLogItem({required this.entry});

  final PumpEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = (entry.leftAmountMl ?? 0) + (entry.rightAmountMl ?? 0);

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
          ref.read(pumpRepositoryProvider).deletePump(entry.userId, entry.babyId, entry.id),
      child: GestureDetector(
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => PumpManualSheet(existing: entry),
        ),
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
              const Text('🥛', style: TextStyle(fontSize: 18)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${total.toStringAsFixed(0)} ml', style: AppTextStyles.bodyLg),
                    Text(
                      'T: ${(entry.leftAmountMl ?? 0).toStringAsFixed(0)}ml · '
                      'P: ${(entry.rightAmountMl ?? 0).toStringAsFixed(0)}ml',
                      style: AppTextStyles.bodySm,
                    ),
                  ],
                ),
              ),
              Text(formatTime(entry.startTime), style: AppTextStyles.bodySm),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xoá phiên hút sữa?'),
        content: const Text('Bạn có chắc muốn xoá phiên hút sữa này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Huỷ')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Xoá')),
        ],
      ),
    );
    return result ?? false;
  }
}
