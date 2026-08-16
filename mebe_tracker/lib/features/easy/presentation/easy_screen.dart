import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/bunny_header.dart';
import '../data/easy_data.dart';
import '../data/easy_provider.dart';

class EasyScreen extends ConsumerWidget {
  const EasyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleAsync = ref.watch(easyScheduleProvider);
    final blocks = scheduleAsync.value ?? [];

    return Scaffold(
      backgroundColor: AppColors.powder,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.mint,
        onPressed: () => _showAddBlock(context, ref),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          BunnyHeader(
            gradient: const LinearGradient(
              colors: [Color(0xFF7DE8C8), Color(0xFF50C8A0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            earLeftColor: AppColors.mint,
            earRightColor: AppColors.mintLight,
            title: 'EASY Schedule',
            subtitle: 'Eat · Activity · Sleep · You',
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () => ref.read(easyScheduleProvider.notifier).resetToDefault(),
                tooltip: 'Đặt lại mặc định',
              ),
            ],
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
                  _EasyLegend(),
                  const SizedBox(height: AppSpacing.lg),
                  Center(
                    child: _EasyCircleChart(blocks: blocks),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _BlockList(
                    blocks: blocks,
                    onRemove: (id) =>
                        ref.read(easyScheduleProvider.notifier).removeBlock(id),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddBlock(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _AddBlockSheet(
        onAdd: (block) => ref.read(easyScheduleProvider.notifier).addBlock(block),
      ),
    );
  }
}

class _EasyLegend extends StatelessWidget {
  _EasyLegend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      children: EasyBlockType.values.map((t) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Color(t.colorValue),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(t.label, style: AppTextStyles.bodySm.copyWith(color: AppColors.body)),
          ],
        );
      }).toList(),
    );
  }
}

class _EasyCircleChart extends StatelessWidget {
  const _EasyCircleChart({required this.blocks});
  final List<EasyBlock> blocks;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 280,
      child: CustomPaint(
        painter: _CircleChartPainter(blocks: blocks),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('24h', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.ink)),
              Text('EASY', style: TextStyle(fontSize: 11, color: AppColors.muted)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleChartPainter extends CustomPainter {
  const _CircleChartPainter({required this.blocks});
  final List<EasyBlock> blocks;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerR = size.width / 2 - 4;
    final innerR = outerR * 0.55;
    const totalMinutes = 24 * 60;
    // Start at top (12:00) = -pi/2
    const startOffset = -math.pi / 2;

    // Background ring
    canvas.drawCircle(
      Offset(cx, cy),
      outerR,
      Paint()..color = AppColors.divider.withOpacity(0.4),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      innerR,
      Paint()..color = AppColors.powder,
    );

    for (final block in blocks) {
      final startAngle =
          startOffset + (block.startMinute / totalMinutes) * 2 * math.pi;
      final sweepAngle =
          (block.durationMinutes / totalMinutes) * 2 * math.pi;

      final rect = Rect.fromCircle(center: Offset(cx, cy), radius: outerR);
      final paint = Paint()
        ..color = Color(block.type.colorValue).withOpacity(0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = outerR - innerR;

      // Draw arc centred at the midpoint radius
      final midR = (outerR + innerR) / 2;
      final midRect =
          Rect.fromCircle(center: Offset(cx, cy), radius: midR);
      canvas.drawArc(midRect, startAngle, sweepAngle, false,
          Paint()
            ..color = Color(block.type.colorValue).withOpacity(0.85)
            ..style = PaintingStyle.stroke
            ..strokeWidth = outerR - innerR);
    }

    // Hour ticks at 6h intervals (12, 6, 12, 18)
    final tickLabels = ['12', '6', '12', '18'];
    final tickAngles = [
      -math.pi / 2,
      0.0,
      math.pi / 2,
      math.pi,
    ];
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (var i = 0; i < 4; i++) {
      final angle = tickAngles[i];
      final outerTip = Offset(cx + outerR * math.cos(angle), cy + outerR * math.sin(angle));
      final labelR = outerR + 14;
      tp.text = TextSpan(
        text: tickLabels[i],
        style: const TextStyle(fontSize: 10, color: AppColors.muted, fontWeight: FontWeight.w600),
      );
      tp.layout();
      tp.paint(canvas, Offset(
        cx + labelR * math.cos(angle) - tp.width / 2,
        cy + labelR * math.sin(angle) - tp.height / 2,
      ));
    }
  }

  @override
  bool shouldRepaint(_CircleChartPainter old) => old.blocks != blocks;
}

class _BlockList extends StatelessWidget {
  const _BlockList({required this.blocks, required this.onRemove});
  final List<EasyBlock> blocks;
  final void Function(String) onRemove;

  @override
  Widget build(BuildContext context) {
    if (blocks.isEmpty) {
      return Center(
        child: Text(
          'Chưa có block nào. Nhấn + để thêm!',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.muted),
        ),
      );
    }

    final sorted = [...blocks]..sort((a, b) => a.startMinute.compareTo(b.startMinute));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chi tiết lịch',
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...sorted.map((block) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _BlockTile(block: block, onRemove: onRemove),
        )),
      ],
    );
  }
}

class _BlockTile extends StatelessWidget {
  const _BlockTile({required this.block, required this.onRemove});
  final EasyBlock block;
  final void Function(String) onRemove;

  @override
  Widget build(BuildContext context) {
    final startH = block.startMinute ~/ 60;
    final startM = block.startMinute % 60;
    final endH = block.endMinute ~/ 60 % 24;
    final endM = block.endMinute % 60;
    final timeStr =
        '${startH.toString().padLeft(2, '0')}:${startM.toString().padLeft(2, '0')} → ${endH.toString().padLeft(2, '0')}:${endM.toString().padLeft(2, '0')}';
    final durH = block.durationMinutes ~/ 60;
    final durM = block.durationMinutes % 60;
    final durStr = durH > 0 ? '${durH}h${durM > 0 ? ' ${durM}m' : ''}' : '${durM}m';

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: Color(block.type.colorValue).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Color(block.type.colorValue).withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: Color(block.type.colorValue),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(block.type.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  block.label ?? block.type.label,
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.ink),
                ),
                Text(
                  '$timeStr · $durStr',
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => onRemove(block.id),
            child: const Icon(Icons.close, size: 18, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _AddBlockSheet extends StatefulWidget {
  const _AddBlockSheet({required this.onAdd});
  final Future<void> Function(EasyBlock) onAdd;

  @override
  State<_AddBlockSheet> createState() => _AddBlockSheetState();
}

class _AddBlockSheetState extends State<_AddBlockSheet> {
  EasyBlockType _type = EasyBlockType.eat;
  int _startHour = 7;
  int _startMin = 0;
  int _durationMinutes = 30;
  final _labelCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _labelCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final block = EasyBlock(
      id: const Uuid().v4(),
      type: _type,
      startMinute: _startHour * 60 + _startMin,
      durationMinutes: _durationMinutes,
      label: _labelCtrl.text.trim().isEmpty ? null : _labelCtrl.text.trim(),
    );
    await widget.onAdd(block);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Thêm block', style: AppTextStyles.headingSm),
            const SizedBox(height: AppSpacing.md),

            // Type selector
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: EasyBlockType.values.map((t) {
                final isSelected = _type == t;
                return GestureDetector(
                  onTap: () => setState(() => _type = t),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? Color(t.colorValue).withOpacity(0.2) : AppColors.powder,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      border: Border.all(
                        color: isSelected ? Color(t.colorValue) : AppColors.divider,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(t.emoji),
                        const SizedBox(width: 4),
                        Text(t.label, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),

            // Start time
            Text('Bắt đầu:', style: AppTextStyles.bodySm.copyWith(color: AppColors.body)),
            Row(
              children: [
                Expanded(
                  child: _NumberPicker(
                    value: _startHour, min: 0, max: 23, label: 'Giờ',
                    onChanged: (v) => setState(() => _startHour = v),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _NumberPicker(
                    value: _startMin, min: 0, max: 55, step: 5, label: 'Phút',
                    onChanged: (v) => setState(() => _startMin = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Duration
            Text('Thời lượng (phút):', style: AppTextStyles.bodySm.copyWith(color: AppColors.body)),
            _NumberPicker(
              value: _durationMinutes, min: 5, max: 600, step: 5, label: 'Phút',
              onChanged: (v) => setState(() => _durationMinutes = v),
            ),
            const SizedBox(height: AppSpacing.sm),

            TextField(
              controller: _labelCtrl,
              decoration: const InputDecoration(
                hintText: 'Tên block (tuỳ chọn)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mint,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Thêm'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberPicker extends StatelessWidget {
  const _NumberPicker({
    required this.value,
    required this.min,
    required this.max,
    required this.label,
    required this.onChanged,
    this.step = 1,
  });

  final int value;
  final int min;
  final int max;
  final String label;
  final void Function(int) onChanged;
  final int step;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: value > min ? () => onChanged(value - step) : null,
          icon: const Icon(Icons.remove),
          color: AppColors.blossom,
          iconSize: 20,
        ),
        Expanded(
          child: Text(
            '$value $label',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMd,
          ),
        ),
        IconButton(
          onPressed: value < max ? () => onChanged(value + step) : null,
          icon: const Icon(Icons.add),
          color: AppColors.blossom,
          iconSize: 20,
        ),
      ],
    );
  }
}
