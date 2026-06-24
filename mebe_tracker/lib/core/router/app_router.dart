import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/create_baby_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/providers/baby_provider.dart';
import '../widgets/scaffold_with_bottom_nav.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final babiesState = ref.watch(babiesProvider);

  return GoRouter(
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
      ShellRoute(
        builder: (context, state, child) => ScaffoldWithBottomNav(child: child),
        routes: [
          GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
          GoRoute(
            path: '/home/feeding',
            builder: (context, state) => const _PlaceholderScreen(title: 'Ăn uống'),
          ),
          GoRoute(
            path: '/home/pumping',
            builder: (context, state) => const _PlaceholderScreen(title: 'Hút sữa'),
          ),
          GoRoute(
            path: '/home/sleep',
            builder: (context, state) => const _PlaceholderScreen(title: 'Giấc ngủ'),
          ),
          GoRoute(
            path: '/home/growth',
            builder: (context, state) => const _PlaceholderScreen(title: 'Phát triển'),
          ),
          GoRoute(
            path: '/home/diaper',
            builder: (context, state) => const _PlaceholderScreen(title: 'Thay tã'),
          ),
          GoRoute(
            path: '/home/profile',
            builder: (context, state) => const _PlaceholderScreen(title: 'Hồ sơ'),
          ),
        ],
      ),
    ],
  );
});

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(title)));
  }
}

/// Bridges Riverpod state changes into a [Listenable] so GoRouter
/// re-evaluates its redirect whenever auth or baby data changes.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Ref ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
    ref.listen(babiesProvider, (_, __) => notifyListeners());
  }
}
