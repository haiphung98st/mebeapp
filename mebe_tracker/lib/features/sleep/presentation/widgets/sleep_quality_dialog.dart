import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/duration_utils.dart';
import '../../../../shared/models/sleep_entry.dart';
import '../../../../shared/providers/sleep_provider.dart';

class SleepQualityDialog extends ConsumerStatefulWidget {
  const SleepQualityDialog({super.key, required this.entry});

  final SleepEntry entry;

  @override
  ConsumerState<SleepQualityDialog> createState() => _SleepQualityDialogState();
}

class _SleepQualityDialogState extends ConsumerState<SleepQualityDialog> {
  final _notesController = TextEditingController();
  SleepQuality? _quality;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duration = Duration(minutes: widget.entry.durationMinutes ?? 0);

    return AlertDialog(
      title: const Text('Giấc ngủ thế nào?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Thời lượng: ${formatStopwatch(duration)}', style: AppTextStyles.bodyLg),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _QualityButton(
                emoji: '😊',
                label: 'Ngủ ngon',
                selected: _quality == SleepQuality.good,
                onTap: () => setState(() => _quality = SleepQuality.good),
              ),
              _QualityButton(
                emoji: '😐',
                label: 'Bình thường',
                selected: _quality == SleepQuality.fair,
                onTap: () => setState(() => _quality = SleepQuality.fair),
              ),
              _QualityButton(
                emoji: '😴',
                label: 'Hay quấy',
                selected: _quality == SleepQuality.poor,
                onTap: () => setState(() => _quality = SleepQuality.poor),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(hintText: 'Ghi chú (không bắt buộc)'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => _save(context), child: const Text('Lưu')),
      ],
    );
  }

  Future<void> _save(BuildContext context) async {
    final entry = widget.entry.copyWith(
      quality: _quality,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );
    await ref.read(sleepRepositoryProvider).addSleep(entry);
    if (context.mounted) Navigator.of(context).pop();
  }
}

class _QualityButton extends StatelessWidget {
  const _QualityButton({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected ? AppColors.lilac : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.bodySm),
          ],
        ),
      ),
    );
  }
}
