import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/duration_utils.dart';
import '../../../../shared/models/sleep_entry.dart';
import '../../../../shared/providers/sleep_provider.dart';
import '../sleep_manual_sheet.dart';

String _dateGroupLabel(DateTime date) {
  final today = DateTime.now();
  if (isSameDay(date, today)) return 'Hôm nay';
  final yesterday = today.subtract(const Duration(days: 1));
  if (isSameDay(date, yesterday)) return 'Hôm qua';
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
}

class SleepHistoryList extends ConsumerWidget {
  const SleepHistoryList({super.key, required this.entries});

  final List<SleepEntry> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: Center(child: Text('Chưa có giấc ngủ nào', style: AppTextStyles.bodyMd)),
      );
    }

    final grouped = <String, List<SleepEntry>>{};
    for (final entry in entries) {
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
              ...group.value.map((entry) => _SleepHistoryItem(entry: entry)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _SleepHistoryItem extends ConsumerWidget {
  const _SleepHistoryItem({required this.entry});

  final SleepEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOngoing = entry.endTime == null;
    final duration = entry.durationMinutes != null
        ? formatMinutesShort(entry.durationMinutes!)
        : '—';

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
          ref.read(sleepRepositoryProvider).deleteSleep(entry.userId, entry.babyId, entry.id),
      child: GestureDetector(
        onTap: isOngoing
            ? null
            : () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => SleepManualSheet(existing: entry),
                ),
        child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: isOngoing ? const Border(left: BorderSide(color: AppColors.lavender, width: 3)) : null,
          boxShadow: [
            BoxShadow(
              color: AppColors.nightMid.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(sleepIcon(entry), style: const TextStyle(fontSize: 20)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sleepLabel(entry), style: AppTextStyles.bodyLg),
                  Text(
                    '${formatTime(entry.startTime)}'
                    '${entry.endTime != null ? ' – ${formatTime(entry.endTime!)}' : ' – đang ngủ'}',
                    style: AppTextStyles.bodySm,
                  ),
                ],
              ),
            ),
            Text(
              duration,
              style: AppTextStyles.bodyLg.copyWith(
                color: isOngoing ? AppColors.lavender : AppColors.body,
                fontWeight: FontWeight.w800,
              ),
            ),
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
        title: const Text('Xoá giấc ngủ?'),
        content: const Text('Bạn có chắc muốn xoá giấc ngủ này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Huỷ')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Xoá')),
        ],
      ),
    );
    return result ?? false;
  }
}
