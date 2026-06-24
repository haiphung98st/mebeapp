import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/duration_utils.dart';
import '../../../../core/utils/error_handling.dart';
import '../../../../shared/models/milk_stash_entry.dart';
import '../../../../shared/models/pump_entry.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/baby_provider.dart';
import '../../../../shared/providers/pump_provider.dart';

class NewSessionButton extends ConsumerWidget {
  const NewSessionButton({super.key});

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
            color: AppColors.lavender.withValues(alpha: 0.15),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('🐰', style: TextStyle(fontSize: 48)),
          const SizedBox(height: AppSpacing.md),
          Text('Bắt đầu phiên hút sữa', style: AppTextStyles.headingMd),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.gradientPump,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: TextButton(
                onPressed: () => ref.read(pumpTimerProvider.notifier).startSession(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  foregroundColor: AppColors.white,
                ),
                child: const Text('Bắt đầu', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CurrentSessionCard extends ConsumerWidget {
  const CurrentSessionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(pumpTimerProvider);
    final total = timer.leftAmountMl + timer.rightAmountMl;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.lavender.withValues(alpha: 0.15),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _SideColumn(
                  label: 'Bên trái',
                  amountMl: timer.leftAmountMl,
                  elapsedSeconds: timer.leftElapsedSeconds,
                  isRunning: timer.leftRunning,
                  onAmountChanged: (v) => ref.read(pumpTimerProvider.notifier).setLeftAmount(v),
                  onToggle: () => timer.leftRunning
                      ? ref.read(pumpTimerProvider.notifier).pauseLeft()
                      : ref.read(pumpTimerProvider.notifier).startLeft(),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: _SideColumn(
                  label: 'Bên phải',
                  amountMl: timer.rightAmountMl,
                  elapsedSeconds: timer.rightElapsedSeconds,
                  isRunning: timer.rightRunning,
                  onAmountChanged: (v) => ref.read(pumpTimerProvider.notifier).setRightAmount(v),
                  onToggle: () => timer.rightRunning
                      ? ref.read(pumpTimerProvider.notifier).pauseRight()
                      : ref.read(pumpTimerProvider.notifier).startRight(),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: total <= 0 ? null : () => _finishSession(context, ref, total),
              child: Text('✓ Xong phiên này · ${total.toStringAsFixed(0)}ml'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _finishSession(BuildContext context, WidgetRef ref, double total) async {
    await showDialog<void>(
      context: context,
      builder: (context) => _FinishSessionDialog(totalMl: total),
    );
  }
}

class _SideColumn extends StatelessWidget {
  const _SideColumn({
    required this.label,
    required this.amountMl,
    required this.elapsedSeconds,
    required this.isRunning,
    required this.onAmountChanged,
    required this.onToggle,
  });

  final String label;
  final double amountMl;
  final int elapsedSeconds;
  final bool isRunning;
  final ValueChanged<double> onAmountChanged;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.bodyLg.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StepIcon(icon: Icons.remove, onTap: () => onAmountChanged(amountMl - 10)),
            SizedBox(
              width: 56,
              child: Text(
                '${amountMl.toStringAsFixed(0)}ml',
                textAlign: TextAlign.center,
                style: AppTextStyles.headingSm,
              ),
            ),
            _StepIcon(icon: Icons.add, onTap: () => onAmountChanged(amountMl + 10)),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(formatStopwatch(Duration(seconds: elapsedSeconds)), style: AppTextStyles.headingMd),
        const SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          child: Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              gradient: AppColors.gradientPump,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isRunning ? Icons.pause : Icons.play_arrow,
              color: AppColors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _StepIcon extends StatelessWidget {
  const _StepIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      child: Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(color: AppColors.lilac, shape: BoxShape.circle),
        child: Icon(icon, size: 16, color: AppColors.mauve),
      ),
    );
  }
}

class _FinishSessionDialog extends ConsumerStatefulWidget {
  const _FinishSessionDialog({required this.totalMl});

  final double totalMl;

  @override
  ConsumerState<_FinishSessionDialog> createState() => _FinishSessionDialogState();
}

class _FinishSessionDialogState extends ConsumerState<_FinishSessionDialog> {
  PumpStorage _storage = PumpStorage.fresh;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Hoàn tất phiên hút sữa'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tổng: ${widget.totalMl.toStringAsFixed(0)}ml', style: AppTextStyles.headingMd),
          const SizedBox(height: AppSpacing.md),
          Text('Bảo quản ở đâu?', style: AppTextStyles.bodyMd),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              _StorageChip(
                label: 'Dùng ngay',
                selected: _storage == PumpStorage.fresh,
                onTap: () => setState(() => _storage = PumpStorage.fresh),
              ),
              _StorageChip(
                label: 'Tủ mát',
                selected: _storage == PumpStorage.fridge,
                onTap: () => setState(() => _storage = PumpStorage.fridge),
              ),
              _StorageChip(
                label: 'Tủ đông',
                selected: _storage == PumpStorage.frozen,
                onTap: () => setState(() => _storage = PumpStorage.frozen),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            ref.read(pumpTimerProvider.notifier).reset();
            Navigator.of(context).pop();
          },
          child: const Text('Bỏ qua'),
        ),
        FilledButton(
          onPressed: () => _save(context),
          child: const Text('Lưu'),
        ),
      ],
    );
  }

  Future<void> _save(BuildContext context) async {
    final user = ref.read(currentUserProvider);
    final baby = ref.read(activeBabyProvider);
    if (user == null || baby == null) return;
    final timer = ref.read(pumpTimerProvider);
    final now = DateTime.now();
    final firestoreService = ref.read(firestoreServiceProvider);

    final pumpEntry = PumpEntry(
      id: firestoreService.newId(),
      babyId: baby.id,
      userId: user.uid,
      startTime: timer.sessionStartTime ?? now,
      endTime: now,
      leftAmountMl: timer.leftAmountMl,
      rightAmountMl: timer.rightAmountMl,
      leftDurationMinutes: (timer.leftElapsedSeconds / 60).ceil(),
      rightDurationMinutes: (timer.rightElapsedSeconds / 60).ceil(),
      storage: _storage,
      createdAt: now,
    );
    await runWriteAction(
      context,
      () async {
        await ref.read(pumpRepositoryProvider).addPump(pumpEntry);

        if (_storage != PumpStorage.fresh) {
          final location = _storage == PumpStorage.fridge ? StashLocation.fridge : StashLocation.freezer;
          final stashEntry = MilkStashEntry(
            id: firestoreService.newId(),
            babyId: baby.id,
            userId: user.uid,
            pumpedAt: now,
            expiresAt: defaultExpiryFor(location, now),
            amountMl: widget.totalMl,
            location: location,
            isUsed: false,
            createdAt: now,
          );
          await ref.read(pumpRepositoryProvider).addMilkStash(stashEntry);
        }
      },
      onSuccess: () {
        ref.read(pumpTimerProvider.notifier).reset();
        Navigator.of(context).pop();
      },
    );
  }
}

class _StorageChip extends StatelessWidget {
  const _StorageChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.lilac,
    );
  }
}
