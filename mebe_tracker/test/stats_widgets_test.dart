import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mebe_tracker/core/theme/app_theme.dart';
import 'package:mebe_tracker/features/stats/presentation/stats_screen.dart';
import 'package:mebe_tracker/shared/models/diaper_entry.dart';
import 'package:mebe_tracker/shared/models/feeding_entry.dart';
import 'package:mebe_tracker/shared/models/growth_entry.dart';
import 'package:mebe_tracker/shared/models/pump_entry.dart';
import 'package:mebe_tracker/shared/models/sleep_entry.dart';
import 'package:mebe_tracker/shared/providers/auth_provider.dart';
import 'package:mebe_tracker/shared/providers/baby_provider.dart';
import 'package:mebe_tracker/shared/providers/growth_provider.dart';
import 'package:mebe_tracker/shared/providers/home_provider.dart';

void main() {
  testWidgets('StatsScreen renders summary cards and AI insights section', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWithValue(null),
          activeBabyProvider.overrideWithValue(null),
          allFeedingsProvider.overrideWith((ref) => Stream.value(const <FeedingEntry>[])),
          allSleepsProvider.overrideWith((ref) => Stream.value(const <SleepEntry>[])),
          allDiapersProvider.overrideWith((ref) => Stream.value(const <DiaperEntry>[])),
          allPumpsProvider.overrideWith((ref) => Stream.value(const <PumpEntry>[])),
          allGrowthsProvider.overrideWith((ref) => Stream.value(const <GrowthEntry>[])),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const StatsScreen()),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Thống kê'), findsOneWidget);
    expect(find.text('🍼 Cữ bú'), findsOneWidget);
    expect(find.text('🌙 Giấc ngủ'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('🥛 Hút sữa'), 300, scrollable: find.byType(Scrollable));
    await tester.pump();
    expect(find.text('🥛 Hút sữa'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('🌸 Thay tã'), 300, scrollable: find.byType(Scrollable));
    await tester.pump();
    expect(find.text('🌸 Thay tã'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('🐰 AI INSIGHTS'), 300, scrollable: find.byType(Scrollable));
    await tester.pump();
    expect(find.text('🐰 AI INSIGHTS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
