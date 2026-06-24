import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mebe_tracker/core/theme/app_theme.dart';
import 'package:mebe_tracker/features/growth/presentation/growth_screen.dart';
import 'package:mebe_tracker/shared/models/growth_entry.dart';
import 'package:mebe_tracker/shared/models/milestone_entry.dart';
import 'package:mebe_tracker/shared/models/vaccine_entry.dart';
import 'package:mebe_tracker/shared/providers/auth_provider.dart';
import 'package:mebe_tracker/shared/providers/baby_provider.dart';
import 'package:mebe_tracker/shared/providers/growth_provider.dart';
import 'package:mebe_tracker/shared/providers/milestone_provider.dart';
import 'package:mebe_tracker/shared/providers/vaccine_provider.dart';

void main() {
  testWidgets('GrowthScreen renders growth tab and switches tabs', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWithValue(null),
          activeBabyProvider.overrideWithValue(null),
          allGrowthsProvider.overrideWith((ref) => Stream.value(const <GrowthEntry>[])),
          allMilestonesProvider.overrideWith((ref) => Stream.value(const <MilestoneEntry>[])),
          allVaccinesProvider.overrideWith((ref) => Stream.value(const <VaccineEntry>[])),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const GrowthScreen()),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Phát triển'), findsWidgets);
    expect(find.text('Chưa có dữ liệu đo'), findsOneWidget);

    await tester.tap(find.text('Mốc phát triển'));
    await tester.pump();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Tiêm chủng'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
