import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/error_handling.dart';
import '../../../../shared/models/diaper_entry.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/baby_provider.dart';
import '../../../../shared/providers/diaper_provider.dart';
import 'diaper_detail_dialog.dart';

class QuickLogSection extends ConsumerWidget {
  const QuickLogSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: DiaperType.values
          .map(
            (type) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: _QuickLogButton(type: type),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _QuickLogButton extends ConsumerWidget {
  const _QuickLogButton({required this.type});

  final DiaperType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _quickSave(context, ref),
      onLongPress: () => showDialog(
        context: context,
        builder: (context) => DiaperDetailDialog(initialType: type),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          color: diaperTypeColor(type).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: diaperTypeColor(type).withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            Text(diaperTypeIcon(type), style: const TextStyle(fontSize: 28)),
            const SizedBox(height: AppSpacing.xs),
            Text(diaperTypeLabel(type), style: AppTextStyles.bodyMd),
          ],
        ),
      ),
    );
  }

  void _quickSave(BuildContext context, WidgetRef ref) {
    final user = ref.read(currentUserProvider);
    final baby = ref.read(activeBabyProvider);
    if (user == null || baby == null) return;

    final entry = DiaperEntry(
      id: ref.read(firestoreServiceProvider).newId(),
      babyId: baby.id,
      userId: user.uid,
      time: DateTime.now(),
      type: type,
      createdAt: DateTime.now(),
    );
    runWriteAction(
      context,
      () => ref.read(diaperRepositoryProvider).addDiaper(entry),
      successMessage: 'Đã ghi thay tã ✓',
    );
  }
}
