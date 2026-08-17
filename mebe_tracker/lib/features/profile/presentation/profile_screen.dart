import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/providers/app_settings_provider.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/notification_config_provider.dart';
import '../../../shared/providers/pdf_export_provider.dart';
import '../../../shared/services/biometric_service.dart';
import '../../../shared/services/credential_service.dart';

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
    final cfg = ref.watch(notificationConfigProvider);
    final notifier = ref.read(notificationConfigProvider.notifier);
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
                value: cfg.feedingEnabled,
                onChanged: (v) => notifier.updateFeedingConfig(enabled: v),
              ),
              SwitchListTile(
                title: const Text('Nhắc hút sữa'),
                value: cfg.pumpEnabled,
                onChanged: (v) => notifier.updatePumpConfig(enabled: v),
              ),
              SwitchListTile(
                title: const Text('Nhắc giấc ngủ'),
                value: cfg.sleepEnabled,
                onChanged: (v) => notifier.updateSleepConfig(enabled: v),
              ),
              SwitchListTile(
                title: const Text('Nhắc tiêm chủng'),
                value: cfg.vaccineEnabled,
                onChanged: (v) => notifier.updateVaccineConfig(enabled: v),
              ),
              ListTile(
                title: const Text('Cài đặt nâng cao'),
                subtitle: Text(
                  'Khoảng nghỉ ${cfg.quietHourStart}h–${cfg.quietHourEnd}h · Hút sữa mỗi ${cfg.pumpIntervalMinutes ~/ 60}h',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/home/profile/notifications'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _SettingsGroup(
            title: 'BẢO MẬT',
            children: [
              _BiometricTile(),
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

class _BiometricTile extends ConsumerStatefulWidget {
  @override
  ConsumerState<_BiometricTile> createState() => _BiometricTileState();
}

class _BiometricTileState extends ConsumerState<_BiometricTile> {
  bool? _enabled;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final svc = ref.read(biometricServiceProvider);
    final enabled = await svc.isBiometricEnabled();
    if (mounted) setState(() => _enabled = enabled);
  }

  Future<void> _toggle(bool value) async {
    final svc = ref.read(biometricServiceProvider);
    final credSvc = ref.read(credentialServiceProvider);
    if (value) {
      final available = await svc.isAvailable();
      if (!available) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thiết bị không hỗ trợ sinh trắc học')),
          );
        }
        return;
      }
      final hasCreds = await credSvc.hasSavedCredentials();
      if (!hasCreds) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Hãy bật "Nhớ mật khẩu" và đăng nhập trước nhé'),
            ),
          );
        }
        return;
      }
      final success = await svc.authenticate(reason: 'Xác thực để bật đăng nhập sinh trắc học');
      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Xác thực không thành công')),
          );
        }
        return;
      }
    }
    await svc.setBiometricEnabled(value);
    if (mounted) {
      setState(() => _enabled = value);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value ? 'Đã bật đăng nhập sinh trắc học' : 'Đã tắt đăng nhập sinh trắc học'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_enabled == null) return const SizedBox.shrink();
    return FutureBuilder<String>(
      future: ref.read(biometricServiceProvider).getBiometricName(),
      builder: (context, snap) {
        final name = snap.data ?? 'Sinh trắc học';
        final icon = name == 'Face ID' ? Icons.face_retouching_natural : Icons.fingerprint;
        return SwitchListTile(
          secondary: Icon(icon),
          title: Text('Đăng nhập bằng $name'),
          value: _enabled!,
          onChanged: _toggle,
        );
      },
    );
  }
}
