import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/error_handling.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/manual_datetime_field.dart';
import '../../../core/widgets/manual_number_field.dart';
import '../../../core/widgets/sheet_handle.dart';
import '../../../shared/models/feeding_entry.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/baby_provider.dart';
import '../../../shared/providers/feeding_provider.dart';

/// Manual create/edit form for a breastfeeding session, opened as a
/// draggable bottom sheet. Pass [existing] to edit (and allow deleting) a
/// previously logged entry; omit it to log a new one.
class BreastfeedingManualSheet extends ConsumerStatefulWidget {
  const BreastfeedingManualSheet({super.key, this.existing});

  final FeedingEntry? existing;

  @override
  ConsumerState<BreastfeedingManualSheet> createState() => _BreastfeedingManualSheetState();
}

class _BreastfeedingManualSheetState extends ConsumerState<BreastfeedingManualSheet> {
  late DateTime _startTime;
  late DateTime _endTime;
  late bool _isLeft;
  late int _durationMinutes;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _startTime = e.startTime;
      _durationMinutes = e.durationMinutes ?? 15;
      _endTime = e.endTime ?? e.startTime.add(Duration(minutes: _durationMinutes));
      _isLeft = e.type != FeedingType.breastRight;
      _notesController = TextEditingController(text: e.notes ?? '');
    } else {
      _startTime = DateTime.now().subtract(const Duration(minutes: 15));
      _endTime = DateTime.now();
      _isLeft = true;
      _durationMinutes = 15;
      _notesController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _recalcDuration() {
    final diff = _endTime.difference(_startTime).inMinutes;
    if (diff > 0) setState(() => _durationMinutes = diff);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
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
                    widget.existing == null ? 'Ghi cữ bú mẹ' : 'Chỉnh sửa cữ bú',
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
                    Text('Bên bú', style: AppTextStyles.headingSm),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _SideButton(
                            label: '◀ Trái',
                            selected: _isLeft,
                            onTap: () => setState(() => _isLeft = true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _SideButton(
                            label: 'Phải ▶',
                            selected: !_isLeft,
                            onTap: () => setState(() => _isLeft = false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ManualDateTimeField(
                      label: 'Bắt đầu',
                      value: _startTime,
                      onChanged: (dt) {
                        setState(() {
                          _startTime = dt;
                          if (_endTime.isBefore(_startTime)) {
                            _endTime = _startTime.add(Duration(minutes: _durationMinutes));
                          }
                          _recalcDuration();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    ManualDateTimeField(
                      label: 'Kết thúc',
                      value: _endTime,
                      onChanged: (dt) {
                        setState(() => _endTime = dt);
                        _recalcDuration();
                      },
                    ),
                    const SizedBox(height: 12),
                    ManualNumberField(
                      label: 'Thời lượng',
                      unit: 'phút',
                      value: _durationMinutes.toDouble(),
                      min: 1,
                      max: 120,
                      step: 1,
                      hint: 'Tự tính từ giờ bắt đầu–kết thúc',
                      onChanged: (v) {
                        setState(() {
                          _durationMinutes = v.toInt();
                          _endTime = _startTime.add(Duration(minutes: _durationMinutes));
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    Text('Ghi chú', style: AppTextStyles.headingSm),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'vd: bé bú tốt, bú sâu, bú ngủ...',
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          borderSide: const BorderSide(color: AppColors.blush),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: AppColors.gradientFeeding,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                        child: TextButton(
                          onPressed: _save,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                            foregroundColor: AppColors.white,
                          ),
                          child: Text(
                            widget.existing == null ? 'Lưu cữ bú' : 'Cập nhật',
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
    final user = ref.read(currentUserProvider);
    final baby = ref.read(activeBabyProvider);
    if (user == null || baby == null) return;

    final notes = _notesController.text.trim();
    final entry = FeedingEntry(
      id: widget.existing?.id ?? ref.read(firestoreServiceProvider).newId(),
      babyId: baby.id,
      userId: user.uid,
      type: _isLeft ? FeedingType.breastLeft : FeedingType.breastRight,
      startTime: _startTime,
      endTime: _endTime,
      durationMinutes: _durationMinutes,
      notes: notes.isEmpty ? null : notes,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );

    await runWriteAction(
      context,
      () => ref.read(feedingRepositoryProvider).addFeeding(entry),
      successMessage: 'Đã lưu cữ bú $_durationMinutes phút ✓',
      onSuccess: () => Navigator.of(context).pop(true),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Xoá cữ bú?',
      content: 'Hành động này không thể hoàn tác.',
      confirmLabel: 'Xoá',
      confirmColor: AppColors.error,
    );
    if (confirmed != true || !mounted) return;

    final existing = widget.existing!;
    await runWriteAction(
      context,
      () => ref.read(feedingRepositoryProvider).deleteFeeding(existing.userId, existing.babyId, existing.id),
      onSuccess: () => Navigator.of(context).pop(true),
    );
  }
}

class _SideButton extends StatelessWidget {
  const _SideButton({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.blossom : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: selected ? AppColors.blossom : AppColors.blush, width: selected ? 2 : 1),
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
