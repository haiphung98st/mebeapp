import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/create_baby_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/diaper/presentation/diaper_screen.dart';
import '../../features/feeding/presentation/feeding_screen.dart';
import '../../features/growth/presentation/growth_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/profile/presentation/edit_baby_screen.dart';
import '../../features/profile/presentation/notification_settings_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/pumping/presentation/milk_stash_detail_screen.dart';
import '../../features/pumping/presentation/pumping_screen.dart';
import '../../features/sleep/presentation/sleep_screen.dart';
import '../../features/stats/presentation/stats_screen.dart';
import '../../features/subscription/presentation/subscription_screen.dart';
import '../../shared/models/baby_profile.dart';
import '../../shared/models/milk_stash_entry.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/providers/baby_provider.dart';
import '../services/notification_service.dart';
import '../widgets/scaffold_with_bottom_nav.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final babiesState = ref.watch(babiesProvider);

  final router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(ref),
    redirect: (context, state) {
      final path = state.matchedLocation;
      if (path == '/splash') return null;

      final user = authState.value;
      final isLoggedIn = user != null;
      final authRoutes = {'/onboarding', '/login', '/register'};

      if (!isLoggedIn) {
        return authRoutes.contains(path) ? null : '/onboarding';
      }

      if (authState.isLoading) return null;

      final babies = babiesState.value;
      final hasBaby = babies != null && babies.isNotEmpty;

      if (!hasBaby) {
        return path == '/create-baby' ? null : '/create-baby';
      }

      if (authRoutes.contains(path) || path == '/create-baby') {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/create-baby', builder: (context, state) => const CreateBabyScreen()),
      GoRoute(
        path: '/home/pumping/stash',
        builder: (context, state) =>
            MilkStashDetailScreen(location: state.extra as StashLocation),
      ),
      GoRoute(
        path: '/home/profile/notifications',
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: '/home/subscription',
        builder: (context, state) => const SubscriptionScreen(),
      ),
      GoRoute(
        path: '/home/stats',
        builder: (context, state) => const StatsScreen(),
      ),
      GoRoute(
        path: '/home/profile/edit-baby',
        builder: (context, state) => EditBabyScreen(baby: state.extra as BabyProfile),
      ),
      ShellRoute(
        builder: (context, state, child) => ScaffoldWithBottomNav(child: child),
        routes: [
          GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
          GoRoute(
            path: '/home/feeding',
            builder: (context, state) => const FeedingScreen(),
          ),
          GoRoute(
            path: '/home/pumping',
            builder: (context, state) => const PumpingScreen(),
          ),
          GoRoute(
            path: '/home/sleep',
            builder: (context, state) => const SleepScreen(),
          ),
          GoRoute(
            path: '/home/growth',
            builder: (context, state) => const GrowthScreen(),
          ),
          GoRoute(
            path: '/home/diaper',
            builder: (context, state) => const DiaperScreen(),
          ),
          GoRoute(
            path: '/home/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
  NotificationService.instance.attachRouter(router);
  return router;
});

/// Bridges Riverpod state changes into a [Listenable] so GoRouter
/// re-evaluates its redirect whenever auth or baby data changes.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Ref ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
    ref.listen(babiesProvider, (_, __) => notifyListeners());
  }
}
