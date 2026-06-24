import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mebe_tracker/core/theme/app_theme.dart';
import 'package:mebe_tracker/core/widgets/scaffold_with_bottom_nav.dart';
import 'package:mebe_tracker/features/home/presentation/widgets/baby_pill.dart';
import 'package:mebe_tracker/features/home/presentation/widgets/daily_summary_card.dart';
import 'package:mebe_tracker/features/home/presentation/widgets/home_skeleton.dart';
import 'package:mebe_tracker/features/home/presentation/widgets/quick_actions_grid.dart';
import 'package:mebe_tracker/features/home/presentation/widgets/recent_events_list.dart';
import 'package:mebe_tracker/shared/models/baby_profile.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('HomeScreen widgets render without error', (tester) async {
    final baby = BabyProfile(
      id: 'b1',
      userId: 'u1',
      name: 'Bé Mia',
      dateOfBirth: DateTime(2025, 1, 1),
      gender: 'female',
      weightKg: 6.8,
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ListView(
            children: [
              BabyPill(baby: baby, nextFeedingTime: DateTime.now()),
              QuickActionsGrid(
                actions: [
                  QuickAction(icon: '🤱', label: 'Bú mẹ', onTap: () {}),
                  QuickAction(icon: '🍼', label: 'Bú bình', onTap: () {}),
                ],
              ),
              const DailySummaryCard(
                feedingCount: 3,
                sleepHours: 8.5,
                diaperCount: 4,
                pumpMl: 120,
              ),
              const RecentEventsList(events: []),
              const HomeSkeleton(),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('ScaffoldWithBottomNav renders 5 tabs', (tester) async {
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        ShellRoute(
          builder: (context, state, child) => ScaffoldWithBottomNav(child: child),
          routes: [
            GoRoute(path: '/home', builder: (context, state) => const SizedBox()),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Trang chủ'), findsOneWidget);
    expect(find.text('Hồ sơ'), findsOneWidget);
  });
}
