import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/baby_provider.dart';
import '../../../../shared/providers/home_provider.dart';
import '../../../../shared/providers/night_mode_provider.dart';
import 'baby_pill.dart';
import 'baby_switcher.dart';

/// Gradient header for HomeScreen: greeting + night-mode toggle, the active
/// baby's card, and (when there's more than one baby) the switcher pills.
class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final baby = ref.watch(activeBabyProvider);
    final nextFeedingTime = ref.watch(nextFeedingTimeProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        52,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      decoration: const BoxDecoration(
        gradient: AppColors.gradientHome,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Chào chị ${user?.displayName ?? 'mẹ'} ơi! 👋',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () =>
                    ref.read(nightModeOverrideProvider.notifier).forceEnable(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text('🌙', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (baby != null) BabyPill(baby: baby, nextFeedingTime: nextFeedingTime),
          const SizedBox(height: AppSpacing.sm),
          const BabySwitcher(),
        ],
      ),
    );
  }
}
