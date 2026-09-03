import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/bunny_avatar.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../shared/models/baby_profile.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/baby_provider.dart';
import '../../subscription/presentation/premium_gate.dart';

class ManageBabiesScreen extends ConsumerWidget {
  const ManageBabiesScreen({super.key});

  String _ageLabel(DateTime dateOfBirth) {
    final now = DateTime.now();
    final totalDays = now.difference(dateOfBirth).inDays;
    final months = totalDays ~/ 30;
    final days = totalDays % 30;
    return '$months tháng $days ngày';
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, BabyProfile baby) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Xóa hồ sơ của ${baby.name}?',
      content: 'Toàn bộ nhật ký, ảnh và dữ liệu theo dõi của bé sẽ bị xóa vĩnh viễn. Hành động này không thể hoàn tác.',
      confirmLabel: 'Xóa',
      confirmColor: AppColors.error,
    );
    if (confirmed != true) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;
    try {
      await ref.read(firestoreServiceProvider).deleteBaby(user.uid, baby.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xóa hồ sơ của ${baby.name}')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xóa không thành công. Thử lại nhé 🐰')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final babies = ref.watch(babiesProvider).value ?? const [];
    final activeBabyId = ref.watch(activeBabyProvider)?.id;
    final canDelete = babies.length > 1;

    return Scaffold(
      backgroundColor: AppColors.powder,
      appBar: AppBar(
        title: const Text('Quản lý các bé'),
        backgroundColor: AppColors.powder,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          if (!canDelete)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Text(
                'Cần giữ lại ít nhất 1 hồ sơ bé — thêm bé khác trước khi xóa bé này.',
                style: AppTextStyles.bodySm.copyWith(color: AppColors.muted),
              ),
            ),
          ...babies.map((baby) {
            final isActive = baby.id == activeBabyId;
            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: isActive ? Border.all(color: AppColors.blossom, width: 1.5) : null,
                boxShadow: [
                  BoxShadow(color: AppColors.blossom.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  if (baby.avatarUrl != null)
                    CircleAvatar(radius: 26, backgroundImage: NetworkImage(baby.avatarUrl!))
                  else
                    const BunnyAvatar(size: 52),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(baby.name, style: AppTextStyles.headingSm),
                            if (isActive) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.powder,
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                                ),
                                child: Text('Đang chọn', style: AppTextStyles.label.copyWith(color: AppColors.blossom)),
                              ),
                            ],
                          ],
                        ),
                        Text(_ageLabel(baby.dateOfBirth), style: AppTextStyles.bodySm),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppColors.blossom),
                    tooltip: 'Sửa thông tin bé',
                    onPressed: () => context.push('/home/profile/edit-baby', extra: baby),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: canDelete ? AppColors.error : AppColors.divider),
                    tooltip: canDelete ? 'Xóa hồ sơ bé' : 'Cần giữ ít nhất 1 bé',
                    onPressed: canDelete ? () => _delete(context, ref, baby) : null,
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: AppSpacing.md),
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
}
