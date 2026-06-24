import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/baby_provider.dart';
import '../../../../shared/providers/milestone_provider.dart';

class MilestonesSection extends ConsumerWidget {
  const MilestonesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baby = ref.watch(activeBabyProvider);
    final items = ref.watch(milestoneViewListProvider);
    final ageWeeks = baby == null
        ? 0
        : DateTime.now().difference(baby.dateOfBirth).inDays ~/ 7;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xxxl,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => _MilestoneItem(item: items[index], ageWeeks: ageWeeks),
    );
  }
}

Color _statusColor(MilestoneStatus status) {
  switch (status) {
    case MilestoneStatus.achieved:
      return AppColors.success;
    case MilestoneStatus.inProgress:
      return AppColors.warning;
    case MilestoneStatus.notYet:
      return AppColors.muted;
  }
}

String _statusLabel(MilestoneStatus status) {
  switch (status) {
    case MilestoneStatus.achieved:
      return 'Đã đạt';
    case MilestoneStatus.inProgress:
      return 'Đang theo dõi';
    case MilestoneStatus.notYet:
      return 'Chưa tới';
  }
}

class _MilestoneItem extends ConsumerWidget {
  const _MilestoneItem({required this.item, required this.ageWeeks});

  final MilestoneViewItem item;
  final int ageWeeks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = item.statusAt(ageWeeks);
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
              status == MilestoneStatus.achieved ? Icons.check_circle : Icons.circle,
              color: color,
              size: 22,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.def.titleVi, style: AppTextStyles.bodyLg),
                  Text(
                    item.entry?.achievedAt != null
                        ? 'Đạt ngày ${_formatDate(item.entry!.achievedAt!)}'
                        : '${item.def.expectedWeekMin}-${item.def.expectedWeekMax} tuần tuổi',
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
    showDialog(
      context: context,
      builder: (context) => _MarkMilestoneDialog(item: item),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

class _MarkMilestoneDialog extends ConsumerStatefulWidget {
  const _MarkMilestoneDialog({required this.item});

  final MilestoneViewItem item;

  @override
  ConsumerState<_MarkMilestoneDialog> createState() => _MarkMilestoneDialogState();
}

class _MarkMilestoneDialogState extends ConsumerState<_MarkMilestoneDialog> {
  late DateTime _achievedAt = widget.item.entry?.achievedAt ?? DateTime.now();
  final _photoController = TextEditingController();

  @override
  void dispose() {
    _photoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAchieved = widget.item.isAchieved;
    return AlertDialog(
      title: Text(isAchieved ? 'Sửa ngày đạt mốc' : 'Ghi nhận mốc đạt được'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.item.def.titleVi, style: AppTextStyles.bodyLg),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton(
            onPressed: _pickDate,
            child: Text(
              '${_achievedAt.day.toString().padLeft(2, '0')}/'
              '${_achievedAt.month.toString().padLeft(2, '0')}/${_achievedAt.year}',
            ),
          ),
          if (!isAchieved) ...[
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _photoController,
              decoration: const InputDecoration(labelText: 'Link ảnh (không bắt buộc)'),
            ),
          ],
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
      initialDate: _achievedAt,
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() => _achievedAt = picked);
  }

  void _save() {
    final user = ref.read(currentUserProvider);
    final baby = ref.read(activeBabyProvider);
    if (user == null || baby == null) return;

    if (widget.item.isAchieved) {
      ref.read(milestoneRepositoryProvider).updateAchievedDate(
            widget.item.entry!,
            userId: user.uid,
            achievedAt: _achievedAt,
          );
    } else {
      ref.read(milestoneRepositoryProvider).markAchieved(
            widget.item,
            userId: user.uid,
            babyId: baby.id,
            achievedAt: _achievedAt,
            photoUrl: _photoController.text.trim().isEmpty ? null : _photoController.text.trim(),
          );
    }
    Navigator.of(context).pop();
  }
}
