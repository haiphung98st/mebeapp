import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.powder,
      appBar: AppBar(title: const Text('Hồ sơ'), backgroundColor: AppColors.powder, elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications_outlined, color: AppColors.blossom),
              title: Text('Cài đặt thông báo', style: AppTextStyles.bodyLg),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/home/profile/notifications'),
            ),
          ),
        ],
      ),
    );
  }
}
