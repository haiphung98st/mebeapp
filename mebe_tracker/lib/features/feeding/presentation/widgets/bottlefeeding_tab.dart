import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/error_handling.dart';
import '../../../../shared/models/feeding_entry.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/baby_provider.dart';
import '../../../../shared/providers/feeding_provider.dart';
import '../../../../shared/providers/home_provider.dart';
import 'feeding_log_list.dart';

const _milkTypes = ['Sữa mẹ', 'Sữa công thức'];

class BottlefeedingTab extends ConsumerWidget {
  const BottlefeedingTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayFeedings = ref.watch(todayFeedingsProvider);
    final bottleFeedings = todayFeedings.where((e) => e.type == FeedingType.bottle).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _AmountCard(),
          const SizedBox(height: AppSpacing.lg),
          Text('Lịch sử hôm nay', style: AppTextStyles.headingMd),
          const SizedBox(height: AppSpacing.md),
          FeedingLogList(entries: bottleFeedings, emptyLabel: 'Chưa có cữ bú bình hôm nay'),
        ],
      ),
    );
  }
}

class _AmountCard extends ConsumerStatefulWidget {
  const _AmountCard();

  @override
  ConsumerState<_AmountCard> createState() => _AmountCardState();
}

class _AmountCardState extends ConsumerState<_AmountCard> {
  double _amountMl = 60;
  bool _useOz = false;
  String _milkType = _milkTypes.first;

  String get _displayAmount {
    if (_useOz) return (_amountMl / 29.5735).toStringAsFixed(1);
    return _amountMl.toStringAsFixed(0);
  }

  void _step(double deltaMl) {
    setState(() {
      _amountMl = (_amountMl + deltaMl).clamp(10, 500);
    });
  }

  @override
  Widget build(BuildContext context) {
    final lastBottleFeeding = ref.watch(lastBottleFeedingProvider);

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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StepButton(icon: Icons.remove, onTap: () => _step(-10)),
              SizedBox(
                width: 140,
                child: Column(
                  children: [
                    Text(_displayAmount, style: AppTextStyles.timerDisplay.copyWith(fontSize: 40)),
                    Text(_useOz ? 'oz' : 'ml', style: AppTextStyles.bodyMd),
                  ],
                ),
              ),
              _StepButton(icon: Icons.add, onTap: () => _step(10)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _UnitToggleButton(label: 'ml', selected: !_useOz, onTap: () => setState(() => _useOz = false)),
              const SizedBox(width: AppSpacing.sm),
              _UnitToggleButton(label: 'oz', selected: _useOz, onTap: () => setState(() => _useOz = true)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          DropdownButtonFormField<String>(
            initialValue: _milkType,
            decoration: const InputDecoration(labelText: 'Loại sữa'),
            items: _milkTypes
                .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _milkType = value);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              if (lastBottleFeeding != null)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _duplicateLast(lastBottleFeeding),
                    child: const Text('Lặp lại lần trước'),
                  ),
                ),
              if (lastBottleFeeding != null) const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilledButton(
                  onPressed: () => _save(context),
                  child: const Text('Ghi cữ bú'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _duplicateLast(FeedingEntry entry) {
    setState(() {
      _amountMl = entry.amountMl ?? _amountMl;
    });
  }

  void _save(BuildContext context) {
    final user = ref.read(currentUserProvider);
    final baby = ref.read(activeBabyProvider);
    if (user == null || baby == null) return;
    final now = DateTime.now();
    final entry = FeedingEntry(
      id: ref.read(firestoreServiceProvider).newId(),
      babyId: baby.id,
      userId: user.uid,
      type: FeedingType.bottle,
      startTime: now,
      endTime: now,
      amountMl: _amountMl,
      notes: _milkType,
      createdAt: now,
    );
    runWriteAction(
      context,
      () => ref.read(feedingRepositoryProvider).addFeeding(entry),
      successMessage: 'Đã lưu cữ bú bình 🍼',
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: AppColors.powder,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.blossom),
      ),
    );
  }
}

class _UnitToggleButton extends StatelessWidget {
  const _UnitToggleButton({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: selected ? AppColors.blossom : AppColors.powder,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMd.copyWith(
            color: selected ? AppColors.white : AppColors.body,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
