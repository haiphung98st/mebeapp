import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/admin/data/admin_provider.dart';
import 'features/widget/widget_provider.dart';
import 'shared/providers/auth_provider.dart';
import 'shared/providers/live_activity_provider.dart';

class MeBeApp extends ConsumerStatefulWidget {
  const MeBeApp({super.key});

  @override
  ConsumerState<MeBeApp> createState() => _MeBeAppState();
}

class _MeBeAppState extends ConsumerState<MeBeApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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

    final config = configAsync.value;
    final isAdmin = (adminRoleAsync.value?.level ?? 0) >= AdminRole.support.level;

    if (config != null && config.maintenanceMode && !isAdmin) {
      return MaterialApp(
        title: 'MeBé Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: _MaintenanceScreen(message: config.maintenanceModeMessage),
      );
    }

    return MaterialApp.router(
      title: 'MeBé Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
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
