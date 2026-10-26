import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/vaccine_schedule_data.dart';
import '../../../core/widgets/disclaimer_banner.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/baby_provider.dart';
import 'package:mebe_tracker/core/icons/mebe_glyphs.dart';
import 'package:mebe_tracker/core/icons/mebe_icons.dart';
import '../../../shared/providers/vaccine_provider.dart';

class VaccineScreen extends ConsumerStatefulWidget {
  const VaccineScreen({super.key});

  @override
  ConsumerState<VaccineScreen> createState() => _VaccineScreenState();
}

class _VaccineScreenState extends ConsumerState<VaccineScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final ConfettiController _confettiCtrl;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _confettiCtrl = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  void _onVaccineDone() {
    _confettiCtrl.play();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🎉 Bé đã hoàn thành mũi tiêm!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(vaccineProgressProvider);

    return Scaffold(
      backgroundColor: AppColors.powder,
      appBar: AppBar(
        title: const Text('Tiêm chủng'),
        backgroundColor: AppColors.powder,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.blossom,
          labelColor: AppColors.blossom,
          unselectedLabelColor: AppColors.muted,
          tabs: const [
            Tab(text: 'Lịch tiêm'),
            Tab(text: 'Thư viện'),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const DisclaimerBanner(
                text:
                    'Lịch tiêm chủng gợi ý dựa trên khuyến cáo chung, chỉ mang tính tham khảo. '
                    'Hãy xác nhận lịch tiêm cụ thể cho bé với bác sĩ hoặc cơ sở y tế.',
              ),
              _ProgressBanner(progress: progress),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _ScheduleTab(onDone: _onVaccineDone),
                    const _LibraryTab(),
                  ],
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiCtrl,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [
                AppColors.blossom,
                AppColors.mint,
                AppColors.blush,
                Colors.yellow,
                Colors.purple,
              ],
              numberOfParticles: 30,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Progress banner ────────────────────────────────────────────────────────────

class _ProgressBanner extends StatelessWidget {
  const _ProgressBanner({required this.progress});

  final VaccineProgress progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xs),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.blossom.withValues(alpha: 0.9),
            AppColors.mint.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Row(
        children: [
          const MeBeIcon(type: MeBeIconType.vaccine, size: 28),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${progress.done}/${progress.total} mũi đã tiêm',
                  style: AppTextStyles.bodyLg.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  child: LinearProgressIndicator(
                    value: progress.ratio,
                    backgroundColor: AppColors.white.withValues(alpha: 0.3),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.white),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            '${(progress.ratio * 100).round()}%',
            style: AppTextStyles.bodyLg.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Schedule tab ───────────────────────────────────────────────────────────────

class _ScheduleTab extends ConsumerWidget {
  const _ScheduleTab({required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overdueItems = ref.watch(overdueVaccinesProvider);
    final upcomingItems = ref.watch(upcomingVaccinesProvider);
    final allItems = ref.watch(vaccineViewListProvider);

    final notYet =
        allItems.where((i) => i.status == VaccineStatus.notYet).toList();
    final done =
        allItems.where((i) => i.status == VaccineStatus.done).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xxxl,
      ),
      children: [
        if (overdueItems.isNotEmpty) ...[
          _SectionHeader(
              icon: const MeBeGlyph(MeBeGlyphType.warningAmber,
                  color: AppColors.error, size: 14),
              label: 'Quá hạn (${overdueItems.length})',
              color: AppColors.error),
          ...overdueItems.map((i) => _VaccineCard(item: i, onDone: onDone)),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (upcomingItems.isNotEmpty) ...[
          _SectionHeader(
              icon: const MeBeIcon(type: MeBeIconType.timer, size: 16),
              label: 'Sắp tới (${upcomingItems.length})',
              color: AppColors.warning),
          ...upcomingItems.map((i) => _VaccineCard(item: i, onDone: onDone)),
          const SizedBox(height: AppSpacing.md),
        ],
        if (notYet.isNotEmpty) ...[
          _SectionHeader(
              icon: const MeBeGlyph(MeBeGlyphType.calendarToday,
                  color: AppColors.muted, size: 14),
              label: 'Chưa tới (${notYet.length})',
              color: AppColors.muted),
          ...notYet.map((i) => _VaccineCard(item: i, onDone: onDone)),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (done.isNotEmpty) ...[
          _SectionHeader(
              icon: const MeBeGlyph(MeBeGlyphType.checkCircle,
                  color: AppColors.success, size: 14),
              label: 'Đã tiêm (${done.length})',
              color: AppColors.success),
          ...done.map((i) => _VaccineCard(item: i, onDone: onDone)),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.label, required this.color});

  final Widget icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs, top: AppSpacing.xs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.label.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

// ── Vaccine card ───────────────────────────────────────────────────────────────

class _VaccineCard extends ConsumerWidget {
  const _VaccineCard({required this.item, required this.onDone});

  final VaccineViewItem item;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = item.status;
    final isDone = status == VaccineStatus.done;

    final Color iconBg;
    final Color iconColor;
    final String? badgeText;
    final Color? badgeColor;

    switch (status) {
      case VaccineStatus.done:
        iconBg = AppColors.success.withValues(alpha: 0.12);
        iconColor = AppColors.success;
        badgeText = null;
        badgeColor = null;
      case VaccineStatus.overdue:
        iconBg = AppColors.error.withValues(alpha: 0.1);
        iconColor = AppColors.error;
        badgeText = 'Quá hạn';
        badgeColor = AppColors.error;
      case VaccineStatus.upcoming:
        iconBg = const Color(0xFFFFF3E0);
        iconColor = const Color(0xFFE07800);
        badgeText = 'Sắp đến hạn';
        badgeColor = const Color(0xFFE07800);
      case VaccineStatus.notYet:
        iconBg = AppColors.divider;
        iconColor = AppColors.muted;
        badgeText = 'Chưa đến hạn';
        badgeColor = AppColors.muted;
    }

    // Days remaining / overdue
    final now = DateTime.now();
    final diff = item.scheduledDate.difference(now).inDays;
    final daysText = switch (status) {
      VaccineStatus.overdue  => 'Quá ${diff.abs()} ngày',
      VaccineStatus.upcoming => 'Còn $diff ngày',
      VaccineStatus.notYet   => 'Còn $diff ngày',
      VaccineStatus.done     => null,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.blossom.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: icon + name + badge ──────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: iconBg, shape: BoxShape.circle),
                  child: Icon(
                    isDone ? Icons.check_circle : Icons.vaccines,
                    color: iconColor, size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.def.nameVi,
                        style: AppTextStyles.bodyMd.copyWith(
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      if (isDone) ...[
                        // Administered date + clinic
                        Text(
                          item.entry?.administeredDate != null
                              ? 'Đã tiêm ${_fmt(item.entry!.administeredDate!)}'
                              : 'Đã tiêm',
                          style: AppTextStyles.bodySm
                              .copyWith(color: AppColors.muted),
                        ),
                        if (item.entry?.clinicName != null &&
                            item.entry!.clinicName!.isNotEmpty)
                          Text(
                            item.entry!.clinicName!,
                            style: AppTextStyles.bodySm
                                .copyWith(color: AppColors.muted),
                          ),
                      ] else ...[
                        // Scheduled date + days remaining
                        Row(
                          children: [
                            Text(
                              'Lịch hẹn ${_fmt(item.scheduledDate)}',
                              style: AppTextStyles.bodySm
                                  .copyWith(color: AppColors.muted),
                            ),
                            if (daysText != null) ...[
                              Text(
                                '  ·  ',
                                style: AppTextStyles.bodySm
                                    .copyWith(color: AppColors.divider),
                              ),
                              Text(
                                daysText,
                                style: AppTextStyles.bodySm.copyWith(
                                  color: badgeColor ?? AppColors.muted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                // Badge
                if (badgeText != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeColor!.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: Text(
                      badgeText,
                      style: AppTextStyles.bodySm.copyWith(
                        color: badgeColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            // ── "Xem ghi nhận" for done ───────────────────────────────
            if (isDone) ...[
              const SizedBox(height: AppSpacing.sm),
              GestureDetector(
                onTap: () => _showDetail(context),
                child: Text(
                  'Xem ghi nhận →',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.blossom,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],

            // ── Action buttons for non-done ───────────────────────────
            if (!isDone) ...[
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.blossom,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm),
                  ),
                  onPressed: () =>
                      _showMarkDialog(context, ref),
                  child: const Text(
                    'Đánh dấu đã tiêm',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE8D8F0)),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm),
                    foregroundColor: AppColors.body,
                  ),
                  icon: const Icon(Icons.calendar_today_outlined, size: 16),
                  label: const Text(
                    'Đổi lịch',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onPressed: () => _showRescheduleDialog(context, ref),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    final entry = item.entry;
    if (entry == null) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle,
                      color: AppColors.success, size: 24),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    item.def.nameVi,
                    style: AppTextStyles.headingSm,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _DetailRow(
              icon: Icons.event_available,
              label: 'Ngày tiêm',
              value: entry.administeredDate != null
                  ? _fmt(entry.administeredDate!)
                  : '—',
            ),
            if (entry.clinicName != null && entry.clinicName!.isNotEmpty)
              _DetailRow(
                icon: Icons.local_hospital_outlined,
                label: 'Nơi tiêm',
                value: entry.clinicName!,
              ),
            if (entry.notes != null && entry.notes!.isNotEmpty)
              _DetailRow(
                icon: Icons.notes,
                label: 'Ghi chú',
                value: entry.notes!,
              ),
          ],
        ),
      ),
    );
  }

  void _showMarkDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (_) => _MarkVaccineSheet(item: item, onDone: onDone),
    );
  }

  void _showRescheduleDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (_) => _RescheduleSheet(item: item),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.muted),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.muted)),
              Text(value,
                  style:
                      AppTextStyles.bodyMd.copyWith(color: AppColors.ink)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Mark vaccine bottom sheet ──────────────────────────────────────────────────

class _MarkVaccineSheet extends ConsumerStatefulWidget {
  const _MarkVaccineSheet({required this.item, required this.onDone});

  final VaccineViewItem item;
  final VoidCallback onDone;

  @override
  ConsumerState<_MarkVaccineSheet> createState() => _MarkVaccineSheetState();
}

class _MarkVaccineSheetState extends ConsumerState<_MarkVaccineSheet> {
  DateTime _administeredDate = DateTime.now();
  final _clinicCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _clinicCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xxxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Ghi nhận đã tiêm', style: AppTextStyles.headingSm),
          const SizedBox(height: AppSpacing.xs),
          Text(widget.item.def.nameVi,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.muted)),
          const SizedBox(height: AppSpacing.lg),

          // Date picker
          Text('Ngày tiêm',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.muted)),
          const SizedBox(height: AppSpacing.xs),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
              decoration: BoxDecoration(
                color: AppColors.powder,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 18, color: AppColors.blossom),
                  const SizedBox(width: AppSpacing.sm),
                  Text(_fmt(_administeredDate),
                      style: AppTextStyles.bodyMd
                          .copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Clinic
          TextField(
            controller: _clinicCtrl,
            decoration: InputDecoration(
              labelText: 'Nơi tiêm (không bắt buộc)',
              prefixIcon:
                  const Icon(Icons.local_hospital_outlined, size: 18),
              filled: true,
              fillColor: AppColors.powder,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Notes
          TextField(
            controller: _notesCtrl,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Ghi chú (không bắt buộc)',
              prefixIcon: const Icon(Icons.notes, size: 18),
              filled: true,
              fillColor: AppColors.powder,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.blossom,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              onPressed: _save,
              child: const Text('Lưu',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _administeredDate,
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _administeredDate = picked);
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
          clinicName: _clinicCtrl.text.trim().isEmpty
              ? null
              : _clinicCtrl.text.trim(),
        );
    Navigator.of(context).pop();
    widget.onDone();
  }
}

// ── Reschedule bottom sheet ────────────────────────────────────────────────────

class _RescheduleSheet extends ConsumerStatefulWidget {
  const _RescheduleSheet({required this.item});

  final VaccineViewItem item;

  @override
  ConsumerState<_RescheduleSheet> createState() => _RescheduleSheetState();
}

class _RescheduleSheetState extends ConsumerState<_RescheduleSheet> {
  late DateTime _newDate;

  @override
  void initState() {
    super.initState();
    _newDate = widget.item.scheduledDate;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xxxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Đổi lịch tiêm', style: AppTextStyles.headingSm),
          const SizedBox(height: AppSpacing.xs),
          Text(widget.item.def.nameVi,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.muted)),
          const SizedBox(height: AppSpacing.lg),
          Text('Ngày tiêm mới',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.muted)),
          const SizedBox(height: AppSpacing.xs),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
              decoration: BoxDecoration(
                color: AppColors.powder,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 18, color: AppColors.blossom),
                  const SizedBox(width: AppSpacing.sm),
                  Text(_fmt(_newDate),
                      style: AppTextStyles.bodyMd
                          .copyWith(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text('Chạm để thay đổi',
                      style: AppTextStyles.bodySm
                          .copyWith(color: AppColors.muted)),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.blossom,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              onPressed: _save,
              child: const Text('Xác nhận',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _newDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => _newDate = picked);
  }

  void _save() {
    final user = ref.read(currentUserProvider);
    final baby = ref.read(activeBabyProvider);
    if (user == null || baby == null) return;
    ref.read(vaccineRepositoryProvider).reschedule(
          widget.item,
          userId: user.uid,
          babyId: baby.id,
          newDate: _newDate,
        );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ Đã đổi lịch sang ${_fmt(_newDate)}')),
    );
  }
}

// ── Library tab ────────────────────────────────────────────────────────────────

class _LibraryTab extends ConsumerStatefulWidget {
  const _LibraryTab();

  @override
  ConsumerState<_LibraryTab> createState() => _LibraryTabState();
}

class _LibraryTabState extends ConsumerState<_LibraryTab> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(filteredVaccineLibraryProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (q) =>
                ref.read(vaccineSearchQueryProvider.notifier).state = q,
            decoration: InputDecoration(
              hintText: 'Tìm vắc xin...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppColors.white,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusFull),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xxxl),
            itemCount: items.length,
            itemBuilder: (context, index) =>
                _LibraryCard(item: items[index]),
          ),
        ),
      ],
    );
  }
}

class _LibraryCard extends StatelessWidget {
  const _LibraryCard({required this.item});

  final VaccineViewItem item;

  @override
  Widget build(BuildContext context) {
    final isDone = item.isCompleted;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.blossom.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: (isDone ? AppColors.success : AppColors.blossom)
                .withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isDone ? Icons.check_circle : Icons.vaccines,
            color: isDone ? AppColors.success : AppColors.blossom,
            size: 20,
          ),
        ),
        title: Text(item.def.nameVi,
            style:
                AppTextStyles.bodyLg.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Row(
          children: [
            Text(item.def.ageLabel,
                style: AppTextStyles.bodySm.copyWith(color: AppColors.muted)),
            if (item.def.category == VaccineCategory.recommended) ...[
              const SizedBox(width: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.mint.withValues(alpha: 0.2),
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  'Khuyến cáo',
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.mint, fontSize: 10),
                ),
              ),
            ],
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
            child: Text(
              item.def.descriptionVi.isNotEmpty
                  ? item.def.descriptionVi
                  : 'Không có thông tin chi tiết.',
              style:
                  AppTextStyles.bodySm.copyWith(color: AppColors.body),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────

String _fmt(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
