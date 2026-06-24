import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mebe_tracker/core/theme/app_theme.dart';
import 'package:mebe_tracker/features/diaper/presentation/diaper_screen.dart';
import 'package:mebe_tracker/shared/models/diaper_entry.dart';
import 'package:mebe_tracker/shared/providers/auth_provider.dart';
import 'package:mebe_tracker/shared/providers/baby_provider.dart';
import 'package:mebe_tracker/shared/providers/home_provider.dart';

void main() {
  testWidgets('DiaperScreen renders quick log buttons and color guide', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWithValue(null),
          activeBabyProvider.overrideWithValue(null),
          allDiapersProvider.overrideWith((ref) => Stream.value(const <DiaperEntry>[])),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const DiaperScreen()),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Ướt'), findsOneWidget);
    expect(find.text('Bẩn'), findsOneWidget);
    expect(find.text('Cả hai'), findsOneWidget);
    expect(find.text('Bảng màu tã'), findsOneWidget);
  });
}
