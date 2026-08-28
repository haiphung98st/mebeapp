import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/error_handling.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/manual_datetime_field.dart';
import '../../../core/widgets/sheet_handle.dart';
import '../../../shared/models/diaper_entry.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/baby_provider.dart';
import '../../../shared/providers/diaper_provider.dart';

/// Manual create/edit form for a diaper-change entry. Pass [existing] to
/// edit (and allow deleting) a previously logged entry.
class DiaperManualSheet extends ConsumerStatefulWidget {
  const DiaperManualSheet({super.key, this.existing, this.initialType});

  final DiaperEntry? existing;

  /// Pre-selected type when creating a new entry (ignored when editing).
  final DiaperType? initialType;

  @override
  ConsumerState<DiaperManualSheet> createState() => _DiaperManualSheetState();
}

class _DiaperManualSheetState extends ConsumerState<DiaperManualSheet> {
  late DateTime _time;
  late DiaperType _type;
  String? _color;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _time = e?.time ?? DateTime.now();
    _type = e?.type ?? widget.initialType ?? DiaperType.wet;
    _color = e?.color;
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
      initialChildSize: 0.72,
      maxChildSize: 0.95,
      minChildSize: 0.4,
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
                    widget.existing == null ? '🌸 Ghi thay tã' : '🌸 Chỉnh sửa thay tã',
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
                    ManualDateTimeField(
                      label: 'Thời gian thay tã',
                      value: _time,
                      onChanged: (dt) => setState(() => _time = dt),
                    ),
                    const SizedBox(height: 20),
                    Text('Loại tã', style: AppTextStyles.headingSm),
                    const SizedBox(height: 8),
                    Row(
                      children: DiaperType.values
                          .map(
                            (type) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: _TypeCard(
                                  icon: diaperTypeIcon(type),
                                  label: diaperTypeLabel(type),
                                  selected: _type == type,
                                  onTap: () => setState(() => _type = type),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    if (_type != DiaperType.wet) ...[
                      const SizedBox(height: 20),
                      Text('Màu tã', style: AppTextStyles.headingSm),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: diaperColorGuide.map((option) {
                          final selected = _color == option.name;
                          return GestureDetector(
                            onTap: () => setState(() => _color = selected ? null : option.name),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: option.color.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                                border: Border.all(
                                  color: selected ? AppColors.blossom : option.color,
                                  width: selected ? 2 : 1,
                                ),
                              ),
                              child: Text(
                                option.name,
                                style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 20),
                    TextField(
                      controller: _notesController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Ghi chú',
                        hintText: 'vd: phân có hạt, mùi lạ...',
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
                          gradient: const LinearGradient(colors: [AppColors.mint, Color(0xFF34A880)]),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                        child: TextButton(
                          onPressed: _save,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                            foregroundColor: AppColors.white,
                          ),
                          child: Text(
                            widget.existing == null ? 'Lưu thay tã' : 'Cập nhật',
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
    final entry = DiaperEntry(
      id: widget.existing?.id ?? ref.read(firestoreServiceProvider).newId(),
      babyId: baby.id,
      userId: user.uid,
      time: _time,
      type: _type,
      color: _color,
      notes: notes.isEmpty ? null : notes,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );

    await runWriteAction(
      context,
      () => ref.read(diaperRepositoryProvider).addDiaper(entry),
      successMessage: 'Đã lưu thay tã ✓',
      onSuccess: () => Navigator.of(context).pop(true),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Xoá lần thay tã?',
      content: 'Hành động này không thể hoàn tác.',
      confirmLabel: 'Xoá',
      confirmColor: AppColors.error,
    );
    if (confirmed != true || !mounted) return;

    final existing = widget.existing!;
    await runWriteAction(
      context,
      () => ref.read(diaperRepositoryProvider).deleteDiaper(existing.userId, existing.babyId, existing.id),
      onSuccess: () => Navigator.of(context).pop(true),
    );
  }
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({required this.icon, required this.label, required this.selected, required this.onTap});

  final String icon;
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
          color: selected ? AppColors.mint.withValues(alpha: 0.25) : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: selected ? AppColors.mint : AppColors.blush, width: selected ? 2 : 1),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
