import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/bunny_header.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/baby_provider.dart';
import '../data/prenatal_data.dart';
import '../data/prenatal_entry.dart';
import '../data/prenatal_provider.dart';

class PrenatalScreen extends ConsumerWidget {
  const PrenatalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baby = ref.watch(activeBabyProvider);
    final entries = ref.watch(allPrenatalProvider).value ?? [];

    // Compute current pregnancy week from EDD if available
    final edd = baby?.edd;
    final currentWeek = edd != null
        ? (40 - edd.difference(DateTime.now()).inDays ~/ 7).clamp(1, 42)
        : null;
    final currentInfo =
        currentWeek != null ? infoForWeek(currentWeek) : null;

    return Scaffold(
      backgroundColor: AppColors.powder,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.blossom,
        onPressed: () => _showAddEntry(context, ref, currentWeek ?? 20),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          BunnyHeader(
            gradient: const LinearGradient(
              colors: [Color(0xFFF472A0), Color(0xFFC9A8F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            earLeftColor: AppColors.petal,
            earRightColor: AppColors.lilac,
            title: 'Nhật ký thai kỳ',
            subtitle: currentWeek != null ? 'Tuần $currentWeek' : 'Nhập ngày dự sinh để xem',
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
                  if (currentInfo != null) ...[
                    _BabyWeekCard(info: currentInfo),
                    const SizedBox(height: AppSpacing.lg),
                  ] else if (baby?.edd == null) ...[
                    _NoEddBanner(),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  _WeekTimeline(),
                  const SizedBox(height: AppSpacing.lg),
                  if (entries.isEmpty)
                    Center(
                      child: Text(
                        'Chưa có ghi chú nào.\nNhấn + để bắt đầu nhật ký!',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySm
                            .copyWith(color: AppColors.muted),
                      ),
                    )
                  else
                    ...entries.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _EntryCard(
                            entry: e,
                            onDelete: () => ref
                                .read(prenatalNotifierProvider.notifier)
                                .delete(e.id),
                          ),
                        )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEntry(BuildContext context, WidgetRef ref, int defaultWeek) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AddEntrySheet(
        defaultWeek: defaultWeek,
        onSave: (entry) =>
            ref.read(prenatalNotifierProvider.notifier).add(entry),
        userId: ref.read(currentUserProvider)?.uid ?? '',
      ),
    );
  }
}

class _BabyWeekCard extends StatelessWidget {
  const _BabyWeekCard({required this.info});
  final WeeklyBabyInfo info;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF8BBD9), Color(0xFFE8C5FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(info.sizeEmoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tuần ${info.week}',
                      style: AppTextStyles.bodySm
                          .copyWith(color: const Color(0xFF7A1F60)),
                    ),
                    Text(
                      'Bé bằng ${info.sizeComparison}',
                      style: AppTextStyles.headingSm.copyWith(
                        color: const Color(0xFF3D1A35),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _Stat('📏', '${info.lengthCm} cm'),
              const SizedBox(width: AppSpacing.lg),
              if (info.weightG > 0) _Stat('⚖️', '${info.weightG} g'),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '✨ ${info.highlight}',
            style: AppTextStyles.bodySm.copyWith(color: const Color(0xFF5B3A8A)),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.icon, this.label);
  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 4),
        Text(label,
            style: AppTextStyles.bodySm.copyWith(color: AppColors.ink)),
      ],
    );
  }
}

class _NoEddBanner extends StatelessWidget {
  _NoEddBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.peachLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Text('📅', style: TextStyle(fontSize: 20)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Thêm ngày dự sinh trong hồ sơ bé để xem thông tin tuần thai.',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.body),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekTimeline extends StatelessWidget {
  const _WeekTimeline();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.petal.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hành trình thai kỳ',
            style: AppTextStyles.bodyMd
                .copyWith(color: AppColors.ink, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _TrimCard('Tam cá nguyệt 1', 'Tuần 1–12', AppColors.error.withOpacity(0.7)),
              const SizedBox(width: 4),
              _TrimCard('Tam cá nguyệt 2', 'Tuần 13–27', AppColors.warning.withOpacity(0.7)),
              const SizedBox(width: 4),
              _TrimCard('Tam cá nguyệt 3', 'Tuần 28–40', AppColors.success.withOpacity(0.7)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrimCard extends StatelessWidget {
  const _TrimCard(this.label, this.sub, this.color);
  final String label;
  final String sub;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              sub,
              style:
                  const TextStyle(fontSize: 8, color: Color(0xFF7A4D6A)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry, required this.onDelete});
  final PrenatalEntry entry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final d = entry.date;
    final label =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.lilac,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  'Tuần ${entry.week}',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.nightMid,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                label,
                style: AppTextStyles.bodySm.copyWith(color: AppColors.muted),
              ),
              const SizedBox(width: AppSpacing.xs),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(Icons.delete_outline,
                    size: 18, color: AppColors.muted),
              ),
            ],
          ),
          if (entry.notes != null && entry.notes!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(entry.notes!,
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.ink)),
          ],
          if (entry.weightKg != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              '⚖️ Cân nặng mẹ: ${entry.weightKg!.toStringAsFixed(1)} kg',
              style:
                  AppTextStyles.bodySm.copyWith(color: AppColors.body),
            ),
          ],
          if (entry.bloodPressureSystolic != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              '💊 Huyết áp: ${entry.bloodPressureSystolic}/${entry.bloodPressureDiastolic} mmHg',
              style:
                  AppTextStyles.bodySm.copyWith(color: AppColors.body),
            ),
          ],
          if (entry.symptoms.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: entry.symptoms
                  .map((s) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.peachLight,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                        child: Text(s,
                            style: const TextStyle(
                                fontSize: 10, color: Color(0xFF7A4D6A))),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _AddEntrySheet extends StatefulWidget {
  const _AddEntrySheet({
    required this.defaultWeek,
    required this.onSave,
    required this.userId,
  });

  final int defaultWeek;
  final Future<void> Function(PrenatalEntry) onSave;
  final String userId;

  @override
  State<_AddEntrySheet> createState() => _AddEntrySheetState();
}

class _AddEntrySheetState extends State<_AddEntrySheet> {
  late int _week;
  final _notesCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _systolicCtrl = TextEditingController();
  final _diastolicCtrl = TextEditingController();
  final _selectedSymptoms = <String>{};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _week = widget.defaultWeek.clamp(1, 42);
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    _weightCtrl.dispose();
    _systolicCtrl.dispose();
    _diastolicCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (widget.userId.isEmpty) return;
    setState(() => _saving = true);
    final entry = PrenatalEntry(
      id: newPrenatalId(),
      userId: widget.userId,
      week: _week,
      date: DateTime.now(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      weightKg: double.tryParse(_weightCtrl.text),
      bloodPressureSystolic: int.tryParse(_systolicCtrl.text),
      bloodPressureDiastolic: int.tryParse(_diastolicCtrl.text),
      symptoms: _selectedSymptoms.toList(),
    );
    await widget.onSave(entry);
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
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Ghi chú thai kỳ', style: AppTextStyles.headingSm),
            const SizedBox(height: AppSpacing.md),

            // Week selector
            Row(
              children: [
                const Text('Tuần: ', style: TextStyle(fontSize: 14)),
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  onPressed: _week > 1 ? () => setState(() => _week--) : null,
                  icon: const Icon(Icons.remove_circle_outline),
                  color: AppColors.blossom,
                ),
                Text(
                  '$_week',
                  style: AppTextStyles.headingMd,
                ),
                IconButton(
                  onPressed:
                      _week < 42 ? () => setState(() => _week++) : null,
                  icon: const Icon(Icons.add_circle_outline),
                  color: AppColors.blossom,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Ghi chú hôm nay...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      hintText: 'Cân nặng (kg)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: _systolicCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'HA tâm thu',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: _diastolicCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'HA tâm trương',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('Triệu chứng:', style: AppTextStyles.bodySm.copyWith(color: AppColors.body)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: prenatalSymptoms.map((s) {
                final selected = _selectedSymptoms.contains(s);
                return FilterChip(
                  label: Text(s, style: const TextStyle(fontSize: 11)),
                  selected: selected,
                  onSelected: (v) => setState(() {
                    if (v) _selectedSymptoms.add(s); else _selectedSymptoms.remove(s);
                  }),
                  selectedColor: AppColors.petal.withOpacity(0.4),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blossom,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Lưu ghi chú'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
