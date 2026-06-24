import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/error_handling.dart';
import '../../../../shared/models/growth_entry.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/baby_provider.dart';
import '../../../../shared/providers/growth_provider.dart';

class AddGrowthDialog extends ConsumerStatefulWidget {
  const AddGrowthDialog({super.key});

  @override
  ConsumerState<AddGrowthDialog> createState() => _AddGrowthDialogState();
}

class _AddGrowthDialogState extends ConsumerState<AddGrowthDialog> {
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _headController = TextEditingController();
  DateTime _measuredAt = DateTime.now();

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _headController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thêm số đo'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _weightController,
              decoration: const InputDecoration(labelText: 'Cân nặng (kg)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _heightController,
              decoration: const InputDecoration(labelText: 'Chiều cao (cm)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _headController,
              decoration: const InputDecoration(labelText: 'Vòng đầu (cm)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: AppSpacing.lg),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Ngày đo', style: AppTextStyles.label),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              onPressed: _pickDate,
              child: Text(
                '${_measuredAt.day.toString().padLeft(2, '0')}/'
                '${_measuredAt.month.toString().padLeft(2, '0')}/${_measuredAt.year}',
              ),
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _measuredAt,
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() => _measuredAt = picked);
  }

  void _save() {
    final user = ref.read(currentUserProvider);
    final baby = ref.read(activeBabyProvider);
    if (user == null || baby == null) return;

    final weight = double.tryParse(_weightController.text.replaceAll(',', '.'));
    final height = double.tryParse(_heightController.text.replaceAll(',', '.'));
    final head = double.tryParse(_headController.text.replaceAll(',', '.'));
    if (weight == null && height == null && head == null) return;

    final entry = GrowthEntry(
      id: ref.read(firestoreServiceProvider).newId(),
      babyId: baby.id,
      userId: user.uid,
      measuredAt: _measuredAt,
      weightKg: weight,
      heightCm: height,
      headCircumferenceCm: head,
      createdAt: DateTime.now(),
    );
    runWriteAction(
      context,
      () => ref.read(growthRepositoryProvider).addGrowth(entry),
      onSuccess: () => Navigator.of(context).pop(),
    );
  }
}
