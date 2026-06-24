import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mebe_tracker/core/theme/app_theme.dart';
import 'package:mebe_tracker/features/sleep/presentation/sleep_screen.dart';
import 'package:mebe_tracker/shared/models/sleep_entry.dart';
import 'package:mebe_tracker/shared/providers/auth_provider.dart';
import 'package:mebe_tracker/shared/providers/baby_provider.dart';
import 'package:mebe_tracker/shared/providers/home_provider.dart';

void main() {
  testWidgets('SleepScreen renders start card and transitions to active card', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWithValue(null),
          activeBabyProvider.overrideWithValue(null),
          allSleepsProvider.overrideWith((ref) => Stream.value(const <SleepEntry>[])),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const SleepScreen()),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('🌙 Bắt đầu ghi giấc ngủ'), findsOneWidget);

    await tester.tap(find.text('🌙 Bắt đầu ghi giấc ngủ'));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.textContaining('Kết thúc giấc ngủ'), findsOneWidget);
  });
}
