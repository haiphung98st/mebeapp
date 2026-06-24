import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/models/diaper_entry.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/baby_provider.dart';
import '../../../../shared/providers/diaper_provider.dart';

class DiaperDetailDialog extends ConsumerStatefulWidget {
  const DiaperDetailDialog({super.key, required this.initialType});

  final DiaperType initialType;

  @override
  ConsumerState<DiaperDetailDialog> createState() => _DiaperDetailDialogState();
}

class _DiaperDetailDialogState extends ConsumerState<DiaperDetailDialog> {
  late DiaperType _type = widget.initialType;
  String? _color;
  late DateTime _time = DateTime.now();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ghi chi tiết thay tã'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Loại', style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: DiaperType.values.map((type) {
                return ChoiceChip(
                  label: Text('${diaperTypeIcon(type)} ${diaperTypeLabel(type)}'),
                  selected: _type == type,
                  onSelected: (_) => setState(() => _type = type),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Màu tã', style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: diaperColorGuide.map((option) {
                return ChoiceChip(
                  avatar: CircleAvatar(backgroundColor: option.color, radius: 8),
                  label: Text(option.name),
                  selected: _color == option.name,
                  onSelected: (_) => setState(() => _color = _color == option.name ? null : option.name),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Thời gian', style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              onPressed: _pickTime,
              child: Text(
                '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}',
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Ghi chú'),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Huỷ')),
        FilledButton(onPressed: _save, child: const Text('Lưu')),
      ],
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_time),
    );
    if (picked == null) return;
    setState(() {
      _time = DateTime(_time.year, _time.month, _time.day, picked.hour, picked.minute);
    });
  }

  void _save() {
    final user = ref.read(currentUserProvider);
    final baby = ref.read(activeBabyProvider);
    if (user == null || baby == null) return;

    final entry = DiaperEntry(
      id: ref.read(firestoreServiceProvider).newId(),
      babyId: baby.id,
      userId: user.uid,
      time: _time,
      type: _type,
      color: _color,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      createdAt: DateTime.now(),
    );
    ref.read(diaperRepositoryProvider).addDiaper(entry);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã ghi thay tã ✓')),
    );
  }
}
