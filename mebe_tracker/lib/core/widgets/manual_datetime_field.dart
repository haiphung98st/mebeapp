import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

/// Tappable field for manual-entry forms: shows a date+time value, opens a
/// date picker then a time picker in sequence, and reports the combined
/// [DateTime] back through [onChanged].
class ManualDateTimeField extends StatelessWidget {
  const ManualDateTimeField({
    super.key,
    required this.value,
    required this.label,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
  });

  final DateTime value;
  final String label;
  final ValueChanged<DateTime> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;

  @override
  Widget build(BuildContext context) {
    final effectiveFirstDate = firstDate ?? DateTime.now().subtract(const Duration(days: 30));
    final effectiveLastDate = lastDate ?? DateTime.now();

    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      onTap: () => _pick(context, effectiveFirstDate, effectiveLastDate),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.powder,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.blush),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.blossom),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.label),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('dd/MM/yyyy  HH:mm').format(value),
                    style: AppTextStyles.bodyMd.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit_outlined, size: 16, color: AppColors.muted),
          ],
        ),
      ),
    );
  }

  Future<void> _pick(BuildContext context, DateTime firstDate, DateTime lastDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: value.isAfter(lastDate) ? lastDate : (value.isBefore(firstDate) ? firstDate : value),
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Chọn ngày',
      cancelText: 'Huỷ',
      confirmText: 'Tiếp theo',
    );
    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(value),
      helpText: 'Chọn giờ',
      cancelText: 'Huỷ',
      confirmText: 'Xong',
    );
    if (time == null) return;

    onChanged(DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }
}
