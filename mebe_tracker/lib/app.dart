import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'shared/providers/live_activity_provider.dart';

class MeBeApp extends ConsumerWidget {
  const MeBeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(liveActivityCoordinatorProvider);
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'MeBé Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
