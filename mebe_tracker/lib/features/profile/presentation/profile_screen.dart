import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/bunny_avatar.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../shared/providers/app_settings_provider.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/notification_config_provider.dart';
import '../../../shared/providers/pdf_export_provider.dart';
import '../../../shared/providers/subscription_provider.dart';
import '../../../shared/services/biometric_service.dart';
import '../../../shared/services/credential_service.dart';

import '../../subscription/presentation/premium_gate.dart';
import '../../subscription/presentation/subscription_screen.dart';
import 'widgets/baby_card.dart';
import 'widgets/family_sharing_section.dart';
import 'widgets/profile_tile.dart';

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
    final confirmed = await showConfirmDialog(
      context,
      title: 'Xóa tài khoản',
      content: 'Hành động này không thể hoàn tác. Bạn có chắc muốn xóa tài khoản?',
      confirmLabel: 'Xóa',
      confirmColor: AppColors.error,
    );
    if (confirmed == true) {
      await ref.read(authRepositoryProvider).deleteAccount();
    }
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Đăng xuất',
      content: 'Bạn có chắc muốn đăng xuất?',
      confirmLabel: 'Đăng xuất',
    );
    if (confirmed == true) {
      await ref.read(authRepositoryProvider).signOut();
    }
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng sẽ sớm được cập nhật')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cfg = ref.watch(notificationConfigProvider);
    final notifier = ref.read(notificationConfigProvider.notifier);
    final unit = ref.watch(volumeUnitProvider);

    return Scaffold(
      backgroundColor: AppColors.powder,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: _ProfileGradientHeader()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xxxl,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 1. Hồ sơ bé
                const _ProfileCard(
                  icon: '👶',
                  title: 'Hồ sơ bé',
                  child: BabyCard(),
                ),
                const SizedBox(height: AppSpacing.lg),

                // 2. Tài khoản
                _ProfileCard(
                  icon: '👤',
                  title: 'Tài khoản',
                  padded: false,
                  child: Column(
                    children: [
                      ProfileTile(
                        icon: Icons.lock_outline,
                        label: 'Đổi mật khẩu',
                        onTap: () => _changePassword(context, ref),
                      ),
                      const FamilySharingSection(),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // 3. Premium & Thanh toán
                const _ProfileCard(
                  icon: '🎀',
                  title: 'Premium & Thanh toán',
                  padded: false,
                  child: _PremiumSection(),
                ),
                const SizedBox(height: AppSpacing.lg),

                // 4. Cài đặt
                _ProfileCard(
                  icon: '⚙️',
                  title: 'Cài đặt',
                  padded: false,
                  child: Column(
                    children: [
                      SwitchListTile(
                        secondary: const Icon(Icons.local_drink_outlined, color: AppColors.blossom),
                        title: const Text('Nhắc cữ bú'),
                        value: cfg.feedingEnabled,
                        onChanged: (v) => notifier.updateFeedingConfig(enabled: v),
                      ),
                      SwitchListTile(
                        secondary: const Icon(Icons.opacity, color: AppColors.blossom),
                        title: const Text('Nhắc hút sữa'),
                        value: cfg.pumpEnabled,
                        onChanged: (v) => notifier.updatePumpConfig(enabled: v),
                      ),
                      SwitchListTile(
                        secondary: const Icon(Icons.bedtime_outlined, color: AppColors.blossom),
                        title: const Text('Nhắc giấc ngủ'),
                        value: cfg.sleepEnabled,
                        onChanged: (v) => notifier.updateSleepConfig(enabled: v),
                      ),
                      SwitchListTile(
                        secondary: const Icon(Icons.vaccines_outlined, color: AppColors.blossom),
                        title: const Text('Nhắc tiêm chủng'),
                        value: cfg.vaccineEnabled,
                        onChanged: (v) => notifier.updateVaccineConfig(enabled: v),
                      ),
                      ProfileTile(
                        icon: Icons.tune,
                        label: 'Cài đặt nhắc nhở nâng cao',
                        subtitle:
                            'Khoảng nghỉ ${cfg.quietHourStart}h–${cfg.quietHourEnd}h · Hút sữa mỗi ${cfg.pumpIntervalMinutes ~/ 60}h',
                        onTap: () => context.push('/home/profile/notifications'),
                      ),
                      const Divider(height: 1, color: AppColors.divider),
                      const _BiometricTile(),
                      SwitchListTile(
                        secondary: const Icon(Icons.straighten, color: AppColors.blossom),
                        title: const Text('Đơn vị đo'),
                        subtitle: Text(unit == VolumeUnit.ml ? 'ml' : 'oz'),
                        value: unit == VolumeUnit.oz,
                        onChanged: (value) => ref
                            .read(volumeUnitProvider.notifier)
                            .setUnit(value ? VolumeUnit.oz : VolumeUnit.ml),
                      ),
                      ProfileTile(
                        icon: Icons.language,
                        label: 'Ngôn ngữ',
                        trailing: Text('Tiếng Việt', style: AppTextStyles.bodySm),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // 5. Kỷ niệm
                _ProfileCard(
                  icon: '📸',
                  title: 'Kỷ niệm',
                  padded: false,
                  child: PremiumGate(
                    feature: 'memory',
                    child: ProfileTile(
                      icon: Icons.auto_stories_outlined,
                      label: 'Sổ tay kỷ niệm của bé',
                      subtitle: 'Nhật ký, ảnh, thư gửi tương lai và hơn thế nữa',
                      onTap: () => context.push('/memory'),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // 6. Hỗ trợ & Pháp lý
                _ProfileCard(
                  icon: '📄',
                  title: 'Hỗ trợ & Pháp lý',
                  padded: false,
                  child: Column(
                    children: [
                      ProfileTile(
                        icon: Icons.help_outline,
                        label: 'Câu hỏi thường gặp',
                        onTap: () => context.push('/legal/faq'),
                      ),
                      ProfileTile(
                        icon: Icons.support_agent_outlined,
                        label: 'Liên hệ hỗ trợ',
                        onTap: () => context.push('/legal/contact'),
                      ),
                      ProfileTile(
                        icon: Icons.description_outlined,
                        label: 'Điều khoản sử dụng',
                        onTap: () => context.push('/legal/terms'),
                      ),
                      ProfileTile(
                        icon: Icons.privacy_tip_outlined,
                        label: 'Chính sách bảo mật',
                        onTap: () => context.push('/legal/privacy'),
                      ),
                      ProfileTile(
                        icon: Icons.health_and_safety_outlined,
                        label: 'Miễn trừ trách nhiệm y tế',
                        onTap: () => context.push('/legal/disclaimer'),
                      ),
                      ProfileTile(
                        icon: Icons.star_outline,
                        label: 'Đánh giá app',
                        onTap: () => _showComingSoon(context),
                      ),
                      ProfileTile(
                        icon: Icons.info_outline,
                        label: 'Về MeBé Tracker',
                        onTap: () => context.push('/legal/about'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Danger zone
                _ProfileCard(
                  icon: '⚠️',
                  title: 'Vùng nguy hiểm',
                  padded: false,
                  child: Column(
                    children: [
                      ProfileTile(
                        icon: Icons.logout,
                        label: 'Đăng xuất',
                        textColor: AppColors.body,
                        onTap: () => _signOut(context, ref),
                      ),
                      ProfileTile(
                        icon: Icons.delete_outline,
                        label: 'Xóa tài khoản',
                        textColor: AppColors.error,
                        onTap: () => _deleteAccount(context, ref),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: FutureBuilder<PackageInfo>(
                    future: PackageInfo.fromPlatform(),
                    builder: (context, snapshot) => Text(
                      snapshot.data == null
                          ? ''
                          : 'MeBé Tracker · phiên bản ${snapshot.data!.version}',
                      style: AppTextStyles.bodySm,
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

/// Gradient header: avatar (tap to change), account name, member-since date,
/// and a Premium badge or upgrade banner.
class _ProfileGradientHeader extends ConsumerStatefulWidget {
  const _ProfileGradientHeader();

  @override
  ConsumerState<_ProfileGradientHeader> createState() => _ProfileGradientHeaderState();
}

class _ProfileGradientHeaderState extends ConsumerState<_ProfileGradientHeader> {
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
      await user.reload();
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

    final createdAt = user?.metadata.creationTime;
    final memberSince = createdAt != null
        ? 'Thành viên từ ${DateFormat('MM/yyyy').format(createdAt)}'
        : null;

    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 52, AppSpacing.lg, AppSpacing.xl),
      decoration: const BoxDecoration(
        gradient: AppColors.gradientHome,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: user == null ? null : () => _changeAvatar(user),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    if (user?.photoURL != null)
                      CircleAvatar(radius: 32, backgroundImage: NetworkImage(user!.photoURL!))
                    else
                      const BunnyAvatar(size: 64, earColor: AppColors.white),
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
                    Text(
                      user?.displayName ?? 'Người dùng MeBé',
                      style: AppTextStyles.headingLg.copyWith(color: AppColors.white),
                    ),
                    Text(
                      user?.email ?? '',
                      style: AppTextStyles.bodySm.copyWith(color: AppColors.white.withValues(alpha: 0.85)),
                    ),
                    if (memberSince != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        memberSince,
                        style: AppTextStyles.bodySm.copyWith(color: AppColors.white.withValues(alpha: 0.7)),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (isPremium)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🎀', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Thành viên Premium',
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            )
          else
            InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.auto_awesome, size: 16, color: AppColors.blossom),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Nâng cấp Premium',
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.blossom,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Card shell used for every profile section: an icon+title header, an
/// optional [padded] body inset, and a white rounded background.
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.icon,
    required this.title,
    required this.child,
    this.padded = true,
  });

  final String icon;
  final String title;
  final Widget child;
  final bool padded;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(color: AppColors.blossom.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 2)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
            child: Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: AppSpacing.xs),
                Text(title, style: AppTextStyles.headingSm),
              ],
            ),
          ),
          Padding(
            padding: padded
                ? const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg)
                : const EdgeInsets.only(bottom: AppSpacing.xs),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _PremiumSection extends ConsumerWidget {
  const _PremiumSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);
    final subscription = ref.watch(subscriptionProvider).value;

    return Column(
      children: [
        if (isPremium)
          ProfileTile(
            icon: Icons.workspace_premium_outlined,
            label: 'Gói Premium đang hoạt động',
            subtitle: subscription?.expiryDate != null
                ? 'Gia hạn: ${DateFormat('dd/MM/yyyy').format(subscription!.expiryDate!)}'
                : null,
            trailing: const SizedBox.shrink(),
          )
        else
          ProfileTile(
            icon: Icons.workspace_premium_outlined,
            label: 'Nâng cấp Premium',
            subtitle: 'Mở khóa chia sẻ gia đình, AI insight, export PDF và hơn thế nữa',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
            ),
          ),
        PremiumGate(
          feature: 'export_pdf',
          child: ProfileTile(
            icon: Icons.picture_as_pdf_outlined,
            label: 'Export dữ liệu (PDF tháng này)',
            onTap: () => _exportPdf(context, ref),
            isPremiumRequired: true,
          ),
        ),
      ],
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
}

class _BiometricTile extends ConsumerStatefulWidget {
  const _BiometricTile();

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
          secondary: Icon(icon, color: AppColors.blossom),
          title: Text('Đăng nhập bằng $name'),
          value: _enabled!,
          onChanged: _toggle,
        );
      },
    );
  }
}
