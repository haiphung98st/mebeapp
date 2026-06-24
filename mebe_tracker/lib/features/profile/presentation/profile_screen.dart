import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/providers/app_settings_provider.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/notification_settings_provider.dart';
import '../../../shared/providers/pdf_export_provider.dart';
import '../../subscription/presentation/premium_gate.dart';
import 'widgets/baby_card.dart';
import 'widgets/family_sharing_section.dart';
import 'widgets/profile_header.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _changePassword(BuildContext context, WidgetRef ref) async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đổi mật khẩu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentController,
              obscureText: true,
              decoration: const InputDecoration(hintText: 'Mật khẩu hiện tại'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: newController,
              obscureText: true,
              decoration: const InputDecoration(hintText: 'Mật khẩu mới'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Hủy')),
          TextButton(
            onPressed: () async {
              try {
                await ref
                    .read(authRepositoryProvider)
                    .changePassword(currentController.text, newController.text);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đổi mật khẩu thành công')),
                  );
                }
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đổi mật khẩu không thành công')),
                  );
                }
              }
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tài khoản'),
        content: const Text('Hành động này không thể hoàn tác. Bạn có chắc muốn xóa tài khoản?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xóa', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authRepositoryProvider).deleteAccount();
    }
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng sẽ sớm được cập nhật')),
    );
  }

  Future<void> _exportPdf(BuildContext context, WidgetRef ref) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đang tạo báo cáo PDF...')),
    );
    try {
      final report = await ref.read(monthlyReportProvider.future);
      if (report == null) return;
      final service = ref.read(pdfExportServiceProvider);
      final file = await service.generateMonthlyReport(report);
      await service.share(file);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tạo báo cáo PDF không thành công')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);
    final unit = ref.watch(volumeUnitProvider);

    return Scaffold(
      backgroundColor: AppColors.powder,
      appBar: AppBar(title: const Text('Hồ sơ'), backgroundColor: AppColors.powder, elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const ProfileHeader(),
          const SizedBox(height: AppSpacing.lg),
          const BabyCard(),
          const SizedBox(height: AppSpacing.lg),
          const FamilySharingSection(),
          const SizedBox(height: AppSpacing.lg),
          _SettingsGroup(
            title: 'NHẮC NHỞ',
            children: [
              SwitchListTile(
                title: const Text('Nhắc cữ bú'),
                value: settings.feedingReminderEnabled,
                onChanged: notifier.setFeedingReminderEnabled,
              ),
              SwitchListTile(
                title: const Text('Nhắc hút sữa'),
                value: settings.pumpReminderEnabled,
                onChanged: notifier.setPumpReminderEnabled,
              ),
              SwitchListTile(
                title: const Text('Nhắc giấc ngủ'),
                value: settings.sleepReminderEnabled,
                onChanged: notifier.setSleepReminderEnabled,
              ),
              SwitchListTile(
                title: const Text('Nhắc tiêm chủng'),
                value: settings.vaccineReminderEnabled,
                onChanged: notifier.setVaccineReminderEnabled,
              ),
              ListTile(
                title: const Text('Cài đặt nâng cao'),
                subtitle: Text(
                  'Khoảng nghỉ ${settings.quietHourStart}h–${settings.quietHourEnd}h · Hút sữa mỗi ${settings.pumpIntervalHours}h',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/home/profile/notifications'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _SettingsGroup(
            title: 'TÀI KHOẢN',
            children: [
              ListTile(
                title: const Text('Đổi mật khẩu'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _changePassword(context, ref),
              ),
              PremiumGate(
                feature: 'export_pdf',
                child: ListTile(
                  title: const Text('Export dữ liệu (PDF tháng này)'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _exportPdf(context, ref),
                ),
              ),
              ListTile(
                title: const Text('Xóa tài khoản'),
                textColor: AppColors.error,
                onTap: () => _deleteAccount(context, ref),
              ),
              ListTile(
                title: const Text('Đăng xuất'),
                onTap: () => ref.read(authRepositoryProvider).signOut(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _SettingsGroup(
            title: 'ỨNG DỤNG',
            children: [
              const ListTile(title: Text('Ngôn ngữ'), trailing: Text('Tiếng Việt')),
              SwitchListTile(
                title: const Text('Đơn vị'),
                subtitle: Text(unit == VolumeUnit.ml ? 'ml' : 'oz'),
                value: unit == VolumeUnit.oz,
                onChanged: (value) =>
                    ref.read(volumeUnitProvider.notifier).setUnit(value ? VolumeUnit.oz : VolumeUnit.ml),
              ),
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) => ListTile(
                  title: const Text('Phiên bản app'),
                  trailing: Text(snapshot.data?.version ?? '—'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _SettingsGroup(
            title: 'THÔNG TIN',
            children: [
              ListTile(title: const Text('Chính sách bảo mật'), onTap: () => _showComingSoon(context)),
              ListTile(title: const Text('Điều khoản sử dụng'), onTap: () => _showComingSoon(context)),
              ListTile(title: const Text('Liên hệ hỗ trợ'), onTap: () => _showComingSoon(context)),
              ListTile(title: const Text('Đánh giá app'), onTap: () => _showComingSoon(context)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.sm, bottom: AppSpacing.xs),
          child: Text(title, style: AppTextStyles.label),
        ),
        Material(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Column(children: children),
        ),
      ],
    );
  }
}
