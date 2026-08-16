import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/animated_bunny_avatar.dart';
import '../../../../shared/providers/baby_provider.dart';
import '../../data/avatar_provider.dart';
import '../../../subscription/presentation/premium_gate.dart';

class BabyCard extends ConsumerWidget {
  const BabyCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baby = ref.watch(activeBabyProvider);
    if (baby == null) return const SizedBox.shrink();

    final age = _ageLabel(baby.dateOfBirth);
    final avatarConfig = ref.watch(avatarConfigProvider).value ?? const AvatarConfig();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [BoxShadow(color: AppColors.divider, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => context.push('/home/profile/avatar'),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    AnimatedBunnyAvatar(config: avatarConfig, size: 56),
                    Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: AppColors.blossom,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.brush, color: Colors.white, size: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(baby.name, style: AppTextStyles.headingMd),
                    Text(age, style: AppTextStyles.bodySm),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppColors.blossom),
                tooltip: 'Sửa thông tin bé',
                onPressed: () => context.push('/home/profile/edit-baby', extra: baby),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          PremiumGate(
            feature: 'multi_baby',
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push('/create-baby'),
                icon: const Icon(Icons.add, color: AppColors.blossom),
                label: const Text('Thêm bé'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _ageLabel(DateTime dateOfBirth) {
    final now = DateTime.now();
    final totalDays = now.difference(dateOfBirth).inDays;
    final months = totalDays ~/ 30;
    final days = totalDays % 30;
    return '$months tháng $days ngày';
  }
}
