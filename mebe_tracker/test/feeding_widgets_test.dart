import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mebe_tracker/core/theme/app_theme.dart';
import 'package:mebe_tracker/features/feeding/presentation/feeding_screen.dart';
import 'package:mebe_tracker/shared/models/feeding_entry.dart';
import 'package:mebe_tracker/shared/providers/auth_provider.dart';
import 'package:mebe_tracker/shared/providers/baby_provider.dart';
import 'package:mebe_tracker/shared/providers/home_provider.dart';

void main() {
  testWidgets('FeedingScreen renders breastfeeding and bottlefeeding tabs', (tester) async {
    final router = GoRouter(
      initialLocation: '/home/feeding',
      routes: [
        GoRoute(path: '/home/feeding', builder: (context, state) => const FeedingScreen()),
        GoRoute(path: '/home/pumping', builder: (context, state) => const SizedBox()),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWithValue(null),
          activeBabyProvider.overrideWithValue(null),
          allFeedingsProvider.overrideWith((ref) => Stream.value(const <FeedingEntry>[])),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Bú mẹ'), findsOneWidget);
    expect(find.text('Bú bình'), findsOneWidget);
    expect(find.text('Hút sữa'), findsOneWidget);

    await tester.tap(find.text('Bú bình'));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Ghi cữ bú'), findsOneWidget);
  });
}
