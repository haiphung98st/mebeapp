import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/providers/baby_provider.dart';
import '../../../../shared/providers/subscription_provider.dart';
import '../../../subscription/presentation/subscription_screen.dart';

class BabySwitcher extends ConsumerWidget {
  const BabySwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final babies = ref.watch(babiesProvider).value ?? [];
    if (babies.length <= 1) return const SizedBox.shrink();

    final activeBaby = ref.watch(activeBabyProvider);
    final isPremium = ref.watch(isPremiumProvider);

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: babies.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final baby = babies[index];
          final isActive = baby.id == activeBaby?.id;
          final isLocked = index > 0 && !isPremium;

          return GestureDetector(
            onTap: () {
              if (isLocked) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const SubscriptionScreen()),
                );
                return;
              }
              ref.read(activeBabyIdProvider.notifier).setActiveBaby(baby.id);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: isActive ? AppColors.blossom : AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                border: Border.all(
                  color: isActive ? AppColors.blossom : AppColors.divider,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLocked) ...[
                    const Icon(Icons.lock_outline,
                        size: 12, color: AppColors.blossom),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    baby.name,
                    style: AppTextStyles.bodySm.copyWith(
                      color: isActive ? AppColors.white : AppColors.body,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
