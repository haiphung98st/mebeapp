import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/baby_provider.dart';
import '../../../../shared/providers/vaccine_provider.dart';

class VaccineSection extends ConsumerWidget {
  const VaccineSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(vaccineViewListProvider);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xxxl,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => _VaccineItem(item: items[index]),
    );
  }
}

Color _statusColor(VaccineStatus status) {
  switch (status) {
    case VaccineStatus.done:
      return AppColors.success;
    case VaccineStatus.upcoming:
      return AppColors.warning;
    case VaccineStatus.notYet:
      return AppColors.muted;
    case VaccineStatus.overdue:
      return AppColors.error;
  }
}

String _statusLabel(VaccineStatus status) {
  switch (status) {
    case VaccineStatus.done:
      return '✓ Xong';
    case VaccineStatus.upcoming:
      return '⏰ Sắp tới';
    case VaccineStatus.notYet:
      return '📅 Chưa tới';
    case VaccineStatus.overdue:
      return '⚠️ Quá hạn';
  }
}

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

class _VaccineItem extends ConsumerWidget {
  const _VaccineItem({required this.item});

  final VaccineViewItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = item.status;
    final color = _statusColor(status);

    return Container(
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
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: () => _onTap(context, ref),
        child: Row(
          children: [
            Icon(
              status == VaccineStatus.done ? Icons.check_circle : Icons.vaccines,
              color: color,
              size: 22,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.def.nameVi, style: AppTextStyles.bodyLg),
                  Text(
                    item.entry?.administeredDate != null
                        ? 'Đã tiêm ngày ${_formatDate(item.entry!.administeredDate!)}'
                        : 'Lịch tiêm: ${_formatDate(item.scheduledDate)}',
                    style: AppTextStyles.bodySm,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: Text(
                _statusLabel(status),
                style: AppTextStyles.bodySm.copyWith(color: color, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTap(BuildContext context, WidgetRef ref) {
    if (item.isCompleted) return;
    showDialog(
      context: context,
      builder: (context) => _MarkVaccineDialog(item: item),
    );
  }
}

class _MarkVaccineDialog extends ConsumerStatefulWidget {
  const _MarkVaccineDialog({required this.item});

  final VaccineViewItem item;

  @override
  ConsumerState<_MarkVaccineDialog> createState() => _MarkVaccineDialogState();
}

class _MarkVaccineDialogState extends ConsumerState<_MarkVaccineDialog> {
  DateTime _administeredDate = DateTime.now();
  final _clinicController = TextEditingController();

  @override
  void dispose() {
    _clinicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ghi nhận đã tiêm'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.item.def.nameVi, style: AppTextStyles.bodyLg),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton(
            onPressed: _pickDate,
            child: Text(
              '${_administeredDate.day.toString().padLeft(2, '0')}/'
              '${_administeredDate.month.toString().padLeft(2, '0')}/${_administeredDate.year}',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _clinicController,
            decoration: const InputDecoration(labelText: 'Nơi tiêm (không bắt buộc)'),
          ),
        ],
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
      initialDate: _administeredDate,
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() => _administeredDate = picked);
  }

  void _save() {
    final user = ref.read(currentUserProvider);
    final baby = ref.read(activeBabyProvider);
    if (user == null || baby == null) return;

    ref.read(vaccineRepositoryProvider).markAdministered(
          widget.item,
          userId: user.uid,
          babyId: baby.id,
          administeredDate: _administeredDate,
          clinicName: _clinicController.text.trim().isEmpty ? null : _clinicController.text.trim(),
        );
    Navigator.of(context).pop();
  }
}
