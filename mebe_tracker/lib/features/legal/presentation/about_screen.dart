import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.powder,
      appBar: AppBar(
        title: const Text('Về MeBé Tracker'),
        backgroundColor: AppColors.powder,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientHome,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  alignment: Alignment.center,
                  child: const Text('🐰', style: TextStyle(fontSize: 44)),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('MeBé Tracker', style: AppTextStyles.headingLg),
                const SizedBox(height: AppSpacing.xs),
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    final version = snapshot.data;
                    final label = version == null
                        ? 'Đang tải phiên bản…'
                        : 'Phiên bản ${version.version} (${version.buildNumber})';
                    return Text(label, style: AppTextStyles.bodySm);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            'MeBé Tracker đồng hành cùng ba mẹ theo dõi từng khoảnh khắc lớn khôn của con — từ cữ bú, giấc ngủ, tăng trưởng, tiêm chủng cho đến những kỷ niệm đáng nhớ đầu đời.',
            style: AppTextStyles.bodyMd.copyWith(height: 1.6),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Được phát triển với tất cả tình yêu thương dành cho các gia đình Việt Nam. 💕',
            style: AppTextStyles.bodyMd.copyWith(height: 1.6),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text('© 2026 MeBé Tracker. Đã đăng ký bản quyền.', style: AppTextStyles.bodySm),
        ],
      ),
    );
  }
}
