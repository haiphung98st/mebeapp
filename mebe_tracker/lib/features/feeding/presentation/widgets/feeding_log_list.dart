import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/models/feeding_entry.dart';
import '../../../../shared/providers/feeding_provider.dart';
import '../bottle_manual_sheet.dart';
import '../breastfeeding_manual_sheet.dart';

String _titleFor(FeedingType type) {
  switch (type) {
    case FeedingType.breastLeft:
      return 'Bú mẹ · Bên trái';
    case FeedingType.breastRight:
      return 'Bú mẹ · Bên phải';
    case FeedingType.bottle:
      return 'Bú bình';
    case FeedingType.solid:
      return 'Ăn dặm';
  }
}

String _subtitleFor(FeedingEntry entry) {
  switch (entry.type) {
    case FeedingType.breastLeft:
    case FeedingType.breastRight:
      return '${entry.durationMinutes ?? 0} phút';
    case FeedingType.bottle:
      return '${entry.amountMl?.toStringAsFixed(0) ?? 0} ml';
    case FeedingType.solid:
      return entry.notes ?? '';
  }
}

class FeedingLogList extends ConsumerWidget {
  const FeedingLogList({super.key, required this.entries, required this.emptyLabel});

  final List<FeedingEntry> entries;
  final String emptyLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: Center(
          child: Text(emptyLabel, style: AppTextStyles.bodyMd),
        ),
      );
    }

    return Column(
      children: entries
          .map(
            (entry) => Dismissible(
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
              onDismissed: (_) => _delete(ref, entry),
              child: GestureDetector(
                onTap: () => _openEdit(context, entry),
                child: Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.blossom.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_titleFor(entry.type), style: AppTextStyles.bodyLg),
                            const SizedBox(height: 2),
                            Text(_subtitleFor(entry), style: AppTextStyles.bodySm),
                          ],
                        ),
                      ),
                      Text(formatTime(entry.startTime), style: AppTextStyles.bodySm),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  void _openEdit(BuildContext context, FeedingEntry entry) {
    switch (entry.type) {
      case FeedingType.breastLeft:
      case FeedingType.breastRight:
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => BreastfeedingManualSheet(existing: entry),
        );
      case FeedingType.bottle:
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => BottleManualSheet(existing: entry),
        );
      case FeedingType.solid:
        break;
    }
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xoá cữ bú?'),
        content: const Text('Bạn có chắc muốn xoá cữ bú này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _delete(WidgetRef ref, FeedingEntry entry) {
    ref.read(feedingRepositoryProvider).deleteFeeding(entry.userId, entry.babyId, entry.id);
  }
}
