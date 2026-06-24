import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mebe_tracker/core/theme/app_theme.dart';
import 'package:mebe_tracker/features/pumping/presentation/milk_stash_detail_screen.dart';
import 'package:mebe_tracker/features/pumping/presentation/pumping_screen.dart';
import 'package:mebe_tracker/shared/models/milk_stash_entry.dart';
import 'package:mebe_tracker/shared/models/pump_entry.dart';
import 'package:mebe_tracker/shared/providers/auth_provider.dart';
import 'package:mebe_tracker/shared/providers/baby_provider.dart';
import 'package:mebe_tracker/shared/providers/home_provider.dart';
import 'package:mebe_tracker/shared/providers/pump_provider.dart';

void main() {
  testWidgets('PumpingScreen renders new session button and milk stash card', (tester) async {
    final router = GoRouter(
      initialLocation: '/home/pumping',
      routes: [
        GoRoute(path: '/home/pumping', builder: (context, state) => const PumpingScreen()),
        GoRoute(
          path: '/home/pumping/stash',
          builder: (context, state) =>
              MilkStashDetailScreen(location: state.extra as StashLocation),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWithValue(null),
          activeBabyProvider.overrideWithValue(null),
          allPumpsProvider.overrideWith((ref) => Stream.value(const <PumpEntry>[])),
          milkStashProvider.overrideWith((ref) => Stream.value(const <MilkStashEntry>[])),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Bắt đầu phiên hút sữa'), findsOneWidget);
    expect(find.text('Kho sữa'), findsOneWidget);

    await tester.tap(find.text('Bắt đầu'));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.textContaining('Xong phiên này'), findsOneWidget);
  });
}
