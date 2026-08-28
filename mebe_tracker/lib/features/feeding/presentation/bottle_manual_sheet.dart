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

const _mlPerOz = 29.5735;

enum _MilkType { breast, formula, mixed }

String _milkTypeLabel(_MilkType type) {
  switch (type) {
    case _MilkType.breast:
      return '🤱 Sữa mẹ';
    case _MilkType.formula:
      return '🥛 Sữa CT';
    case _MilkType.mixed:
      return '🍼 Hỗn hợp';
  }
}

/// Manual create/edit form for a bottle-feeding session. Pass [existing] to
/// edit (and allow deleting) a previously logged entry.
class BottleManualSheet extends ConsumerStatefulWidget {
  const BottleManualSheet({super.key, this.existing});

  final FeedingEntry? existing;

  @override
  ConsumerState<BottleManualSheet> createState() => _BottleManualSheetState();
}

class _BottleManualSheetState extends ConsumerState<BottleManualSheet> {
  late DateTime _time;
  late double _amountMl;
  bool _useOz = false;
  _MilkType _milkType = _MilkType.breast;
  late final TextEditingController _brandController;
  late final TextEditingController _notesController;

  double get _amountOz => _amountMl / _mlPerOz;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _time = e?.startTime ?? DateTime.now();
    _amountMl = e?.amountMl ?? 120;
    _brandController = TextEditingController();
    _notesController = TextEditingController(text: e?.notes ?? '');
  }

  @override
  void dispose() {
    _brandController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.80,
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
                    widget.existing == null ? '🍼 Ghi cữ bú bình' : '🍼 Chỉnh sửa',
                    style: AppTextStyles.headingLg,
                  ),
                  const Spacer(),
                  if (widget.existing != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                      onPressed: _confirmDelete,
                    ),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: false, label: Text('ml')),
                      ButtonSegment(value: true, label: Text('oz')),
                    ],
                    selected: {_useOz},
                    onSelectionChanged: (s) => setState(() => _useOz = s.first),
                    style: const ButtonStyle(visualDensity: VisualDensity.compact),
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
                      label: 'Thời gian bú',
                      value: _time,
                      onChanged: (dt) => setState(() => _time = dt),
                    ),
                    const SizedBox(height: 20),
                    ManualNumberField(
                      label: _useOz ? 'Lượng sữa (oz)' : 'Lượng sữa (ml)',
                      unit: _useOz ? 'oz' : 'ml',
                      value: _useOz ? _amountOz : _amountMl,
                      min: _useOz ? 0.5 : 10,
                      max: _useOz ? 10 : 350,
                      step: _useOz ? 0.5 : 10,
                      decimals: _useOz ? 1 : 0,
                      onChanged: (v) => setState(() => _amountMl = _useOz ? v * _mlPerOz : v),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        _useOz ? '≈ ${_amountMl.round()} ml' : '≈ ${_amountOz.toStringAsFixed(1)} oz',
                        style: AppTextStyles.bodySm.copyWith(color: AppColors.muted),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Loại sữa', style: AppTextStyles.headingSm),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _MilkType.values
                          .map((type) => ChoiceChip(
                                label: Text(_milkTypeLabel(type)),
                                selected: _milkType == type,
                                onSelected: (_) => setState(() => _milkType = type),
                                selectedColor: AppColors.blossom.withValues(alpha: 0.2),
                                labelStyle: TextStyle(
                                  color: _milkType == type ? AppColors.blossom : AppColors.body,
                                  fontWeight: FontWeight.w700,
                                ),
                                side: BorderSide(
                                  color: _milkType == type ? AppColors.blossom : AppColors.blush,
                                ),
                              ))
                          .toList(),
                    ),
                    if (_milkType != _MilkType.breast) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _brandController,
                        decoration: InputDecoration(
                          labelText: 'Tên sữa công thức',
                          hintText: 'vd: Similac, Nan, Enfamil...',
                          prefixIcon: const Icon(Icons.local_drink_outlined),
                          filled: true,
                          fillColor: AppColors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    TextField(
                      controller: _notesController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Ghi chú (tuỳ chọn)',
                        hintText: 'vd: bé bú hết, bú ngủ...',
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
                            widget.existing == null ? 'Lưu cữ bú bình' : 'Cập nhật',
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

    final brand = _brandController.text.trim();
    final freeNotes = _notesController.text.trim();
    final notes = [
      _milkTypeLabel(_milkType),
      if (brand.isNotEmpty) brand,
      if (freeNotes.isNotEmpty) freeNotes,
    ].join(' · ');

    final entry = FeedingEntry(
      id: widget.existing?.id ?? ref.read(firestoreServiceProvider).newId(),
      babyId: baby.id,
      userId: user.uid,
      type: FeedingType.bottle,
      startTime: _time,
      amountMl: _amountMl,
      notes: notes,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );

    await runWriteAction(
      context,
      () => ref.read(feedingRepositoryProvider).addFeeding(entry),
      successMessage: 'Đã lưu ${_amountMl.round()}ml (${_amountOz.toStringAsFixed(1)}oz) ✓',
      onSuccess: () => Navigator.of(context).pop(true),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Xoá cữ bú bình?',
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
