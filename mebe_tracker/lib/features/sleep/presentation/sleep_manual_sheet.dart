import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/error_handling.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/manual_datetime_field.dart';
import '../../../core/widgets/sheet_handle.dart';
import '../../../shared/models/sleep_entry.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/baby_provider.dart';
import '../../../shared/providers/sleep_provider.dart';

String _qualityLabel(SleepQuality quality) {
  switch (quality) {
    case SleepQuality.good:
      return '😊 Ngon';
    case SleepQuality.fair:
      return '😐 Bình thường';
    case SleepQuality.poor:
      return '😴 Hay quấy';
  }
}

/// Manual create/edit form for a sleep entry. Pass [existing] to edit (and
/// allow deleting) a previously logged entry.
class SleepManualSheet extends ConsumerStatefulWidget {
  const SleepManualSheet({super.key, this.existing});

  final SleepEntry? existing;

  @override
  ConsumerState<SleepManualSheet> createState() => _SleepManualSheetState();
}

class _SleepManualSheetState extends ConsumerState<SleepManualSheet> {
  late DateTime _startTime;
  late DateTime _endTime;
  late SleepType _type;
  SleepQuality? _quality;
  late final TextEditingController _notesController;

  int get _durationMin => _endTime.difference(_startTime).inMinutes;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _startTime = e?.startTime ?? DateTime.now().subtract(const Duration(hours: 1, minutes: 30));
    _endTime = e?.endTime ?? DateTime.now();
    _type = e?.type ?? SleepType.nap;
    _quality = e?.quality;
    _notesController = TextEditingController(text: e?.notes ?? '');
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.powder,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
        ),
        child: Column(
          children: [
            const SheetHandle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  Text(
                    widget.existing == null ? '🌙 Ghi giấc ngủ' : '🌙 Chỉnh sửa giấc ngủ',
                    style: AppTextStyles.headingLg,
                  ),
                  const Spacer(),
                  if (widget.existing != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                      onPressed: _confirmDelete,
                    ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Loại giấc', style: AppTextStyles.headingSm),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _TypeCard(
                            label: '☀️ Ngủ ngày',
                            selected: _type == SleepType.nap,
                            onTap: () => setState(() => _type = SleepType.nap),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _TypeCard(
                            label: '🌙 Ngủ đêm',
                            selected: _type == SleepType.night,
                            onTap: () => setState(() => _type = SleepType.night),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ManualDateTimeField(
                      label: 'Bắt đầu ngủ',
                      value: _startTime,
                      onChanged: (dt) => setState(() => _startTime = dt),
                    ),
                    const SizedBox(height: 12),
                    ManualDateTimeField(
                      label: 'Thức dậy',
                      value: _endTime,
                      onChanged: (dt) => setState(() => _endTime = dt),
                    ),
                    if (_durationMin > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.lilac,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '⏱ ${_durationMin ~/ 60}h ${_durationMin % 60}ph',
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.lavender,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    Text('Chất lượng', style: AppTextStyles.headingSm),
                    const SizedBox(height: 8),
                    Row(
                      children: SleepQuality.values
                          .map(
                            (q) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: _QualityButton(
                                  label: _qualityLabel(q),
                                  selected: _quality == q,
                                  onTap: () => setState(() => _quality = _quality == q ? null : q),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _notesController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Ghi chú',
                        hintText: 'vd: ngủ sâu, thức vài lần...',
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: AppColors.gradientSleep,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                        child: TextButton(
                          onPressed: _save,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                            foregroundColor: AppColors.white,
                          ),
                          child: Text(
                            widget.existing == null ? 'Lưu giấc ngủ' : 'Cập nhật',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_durationMin <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giờ kết thúc phải sau giờ bắt đầu!')),
      );
      return;
    }
    final user = ref.read(currentUserProvider);
    final baby = ref.read(activeBabyProvider);
    if (user == null || baby == null) return;

    final notes = _notesController.text.trim();
    final entry = SleepEntry(
      id: widget.existing?.id ?? ref.read(firestoreServiceProvider).newId(),
      babyId: baby.id,
      userId: user.uid,
      startTime: _startTime,
      endTime: _endTime,
      durationMinutes: _durationMin,
      type: _type,
      quality: _quality,
      notes: notes.isEmpty ? null : notes,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );

    await runWriteAction(
      context,
      () => ref.read(sleepRepositoryProvider).addSleep(entry),
      successMessage: 'Đã lưu giấc ngủ ✓',
      onSuccess: () => Navigator.of(context).pop(true),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Xoá giấc ngủ?',
      content: 'Hành động này không thể hoàn tác.',
      confirmLabel: 'Xoá',
      confirmColor: AppColors.error,
    );
    if (confirmed != true || !mounted) return;

    final existing = widget.existing!;
    await runWriteAction(
      context,
      () => ref.read(sleepRepositoryProvider).deleteSleep(existing.userId, existing.babyId, existing.id),
      onSuccess: () => Navigator.of(context).pop(true),
    );
  }
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.lavender : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: selected ? AppColors.lavender : AppColors.blush, width: selected ? 2 : 1),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMd.copyWith(
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.white : AppColors.body,
          ),
        ),
      ),
    );
  }
}

class _QualityButton extends StatelessWidget {
  const _QualityButton({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: selected ? AppColors.lavender.withValues(alpha: 0.2) : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: selected ? AppColors.lavender : AppColors.blush),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySm.copyWith(
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.lavender : AppColors.body,
          ),
        ),
      ),
    );
  }
}
