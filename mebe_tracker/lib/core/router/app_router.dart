import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/presentation/admin_shell.dart';
import '../../features/admin/presentation/screens/admin_audit_screen.dart';
import '../../features/admin/presentation/screens/admin_config_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/admin_grant_screen.dart';
import '../../features/admin/presentation/screens/admin_roles_screen.dart';
import '../../features/admin/presentation/screens/admin_users_screen.dart';
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
import '../../features/vaccine/presentation/vaccine_screen.dart';
import '../../features/subscription/presentation/subscription_screen.dart';
import '../../features/ai_chat/presentation/ai_chat_screen.dart';
import '../../features/ai_chat/presentation/chat_history_screen.dart';
import '../../features/achievement/presentation/achievements_screen.dart';
import '../../features/growth/presentation/motor_skills_screen.dart';
import '../../features/prenatal/presentation/prenatal_screen.dart';
import '../../features/growth/presentation/teeth_screen.dart';
import '../../features/profile/presentation/avatar_customizer_screen.dart';
import '../../features/community/presentation/community_screen.dart';
import '../../features/easy/presentation/easy_screen.dart';
import '../../features/health/presentation/health_screen.dart';
import '../../features/mom_health/presentation/mom_health_screen.dart';
import '../../features/wrapped/presentation/wrapped_screen.dart';
import '../../features/wonder_weeks/data/wonder_weeks_data.dart';
import '../../features/wonder_weeks/presentation/leap_detail_screen.dart';
import '../../features/wonder_weeks/presentation/wonder_weeks_screen.dart';
import '../../shared/models/baby_profile.dart';
import '../../shared/models/milk_stash_entry.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/providers/baby_provider.dart';
import '../services/notification_service.dart';
import '../widgets/scaffold_with_bottom_nav.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final babiesState = ref.watch(babiesProvider);
  final adminRoleAsync = ref.watch(adminRoleProvider);

  final router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(ref),
    redirect: (context, state) {
      // Handle mebe:// deep links from Dynamic Island and Home Screen Widget.
      final uri = state.uri;
      if (uri.scheme == 'mebe') {
        final host = uri.host;
        // mebe://timer/* — Dynamic Island
        if (host == 'timer') {
          final segment = uri.pathSegments.firstOrNull ?? '';
          switch (segment) {
            case 'feeding':
              return '/home/feeding';
            case 'pump':
              return '/home/pumping';
            case 'sleep':
              return '/home/sleep';
          }
        }
        // mebe://feeding, mebe://sleep, etc. — Home Screen Widget
        switch (host) {
          case 'feeding':
            return '/home/feeding';
          case 'sleep':
            return '/home/sleep';
          case 'diaper':
            return '/home/diaper';
          case 'pumping':
            return '/home/pumping';
          case 'home':
            return '/home';
        }
      }

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

      final adminRole = adminRoleAsync.value;
      final isAdmin = adminRole != null && adminRole.level >= AdminRole.support.level;

      // After login / create-baby, route based on role.
      // Wait for adminRoleProvider to resolve before deciding — otherwise
      // the race between async token fetch and redirect sends admins to /home.
      if (authRoutes.contains(path) || path == '/create-baby') {
        if (adminRoleAsync.isLoading) return null;
        return isAdmin ? '/admin/dashboard' : '/home';
      }

      // Block regular users from admin routes
      if (!isAdmin && !adminRoleAsync.isLoading && path.startsWith('/admin')) {
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
        path: '/ai-chat',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return AiChatScreen(
            prefilledMessage: extra?['message'] as String?,
            conversationId: extra?['conversationId'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/ai-chat/history',
        builder: (context, state) => const ChatHistoryScreen(),
      ),
      GoRoute(
        path: '/home/stats',
        builder: (context, state) => const StatsScreen(),
      ),
      GoRoute(
        path: '/achievements',
        builder: (context, state) => const AchievementsScreen(),
      ),
      GoRoute(
        path: '/home/growth/teeth',
        builder: (context, state) => const TeethScreen(),
      ),
      GoRoute(
        path: '/home/growth/motor',
        builder: (context, state) => const MotorSkillsScreen(),
      ),
      GoRoute(
        path: '/prenatal',
        builder: (context, state) => const PrenatalScreen(),
      ),
      GoRoute(
        path: '/home/profile/avatar',
        builder: (context, state) => const AvatarCustomizerScreen(),
      ),
      GoRoute(
        path: '/home/growth/wonder-weeks',
        builder: (context, state) => const WonderWeeksScreen(),
      ),
      GoRoute(
        path: '/home/growth/wonder-weeks/leap',
        builder: (context, state) =>
            LeapDetailScreen(leap: state.extra as LeapData),
      ),
      GoRoute(
        path: '/easy',
        builder: (_, __) => const EasyScreen(),
      ),
      GoRoute(
        path: '/wrapped',
        builder: (_, __) => const WrappedScreen(),
      ),
      GoRoute(
        path: '/community',
        builder: (_, __) => const CommunityScreen(),
      ),
      GoRoute(
        path: '/home/health',
        builder: (_, __) => const HealthScreen(),
      ),
      GoRoute(
        path: '/home/mom-health',
        builder: (_, __) => const MomHealthScreen(),
      ),
      GoRoute(
        path: '/home/profile/edit-baby',
        builder: (context, state) => EditBabyScreen(baby: state.extra as BabyProfile),
      ),
      // ── Admin shell ──────────────────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: '/admin/dashboard',
            builder: (_, __) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: '/admin/users',
            builder: (_, __) => const AdminUsersScreen(),
          ),
          GoRoute(
            path: '/admin/grant',
            builder: (_, __) => const AdminGrantScreen(),
          ),
          GoRoute(
            path: '/admin/audit',
            builder: (_, __) => const AdminAuditScreen(),
          ),
          GoRoute(
            path: '/admin/roles',
            builder: (_, __) => const AdminRolesScreen(),
          ),
          GoRoute(
            path: '/admin/config',
            builder: (_, __) => const AdminConfigScreen(),
          ),
        ],
      ),
      // ── User shell ───────────────────────────────────────────────────────────
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
            path: '/home/vaccine',
            builder: (context, state) => const VaccineScreen(),
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

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Ref ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
    ref.listen(babiesProvider, (_, __) => notifyListeners());
    ref.listen(adminRoleProvider, (_, __) => notifyListeners());
  }
}
