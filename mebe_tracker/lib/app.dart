import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_spacing.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/achievement/presentation/achievement_overlay.dart';
import 'features/admin/data/admin_provider.dart';
import 'features/auth/presentation/register_screen.dart'
    show kCurrentTermsVersion, kCurrentPrivacyVersion;
import 'features/widget/widget_provider.dart';
import 'shared/providers/auth_provider.dart';
import 'shared/providers/live_activity_provider.dart';
import 'shared/providers/night_mode_provider.dart';

/// Terms/privacy versions recorded on the user's registration consent doc.
class ConsentStatus {
  const ConsentStatus({required this.termsVersion, required this.privacyVersion});

  final String termsVersion;
  final String privacyVersion;

  bool get isStale =>
      termsVersion != kCurrentTermsVersion || privacyVersion != kCurrentPrivacyVersion;
}

/// Streams the signed-in user's registration consent doc so the app can
/// prompt for re-consent when [kCurrentTermsVersion]/[kCurrentPrivacyVersion]
/// have moved past what they last agreed to (including users who registered
/// before consent tracking existed, whose doc is simply missing).
final consentStatusProvider = StreamProvider<ConsentStatus?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(null);
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('consents')
      .doc('registration')
      .snapshots()
      .map((doc) {
    final data = doc.data();
    return ConsentStatus(
      termsVersion: data?['termsVersion'] as String? ?? '',
      privacyVersion: data?['privacyVersion'] as String? ?? '',
    );
  });
});

class MeBeApp extends ConsumerStatefulWidget {
  const MeBeApp({super.key});

  @override
  ConsumerState<MeBeApp> createState() => _MeBeAppState();
}

class _MeBeAppState extends ConsumerState<MeBeApp> with WidgetsBindingObserver {
  bool _consentDialogShowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  void _maybeShowConsentDialog(GoRouter router, ConsentStatus? status) {
    if (status == null || !status.isStale || _consentDialogShowing) return;
    final navContext = router.routerDelegate.navigatorKey.currentContext;
    if (navContext == null) return;
    _consentDialogShowing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showDialog<void>(
        context: navContext,
        barrierDismissible: false,
        builder: (_) => const ConsentUpdateDialog(),
      );
      _consentDialogShowing = false;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh widget data whenever user brings the app to foreground.
      ref.invalidate(widgetDataProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(liveActivityCoordinatorProvider);
    // Keep widget data live whenever the app is open.
    ref.watch(widgetDataProvider);

    final router = ref.watch(goRouterProvider);
    final configAsync = ref.watch(appConfigProvider);
    final adminRoleAsync = ref.watch(adminRoleProvider);

    ref.listen<AsyncValue<ConsentStatus?>>(consentStatusProvider, (_, next) {
      _maybeShowConsentDialog(router, next.valueOrNull);
    });

    final config = configAsync.valueOrNull;
    final isAdmin = (adminRoleAsync.valueOrNull?.level ?? 0) >= AdminRole.support.level;

    if (config != null && config.maintenanceMode && !isAdmin) {
      return MaterialApp(
        title: 'MeBé Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: _MaintenanceScreen(message: config.maintenanceModeMessage),
      );
    }

    final isNight = ref.watch(nightModeProvider);

    return MaterialApp.router(
      title: 'MeBé Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.night,
      themeMode: isNight ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
      builder: (context, child) =>
          AchievementListener(child: child ?? const SizedBox()),
    );
  }
}

/// Non-dismissible dialog shown after login when the user's saved
/// registration consent is behind [kCurrentTermsVersion]/
/// [kCurrentPrivacyVersion] — they must re-agree or sign out.
class ConsentUpdateDialog extends ConsumerWidget {
  const ConsentUpdateDialog({super.key});

  Future<void> _agree(BuildContext context, WidgetRef ref) async {
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('consents')
          .doc('registration')
          .set({
        'termsVersion': kCurrentTermsVersion,
        'privacyVersion': kCurrentPrivacyVersion,
        'consentedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    if (context.mounted) Navigator.of(context).pop();
  }

  Future<void> _disagree(BuildContext context, WidgetRef ref) async {
    Navigator.of(context).pop();
    await ref.read(authRepositoryProvider).signOut();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: const Text('Điều khoản đã được cập nhật'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chúng tôi đã cập nhật Điều khoản sử dụng và Chính sách bảo mật. '
              'Vui lòng xem lại và đồng ý để tiếp tục sử dụng MeBé Tracker.',
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: () => context.push('/legal/terms'),
              child: const Text('Xem Điều khoản sử dụng'),
            ),
            TextButton(
              onPressed: () => context.push('/legal/privacy'),
              child: const Text('Xem Chính sách bảo mật'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => _disagree(context, ref),
            child: const Text('Không đồng ý (đăng xuất)'),
          ),
          ElevatedButton(
            onPressed: () => _agree(context, ref),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.blossom),
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );
  }
}

class _MaintenanceScreen extends StatelessWidget {
  const _MaintenanceScreen({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F6),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🐰', style: TextStyle(fontSize: 72)),
              const SizedBox(height: 24),
              const Text(
                'Đang bảo trì',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3D1A35),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message.isNotEmpty
                    ? message
                    : 'Hệ thống đang bảo trì, vui lòng thử lại sau.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF7A4D6A), fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
