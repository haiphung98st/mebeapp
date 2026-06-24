import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/bunny_avatar.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/subscription_provider.dart';
import '../../../subscription/presentation/subscription_screen.dart';

class ProfileHeader extends ConsumerStatefulWidget {
  const ProfileHeader({super.key});

  @override
  ConsumerState<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends ConsumerState<ProfileHeader> {
  bool _uploading = false;

  Future<void> _changeAvatar(User user) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 800);
    if (picked == null) return;
    setState(() => _uploading = true);
    try {
      final storageRef = FirebaseStorage.instance.ref('avatars/${user.uid}.jpg');
      await storageRef.putFile(File(picked.path));
      final url = await storageRef.getDownloadURL();
      await user.updatePhotoURL(url);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật ảnh đại diện không thành công')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isPremium = ref.watch(isPremiumProvider);

    return Row(
      children: [
        GestureDetector(
          onTap: user == null ? null : () => _changeAvatar(user),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              if (user?.photoURL != null)
                CircleAvatar(radius: 32, backgroundImage: NetworkImage(user!.photoURL!))
              else
                const BunnyAvatar(size: 64, earColor: AppColors.blossom),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: AppColors.blossom, shape: BoxShape.circle),
                child: _uploading
                    ? const SizedBox(
                        width: 10,
                        height: 10,
                        child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.white),
                      )
                    : const Icon(Icons.camera_alt, size: 12, color: AppColors.white),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user?.displayName ?? 'Người dùng MeBé', style: AppTextStyles.headingLg),
              Text(user?.email ?? '', style: AppTextStyles.bodySm),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                    decoration: BoxDecoration(
                      color: isPremium ? AppColors.blossom : AppColors.divider,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: Text(
                      isPremium ? 'Premium 🎀' : 'Free',
                      style: AppTextStyles.label.copyWith(
                        color: isPremium ? AppColors.white : AppColors.body,
                      ),
                    ),
                  ),
                  if (!isPremium) ...[
                    const SizedBox(width: AppSpacing.sm),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
                      ),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Text('Nâng cấp'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
