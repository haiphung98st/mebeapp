import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  Future<void> _launch(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.powder,
      appBar: AppBar(
        title: const Text('Liên hệ hỗ trợ'),
        backgroundColor: AppColors.powder,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('Chúng tôi luôn sẵn sàng hỗ trợ bạn', style: AppTextStyles.headingMd),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Gửi câu hỏi, góp ý hoặc báo lỗi — đội ngũ MeBé sẽ phản hồi trong vòng 24-48 giờ.',
            style: AppTextStyles.bodySm,
          ),
          const SizedBox(height: AppSpacing.lg),
          _ContactCard(
            icon: Icons.email_outlined,
            label: 'Email hỗ trợ',
            value: 'support@mebetracker.app',
            onTap: () => _launch(Uri(scheme: 'mailto', path: 'support@mebetracker.app')),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ContactCard(
            icon: Icons.privacy_tip_outlined,
            label: 'Email bảo mật dữ liệu',
            value: 'privacy@mebetracker.app',
            onTap: () => _launch(Uri(scheme: 'mailto', path: 'privacy@mebetracker.app')),
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.blush,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: AppColors.blossom, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTextStyles.bodySm),
                    Text(value, style: AppTextStyles.bodyLg),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}
