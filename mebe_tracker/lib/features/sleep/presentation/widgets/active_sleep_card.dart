import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/duration_utils.dart';
import '../../../../core/utils/error_handling.dart';
import '../../../../core/widgets/bunny_avatar.dart';
import '../../../../shared/models/sleep_entry.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/baby_provider.dart';
import '../../../../shared/providers/sleep_provider.dart';
import 'sleep_quality_dialog.dart';

String _activeSleepLabel(SleepType type, int startHour) {
  if (type == SleepType.night) return 'Giấc đêm';
  return startHour < 12 ? 'Giấc sáng' : 'Giấc chiều';
}

class ActiveSleepCard extends ConsumerWidget {
  const ActiveSleepCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeSleepProvider);
    final startTime = active.startTime!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.nightMid.withValues(alpha: 0.15),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          const BunnyAvatar(size: 72, isAsleep: true, primaryColor: AppColors.lilac),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Đang ${_activeSleepLabel(active.type, startTime.hour)}',
            style: AppTextStyles.headingMd,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(formatStopwatch(Duration(seconds: active.elapsedSeconds)), style: AppTextStyles.timerDisplay),
          const SizedBox(height: AppSpacing.sm),
          Text('Bắt đầu từ ${formatTime(startTime)}', style: AppTextStyles.bodyMd),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.nightMid),
              onPressed: () => _endSleep(context, ref),
              child: const Text('⏹ Kết thúc giấc ngủ'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _endSleep(BuildContext context, WidgetRef ref) async {
    final user = ref.read(currentUserProvider);
    final baby = ref.read(activeBabyProvider);
    final active = ref.read(activeSleepProvider);
    if (user == null || baby == null || active.startTime == null) return;

    final now = DateTime.now();
    final entry = SleepEntry(
      id: ref.read(firestoreServiceProvider).newId(),
      babyId: baby.id,
      userId: user.uid,
      startTime: active.startTime!,
      endTime: now,
      type: active.type,
      durationMinutes: now.difference(active.startTime!).inMinutes,
      createdAt: now,
    );
    ref.read(activeSleepProvider.notifier).reset();
    await showDialog<void>(
      context: context,
      builder: (context) => SleepQualityDialog(entry: entry),
    );
  }
}

class StartSleepCard extends ConsumerWidget {
  const StartSleepCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.nightMid.withValues(alpha: 0.1),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          const BunnyAvatar(size: 72),
          const SizedBox(height: AppSpacing.md),
          Text('Bé đang thức', style: AppTextStyles.headingMd),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.gradientSleep,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: TextButton(
                onPressed: () => ref.read(activeSleepProvider.notifier).start(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  foregroundColor: AppColors.white,
                ),
                child: const Text('🌙 Bắt đầu ghi giấc ngủ', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: () => _showLogPastDialog(context, ref),
            child: const Text('Ghi nhanh giấc đã qua'),
          ),
        ],
      ),
    );
  }

  Future<void> _showLogPastDialog(BuildContext context, WidgetRef ref) async {
    await showDialog<void>(
      context: context,
      builder: (context) => const _LogPastSleepDialog(),
    );
  }
}

class _LogPastSleepDialog extends ConsumerStatefulWidget {
  const _LogPastSleepDialog();

  @override
  ConsumerState<_LogPastSleepDialog> createState() => _LogPastSleepDialogState();
}

class _LogPastSleepDialogState extends ConsumerState<_LogPastSleepDialog> {
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ghi nhanh giấc đã qua'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Giờ bắt đầu'),
            trailing: Text(_startTime.format(context)),
            onTap: () => _pickTime(isStart: true),
          ),
          ListTile(
            title: const Text('Giờ kết thúc'),
            trailing: Text(_endTime.format(context)),
            onTap: () => _pickTime(isStart: false),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Huỷ')),
        FilledButton(onPressed: () => _save(context), child: const Text('Lưu')),
      ],
    );
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startTime = picked;
      } else {
        _endTime = picked;
      }
    });
  }

  Future<void> _save(BuildContext context) async {
    final user = ref.read(currentUserProvider);
    final baby = ref.read(activeBabyProvider);
    if (user == null || baby == null) return;
    final now = DateTime.now();
    var start = DateTime(now.year, now.month, now.day, _startTime.hour, _startTime.minute);
    var end = DateTime(now.year, now.month, now.day, _endTime.hour, _endTime.minute);
    if (end.isBefore(start)) end = end.add(const Duration(days: 1));

    final entry = SleepEntry(
      id: ref.read(firestoreServiceProvider).newId(),
      babyId: baby.id,
      userId: user.uid,
      startTime: start,
      endTime: end,
      type: sleepTypeForHour(start.hour),
      durationMinutes: end.difference(start).inMinutes,
      createdAt: now,
    );
    await runWriteAction(
      context,
      () => ref.read(sleepRepositoryProvider).addSleep(entry),
      onSuccess: () => Navigator.of(context).pop(),
    );
  }
}
