import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/providers/subscription_provider.dart';
import 'subscription_screen.dart';

/// Wraps a premium-only [child]; shows a locked teaser that opens the
/// [SubscriptionScreen] paywall when the user isn't subscribed.
class PremiumGate extends ConsumerWidget {
  const PremiumGate({super.key, required this.feature, required this.child});

  final String feature;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);
    if (isPremium) return child;
    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.blush,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.petal),
        ),
        child: Row(
          children: [
            const Icon(Icons.lock_outline, color: AppColors.blossom, size: 18),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Tính năng Premium — nhấn để mở khóa',
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.mauve),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.blossom),
          ],
        ),
      ),
    );
  }
}
