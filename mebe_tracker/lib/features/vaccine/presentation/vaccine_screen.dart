import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/vaccine_schedule_data.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/baby_provider.dart';
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

class _ProgressBanner extends StatelessWidget {
  const _ProgressBanner({required this.progress});

  final VaccineProgress progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
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
          const Text('💉', style: TextStyle(fontSize: 28)),
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
              label: '⚠️ Quá hạn (${overdueItems.length})',
              color: AppColors.error),
          ...overdueItems.map((i) =>
              _VaccineCard(item: i, onDone: onDone, highlight: true)),
          const SizedBox(height: AppSpacing.md),
        ],
        if (upcomingItems.isNotEmpty) ...[
          _SectionHeader(
              label: '⏰ Sắp tới (${upcomingItems.length})',
              color: AppColors.warning),
          ...upcomingItems.map((i) =>
              _VaccineCard(item: i, onDone: onDone, highlight: false)),
          const SizedBox(height: AppSpacing.md),
        ],
        if (notYet.isNotEmpty) ...[
          _SectionHeader(
              label: '📅 Chưa tới (${notYet.length})',
              color: AppColors.muted),
          ...notYet.map(
              (i) => _VaccineCard(item: i, onDone: onDone, highlight: false)),
          const SizedBox(height: AppSpacing.md),
        ],
        if (done.isNotEmpty) ...[
          _SectionHeader(
              label: '✅ Đã tiêm (${done.length})',
              color: AppColors.success),
          ...done.map(
              (i) => _VaccineCard(item: i, onDone: onDone, highlight: false)),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs, top: AppSpacing.xs),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(color: color),
      ),
    );
  }
}

class _VaccineCard extends ConsumerWidget {
  const _VaccineCard(
      {required this.item, required this.onDone, required this.highlight});

  final VaccineViewItem item;
  final VoidCallback onDone;
  final bool highlight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = item.status;
    final Color statusColor;
    switch (status) {
      case VaccineStatus.done:
        statusColor = AppColors.success;
      case VaccineStatus.upcoming:
        statusColor = AppColors.warning;
      case VaccineStatus.overdue:
        statusColor = AppColors.error;
      case VaccineStatus.notYet:
        statusColor = AppColors.muted;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: highlight
            ? Border.all(color: statusColor.withValues(alpha: 0.5), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.blossom.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: item.isCompleted ? null : () => _onTap(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  status == VaccineStatus.done
                      ? Icons.check_circle
                      : Icons.vaccines,
                  color: statusColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.def.nameVi,
                        style: AppTextStyles.bodyLg
                            .copyWith(fontWeight: FontWeight.w600)),
                    Text(
                      item.def.ageLabel,
                      style: AppTextStyles.bodySm
                          .copyWith(color: AppColors.muted),
                    ),
                    Text(
                      item.entry?.administeredDate != null
                          ? 'Đã tiêm ${_fmtDate(item.entry!.administeredDate!)}'
                          : 'Lịch: ${_fmtDate(item.scheduledDate)}',
                      style: AppTextStyles.bodySm
                          .copyWith(color: AppColors.body),
                    ),
                  ],
                ),
              ),
              if (!item.isCompleted)
                Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) =>
          _MarkVaccineDialog(item: item, onDone: onDone),
    );
  }
}

String _fmtDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

class _MarkVaccineDialog extends ConsumerStatefulWidget {
  const _MarkVaccineDialog({required this.item, required this.onDone});

  final VaccineViewItem item;
  final VoidCallback onDone;

  @override
  ConsumerState<_MarkVaccineDialog> createState() => _MarkVaccineDialogState();
}

class _MarkVaccineDialogState extends ConsumerState<_MarkVaccineDialog> {
  DateTime _administeredDate = DateTime.now();
  final _clinicCtrl = TextEditingController();

  @override
  void dispose() {
    _clinicCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ghi nhận đã tiêm'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.item.def.nameVi, style: AppTextStyles.bodyLg),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            icon: const Icon(Icons.calendar_today, size: 16),
            label: Text(_fmtDate(_administeredDate)),
            onPressed: _pickDate,
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _clinicCtrl,
            decoration:
                const InputDecoration(labelText: 'Nơi tiêm (không bắt buộc)'),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Huỷ')),
        FilledButton(onPressed: _save, child: const Text('Lưu')),
      ],
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
          clinicName:
              _clinicCtrl.text.trim().isEmpty ? null : _clinicCtrl.text.trim(),
        );
    Navigator.of(context).pop();
    widget.onDone();
  }
}

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
          width: 36,
          height: 36,
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
            style: AppTextStyles.bodyLg
                .copyWith(fontWeight: FontWeight.w600)),
        subtitle: Row(
          children: [
            Text(item.def.ageLabel,
                style: AppTextStyles.bodySm
                    .copyWith(color: AppColors.muted)),
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
              style: AppTextStyles.bodySm
                  .copyWith(color: AppColors.body),
            ),
          ),
        ],
      ),
    );
  }
}
