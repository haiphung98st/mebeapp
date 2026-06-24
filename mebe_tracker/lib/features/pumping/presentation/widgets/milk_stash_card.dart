import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/models/milk_stash_entry.dart';
import '../../../../shared/providers/home_provider.dart';
import '../../../../shared/providers/pump_provider.dart';

class MilkStashCard extends ConsumerWidget {
  const MilkStashCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stash = ref.watch(unusedMilkStashProvider);
    final expiring = ref.watch(expiringStashProvider);
    final todayPumps = ref.watch(todayPumpsProvider);

    final freezerMl = stash
        .where((e) => e.location == StashLocation.freezer)
        .fold<double>(0, (sum, e) => sum + e.amountMl);
    final freezerCount = stash.where((e) => e.location == StashLocation.freezer).length;

    final fridgeMl = stash
        .where((e) => e.location == StashLocation.fridge)
        .fold<double>(0, (sum, e) => sum + e.amountMl);
    final fridgeCount = stash.where((e) => e.location == StashLocation.fridge).length;

    final todayMl = todayPumps.fold<double>(
      0,
      (sum, e) => sum + (e.leftAmountMl ?? 0) + (e.rightAmountMl ?? 0),
    );

    final expiringMl = expiring.fold<double>(0, (sum, e) => sum + e.amountMl);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.lavender.withValues(alpha: 0.1),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kho sữa', style: AppTextStyles.headingMd),
          const SizedBox(height: AppSpacing.md),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: 1.8,
            children: [
              _StashCell(
                icon: '🧊',
                label: 'Tủ đông',
                amountMl: freezerMl,
                detail: '$freezerCount túi',
                color: AppColors.mint,
                background: AppColors.mintLight,
                onTap: () => context.push('/home/pumping/stash', extra: StashLocation.freezer),
              ),
              _StashCell(
                icon: '❄️',
                label: 'Tủ mát',
                amountMl: fridgeMl,
                detail: '$fridgeCount túi',
                color: AppColors.info,
                background: AppColors.lilac,
                onTap: () => context.push('/home/pumping/stash', extra: StashLocation.fridge),
              ),
              _StashCell(
                icon: '🌸',
                label: 'Hôm nay',
                amountMl: todayMl,
                detail: '${todayPumps.length} lần hút',
                color: AppColors.blossom,
                background: AppColors.blush,
              ),
              _StashCell(
                icon: '⚠️',
                label: 'Sắp hết hạn',
                amountMl: expiringMl,
                detail: '${expiring.length} túi · 2 ngày',
                color: AppColors.warning,
                background: AppColors.peachLight,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StashCell extends StatelessWidget {
  const _StashCell({
    required this.icon,
    required this.label,
    required this.amountMl,
    required this.detail,
    required this.color,
    required this.background,
    this.onTap,
  });

  final String icon;
  final String label;
  final double amountMl;
  final String detail;
  final Color color;
  final Color background;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${amountMl.toStringAsFixed(0)}ml',
                    style: AppTextStyles.headingSm.copyWith(color: color),
                  ),
                  Text(label, style: AppTextStyles.bodySm),
                  Text(detail, style: AppTextStyles.bodySm),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
