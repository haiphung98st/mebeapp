import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/duration_utils.dart';
import '../../../../shared/models/feeding_entry.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/baby_provider.dart';
import '../../../../shared/providers/feeding_provider.dart';
import '../../../../shared/providers/home_provider.dart';
import 'feeding_log_list.dart';

class BreastfeedingTab extends ConsumerWidget {
  const BreastfeedingTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayFeedings = ref.watch(todayFeedingsProvider);
    final breastFeedings = todayFeedings
        .where((e) => e.type == FeedingType.breastLeft || e.type == FeedingType.breastRight)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _TimerCard(),
          const SizedBox(height: AppSpacing.lg),
          const _QuickTimeButtons(),
          const SizedBox(height: AppSpacing.lg),
          Text('Lịch sử hôm nay', style: AppTextStyles.headingMd),
          const SizedBox(height: AppSpacing.md),
          FeedingLogList(entries: breastFeedings, emptyLabel: 'Chưa có cữ bú mẹ hôm nay'),
        ],
      ),
    );
  }
}

class _TimerCard extends ConsumerWidget {
  const _TimerCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(feedingTimerProvider);
    final lastBreastFeeding = ref.watch(lastBreastFeedingProvider);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.blossom.withValues(alpha: 0.1),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          if (lastBreastFeeding != null) _HintPill(entry: lastBreastFeeding),
          if (lastBreastFeeding != null) const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _SideButton(
                  label: 'Bên trái',
                  selected: timer.side == FeedingType.breastLeft,
                  onTap: timer.isRunning
                      ? null
                      : () => ref.read(feedingTimerProvider.notifier).selectSide(FeedingType.breastLeft),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _SideButton(
                  label: 'Bên phải',
                  selected: timer.side == FeedingType.breastRight,
                  onTap: timer.isRunning
                      ? null
                      : () => ref.read(feedingTimerProvider.notifier).selectSide(FeedingType.breastRight),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(formatStopwatch(Duration(seconds: timer.elapsedSeconds)), style: AppTextStyles.timerDisplay),
          const SizedBox(height: AppSpacing.lg),
          GestureDetector(
            onTap: () => _onPlayPause(context, ref),
            child: Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                gradient: AppColors.gradientFeeding,
                shape: BoxShape.circle,
              ),
              child: Icon(
                timer.isRunning ? Icons.pause : Icons.play_arrow,
                color: AppColors.white,
                size: 36,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onPlayPause(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(feedingTimerProvider.notifier);
    final timer = ref.read(feedingTimerProvider);
    if (timer.isRunning) {
      notifier.pause();
      _showSaveDialog(context, ref);
    } else {
      notifier.start();
    }
  }

  Future<void> _showSaveDialog(BuildContext context, WidgetRef ref) async {
    await showDialog<void>(
      context: context,
      builder: (context) => const _SaveFeedingDialog(),
    );
  }
}

class _HintPill extends StatelessWidget {
  const _HintPill({required this.entry});

  final FeedingEntry entry;

  @override
  Widget build(BuildContext context) {
    final side = entry.type == FeedingType.breastLeft ? 'bên trái' : 'bên phải';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.powder,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        'Lần trước: $side · ${formatTime(entry.startTime)}',
        style: AppTextStyles.bodySm,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _SideButton extends StatelessWidget {
  const _SideButton({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected ? AppColors.powder : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(color: selected ? AppColors.blossom : AppColors.divider, width: 1.5),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyLg.copyWith(
            color: selected ? AppColors.blossom : AppColors.body,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _QuickTimeButtons extends ConsumerWidget {
  const _QuickTimeButtons();

  static const _minutes = [5, 10, 15, 20];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: _minutes
          .map(
            (m) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: OutlinedButton(
                  onPressed: () => _logQuickFeeding(context, ref, m),
                  child: Text('$m phút'),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  void _logQuickFeeding(BuildContext context, WidgetRef ref, int minutes) {
    final user = ref.read(currentUserProvider);
    final baby = ref.read(activeBabyProvider);
    if (user == null || baby == null) return;
    final side = ref.read(feedingTimerProvider).side;
    final now = DateTime.now();
    final entry = FeedingEntry(
      id: ref.read(firestoreServiceProvider).newId(),
      babyId: baby.id,
      userId: user.uid,
      type: side,
      startTime: now.subtract(Duration(minutes: minutes)),
      endTime: now,
      durationMinutes: minutes,
      createdAt: now,
    );
    ref.read(feedingRepositoryProvider).addFeeding(entry);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã lưu cữ bú 🐰')),
    );
  }
}

class _SaveFeedingDialog extends ConsumerStatefulWidget {
  const _SaveFeedingDialog();

  @override
  ConsumerState<_SaveFeedingDialog> createState() => _SaveFeedingDialogState();
}

class _SaveFeedingDialogState extends ConsumerState<_SaveFeedingDialog> {
  final _notesController = TextEditingController();
  late FeedingType _side;

  @override
  void initState() {
    super.initState();
    _side = ref.read(feedingTimerProvider).side;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timer = ref.watch(feedingTimerProvider);

    return AlertDialog(
      title: const Text('Kết thúc cữ bú'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tổng thời gian: ${formatStopwatch(Duration(seconds: timer.elapsedSeconds))}',
            style: AppTextStyles.bodyLg,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _SideButton(
                  label: 'Bên trái',
                  selected: _side == FeedingType.breastLeft,
                  onTap: () => setState(() => _side = FeedingType.breastLeft),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _SideButton(
                  label: 'Bên phải',
                  selected: _side == FeedingType.breastRight,
                  onTap: () => setState(() => _side = FeedingType.breastRight),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(hintText: 'Ghi chú (không bắt buộc)'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            ref.read(feedingTimerProvider.notifier).reset();
            Navigator.of(context).pop();
          },
          child: const Text('Bỏ qua'),
        ),
        FilledButton(
          onPressed: () => _save(context),
          child: const Text('Lưu cữ bú'),
        ),
      ],
    );
  }

  void _save(BuildContext context) {
    final user = ref.read(currentUserProvider);
    final baby = ref.read(activeBabyProvider);
    final timer = ref.read(feedingTimerProvider);
    if (user == null || baby == null) return;
    final now = DateTime.now();
    final entry = FeedingEntry(
      id: ref.read(firestoreServiceProvider).newId(),
      babyId: baby.id,
      userId: user.uid,
      type: _side,
      startTime: timer.startTime ?? now.subtract(Duration(seconds: timer.elapsedSeconds)),
      endTime: now,
      durationMinutes: (timer.elapsedSeconds / 60).ceil(),
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      createdAt: now,
    );
    ref.read(feedingRepositoryProvider).addFeeding(entry);
    ref.read(feedingTimerProvider.notifier).reset();
    Navigator.of(context).pop();
  }
}
