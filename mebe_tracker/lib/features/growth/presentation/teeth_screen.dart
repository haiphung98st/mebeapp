import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/bunny_header.dart';
import '../../../shared/providers/baby_provider.dart';
import '../../../shared/providers/growth_provider.dart';
import '../data/teeth_data.dart';
import '../data/teeth_provider.dart';

class TeethScreen extends ConsumerWidget {
  const TeethScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teethAsync = ref.watch(teethProvider);
    final baby = ref.watch(activeBabyProvider);
    final eruptions = teethAsync.value ?? {};
    final totalErupted = eruptions.length;

    final ageMonths = baby != null
        ? ageInMonthsAt(baby.dateOfBirth, DateTime.now())
        : 0.0;

    return Scaffold(
      backgroundColor: AppColors.powder,
      body: Column(
        children: [
          BunnyHeader(
            gradient: AppColors.gradientGrowth,
            earLeftColor: AppColors.growthEarLeft,
            earRightColor: AppColors.growthEarRight,
            title: 'Răng Sữa',
            subtitle: '$totalErupted / 20 răng đã mọc',
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xxxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProgressCard(erupted: totalErupted),
                  const SizedBox(height: AppSpacing.lg),
                  _TeethDiagram(
                    eruptions: eruptions,
                    ageMonths: ageMonths,
                    onToothTap: (def) => _showToothSheet(context, ref, def, eruptions),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _ToothLegend(),
                  const SizedBox(height: AppSpacing.lg),
                  _EruptionTimeline(eruptions: eruptions),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showToothSheet(
    BuildContext context,
    WidgetRef ref,
    ToothDef def,
    Map<String, DateTime> eruptions,
  ) {
    final isErupted = eruptions.containsKey(def.id);
    final eruptedAt = eruptions[def.id];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ToothSheet(
        def: def,
        isErupted: isErupted,
        eruptedAt: eruptedAt,
        onMarkErupted: (date) async {
          await ref.read(teethNotifierProvider.notifier).markErupted(def.id, date);
          if (context.mounted) Navigator.of(context).pop();
        },
        onUnmark: () async {
          await ref.read(teethNotifierProvider.notifier).unmark(def.id);
          if (context.mounted) Navigator.of(context).pop();
        },
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.erupted});
  final int erupted;

  @override
  Widget build(BuildContext context) {
    final pct = erupted / 20;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppColors.gradientGrowth,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🦷', style: TextStyle(fontSize: 28)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tiến trình mọc răng',
                      style: AppTextStyles.bodySm.copyWith(color: Colors.white70),
                    ),
                    Text(
                      '$erupted / 20 răng',
                      style: AppTextStyles.headingMd.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
              Text(
                '${(pct * 100).round()}%',
                style: AppTextStyles.headingLg.copyWith(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: Colors.white30,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeethDiagram extends StatelessWidget {
  const _TeethDiagram({
    required this.eruptions,
    required this.ageMonths,
    required this.onToothTap,
  });

  final Map<String, DateTime> eruptions;
  final double ageMonths;
  final void Function(ToothDef) onToothTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.mint.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Sơ đồ răng sữa',
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Chạm vào răng để đánh dấu',
            style: AppTextStyles.bodySm.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Upper jaw label
          Text('Hàm trên', style: AppTextStyles.bodySm.copyWith(color: AppColors.muted)),
          const SizedBox(height: AppSpacing.sm),
          _JawRow(
            teeth: _upperRowOrder(),
            eruptions: eruptions,
            ageMonths: ageMonths,
            onTap: onToothTap,
          ),
          const SizedBox(height: AppSpacing.sm),
          Divider(color: AppColors.divider, thickness: 1.5),
          const SizedBox(height: AppSpacing.sm),
          _JawRow(
            teeth: _lowerRowOrder(),
            eruptions: eruptions,
            ageMonths: ageMonths,
            onTap: onToothTap,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('Hàm dưới', style: AppTextStyles.bodySm.copyWith(color: AppColors.muted)),
        ],
      ),
    );
  }

  // Upper jaw display order: UR5..UR1 | UL1..UL5
  List<ToothDef> _upperRowOrder() => [
    upperTeeth[4], upperTeeth[3], upperTeeth[2], upperTeeth[1], upperTeeth[0],
    upperTeeth[5], upperTeeth[6], upperTeeth[7], upperTeeth[8], upperTeeth[9],
  ];

  // Lower jaw display order: LR5..LR1 | LL1..LL5
  List<ToothDef> _lowerRowOrder() => [
    lowerTeeth[4], lowerTeeth[3], lowerTeeth[2], lowerTeeth[1], lowerTeeth[0],
    lowerTeeth[5], lowerTeeth[6], lowerTeeth[7], lowerTeeth[8], lowerTeeth[9],
  ];
}

class _JawRow extends StatelessWidget {
  const _JawRow({
    required this.teeth,
    required this.eruptions,
    required this.ageMonths,
    required this.onTap,
  });

  final List<ToothDef> teeth;
  final Map<String, DateTime> eruptions;
  final double ageMonths;
  final void Function(ToothDef) onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: teeth.map((def) {
        final isErupted = eruptions.containsKey(def.id);
        final isSoon = !isErupted && ageMonths >= def.eruptMonthMin - 2;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: GestureDetector(
              onTap: () => onTap(def),
              child: _ToothCell(def: def, isErupted: isErupted, isSoon: isSoon),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ToothCell extends StatelessWidget {
  const _ToothCell({required this.def, required this.isErupted, required this.isSoon});

  final ToothDef def;
  final bool isErupted;
  final bool isSoon;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color border;
    if (isErupted) {
      bg = AppColors.mintLight;
      border = AppColors.success;
    } else if (isSoon) {
      bg = AppColors.peachLight;
      border = AppColors.warning;
    } else {
      bg = AppColors.powder;
      border = AppColors.divider;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 44,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border, width: 1.5),
      ),
      child: Center(
        child: isErupted
            ? const Icon(Icons.check, color: AppColors.success, size: 16)
            : Text(
                '${def.orderFromCenter}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isSoon ? AppColors.warning : AppColors.muted,
                ),
              ),
      ),
    );
  }
}

class _ToothLegend extends StatelessWidget {
  _ToothLegend();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendDot(color: AppColors.success, label: 'Đã mọc'),
        const SizedBox(width: AppSpacing.lg),
        _LegendDot(color: AppColors.warning, label: 'Sắp mọc'),
        const SizedBox(width: AppSpacing.lg),
        _LegendDot(color: AppColors.muted, label: 'Chưa mọc'),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.bodySm.copyWith(color: AppColors.body)),
      ],
    );
  }
}

class _EruptionTimeline extends StatelessWidget {
  const _EruptionTimeline({required this.eruptions});
  final Map<String, DateTime> eruptions;

  @override
  Widget build(BuildContext context) {
    if (eruptions.isEmpty) {
      return Center(
        child: Text(
          'Chưa có răng nào được đánh dấu.\nChạm vào sơ đồ để bắt đầu!',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySm.copyWith(color: AppColors.muted),
        ),
      );
    }

    final sorted = eruptions.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    final byTooth = {
      for (final def in allTeeth) def.id: def,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lịch sử mọc răng',
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...sorted.map((entry) {
          final def = byTooth[entry.key];
          if (def == null) return const SizedBox.shrink();
          final date = entry.value;
          final label =
              '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.mintLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text('🦷', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    def.nameVi,
                    style: AppTextStyles.bodyMd.copyWith(color: AppColors.ink),
                  ),
                ),
                Text(
                  label,
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _ToothSheet extends StatefulWidget {
  const _ToothSheet({
    required this.def,
    required this.isErupted,
    required this.eruptedAt,
    required this.onMarkErupted,
    required this.onUnmark,
  });

  final ToothDef def;
  final bool isErupted;
  final DateTime? eruptedAt;
  final Future<void> Function(DateTime) onMarkErupted;
  final Future<void> Function() onUnmark;

  @override
  State<_ToothSheet> createState() => _ToothSheetState();
}

class _ToothSheetState extends State<_ToothSheet> {
  late DateTime _selectedDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.eruptedAt ?? DateTime.now();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final def = widget.def;
    final dateLabel =
        '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}';

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: math.max(AppSpacing.lg, MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              const Text('🦷', style: TextStyle(fontSize: 28)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(def.nameVi, style: AppTextStyles.headingSm),
                    Text(
                      toothTypeName(def.orderFromCenter),
                      style: AppTextStyles.bodySm.copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Thường mọc: ${def.eruptMonthMin}–${def.eruptMonthMax} tháng',
            style: AppTextStyles.bodySm.copyWith(color: AppColors.body),
          ),
          if (!widget.isErupted) ...[
            const SizedBox(height: AppSpacing.lg),
            Text('Ngày mọc', style: AppTextStyles.bodyMd.copyWith(color: AppColors.ink)),
            const SizedBox(height: AppSpacing.sm),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.powder,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppColors.blossom, size: 18),
                    const SizedBox(width: AppSpacing.sm),
                    Text(dateLabel, style: AppTextStyles.bodyMd),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saving
                    ? null
                    : () async {
                        setState(() => _saving = true);
                        await widget.onMarkErupted(_selectedDate);
                      },
                icon: const Icon(Icons.check),
                label: const Text('Đánh dấu đã mọc'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.mintLight,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Đã mọc ngày $dateLabel',
                    style: AppTextStyles.bodyMd.copyWith(color: AppColors.success),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _saving ? null : () async {
                  setState(() => _saving = true);
                  await widget.onUnmark();
                },
                icon: const Icon(Icons.close, color: AppColors.error),
                label: const Text('Xoá đánh dấu'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}
