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
import '../../../shared/models/pump_entry.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/baby_provider.dart';
import '../../../shared/providers/pump_provider.dart';

const _mlPerOz = 29.5735;

String _storageLabel(PumpStorage storage) {
  switch (storage) {
    case PumpStorage.fresh:
      return '🌡 Dùng ngay';
    case PumpStorage.fridge:
      return '❄️ Tủ mát';
    case PumpStorage.frozen:
      return '🧊 Tủ đông';
  }
}

/// Manual create/edit form for a pumping session. Pass [existing] to edit
/// (and allow deleting) a previously logged entry.
class PumpManualSheet extends ConsumerStatefulWidget {
  const PumpManualSheet({super.key, this.existing});

  final PumpEntry? existing;

  @override
  ConsumerState<PumpManualSheet> createState() => _PumpManualSheetState();
}

class _PumpManualSheetState extends ConsumerState<PumpManualSheet> {
  late DateTime _startTime;
  late DateTime _endTime;
  late double _leftMl;
  late double _rightMl;
  bool _useOz = false;
  late PumpStorage _storage;
  late final TextEditingController _notesController;

  double get _totalMl => _leftMl + _rightMl;
  int get _durationMin => _endTime.difference(_startTime).inMinutes;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _startTime = e?.startTime ?? DateTime.now().subtract(const Duration(minutes: 20));
    _endTime = e?.endTime ?? DateTime.now();
    _leftMl = e?.leftAmountMl ?? 0;
    _rightMl = e?.rightAmountMl ?? 0;
    _storage = e?.storage ?? PumpStorage.fridge;
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
      initialChildSize: 0.88,
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
                  Text('🥛 Ghi phiên hút sữa', style: AppTextStyles.headingLg),
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
                      label: 'Bắt đầu',
                      value: _startTime,
                      onChanged: (dt) => setState(() {
                        _startTime = dt;
                        if (_endTime.isBefore(_startTime)) {
                          _endTime = _startTime.add(const Duration(minutes: 20));
                        }
                      }),
                    ),
                    const SizedBox(height: 12),
                    ManualDateTimeField(
                      label: 'Kết thúc',
                      value: _endTime,
                      onChanged: (dt) => setState(() => _endTime = dt),
                    ),
                    if (_durationMin > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text('Thời lượng: $_durationMin phút', style: AppTextStyles.bodySm),
                      ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ManualNumberField(
                            label: '◀ Bên trái',
                            unit: _useOz ? 'oz' : 'ml',
                            value: _useOz ? _leftMl / _mlPerOz : _leftMl,
                            min: 0,
                            max: _useOz ? 12 : 350,
                            step: _useOz ? 0.5 : 5,
                            decimals: _useOz ? 1 : 0,
                            onChanged: (v) => setState(() => _leftMl = _useOz ? v * _mlPerOz : v),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ManualNumberField(
                            label: 'Bên phải ▶',
                            unit: _useOz ? 'oz' : 'ml',
                            value: _useOz ? _rightMl / _mlPerOz : _rightMl,
                            min: 0,
                            max: _useOz ? 12 : 350,
                            step: _useOz ? 0.5 : 5,
                            decimals: _useOz ? 1 : 0,
                            onChanged: (v) => setState(() => _rightMl = _useOz ? v * _mlPerOz : v),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.lilac,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Tổng cộng:', style: AppTextStyles.bodyMd),
                          Text(
                            _useOz
                                ? '${(_totalMl / _mlPerOz).toStringAsFixed(1)} oz'
                                : '${_totalMl.round()} ml',
                            style: AppTextStyles.headingMd.copyWith(color: AppColors.lavender),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Lưu sữa vào', style: AppTextStyles.headingSm),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: PumpStorage.values
                          .map((storage) => ChoiceChip(
                                label: Text(_storageLabel(storage)),
                                selected: _storage == storage,
                                onSelected: (_) => setState(() => _storage = storage),
                                selectedColor: AppColors.lilac,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _notesController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Ghi chú',
                        hintText: 'vd: sữa nhiều, ít...',
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
                          gradient: AppColors.gradientPump,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                        child: TextButton(
                          onPressed: _save,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                            foregroundColor: AppColors.white,
                          ),
                          child: Text(
                            widget.existing == null ? 'Lưu phiên hút sữa' : 'Cập nhật',
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
    final entry = PumpEntry(
      id: widget.existing?.id ?? ref.read(firestoreServiceProvider).newId(),
      babyId: baby.id,
      userId: user.uid,
      startTime: _startTime,
      endTime: _endTime,
      leftAmountMl: _leftMl > 0 ? _leftMl : null,
      rightAmountMl: _rightMl > 0 ? _rightMl : null,
      leftDurationMinutes: _durationMin > 0 ? _durationMin : null,
      rightDurationMinutes: _durationMin > 0 ? _durationMin : null,
      storage: _storage,
      notes: notes.isEmpty ? null : notes,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );

    await runWriteAction(
      context,
      () => ref.read(pumpRepositoryProvider).addPump(entry),
      successMessage: 'Đã lưu ${_totalMl.round()}ml ✓',
      onSuccess: () => Navigator.of(context).pop(true),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Xoá phiên hút sữa?',
      content: 'Hành động này không thể hoàn tác.',
      confirmLabel: 'Xoá',
      confirmColor: AppColors.error,
    );
    if (confirmed != true || !mounted) return;

    final existing = widget.existing!;
    await runWriteAction(
      context,
      () => ref.read(pumpRepositoryProvider).deletePump(existing.userId, existing.babyId, existing.id),
      onSuccess: () => Navigator.of(context).pop(true),
    );
  }
}
