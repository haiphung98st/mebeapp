import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mebe_tracker/core/theme/app_theme.dart';
import 'package:mebe_tracker/features/profile/presentation/notification_settings_screen.dart';

void main() {
  testWidgets('NotificationSettingsScreen renders reminder toggles', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AppTheme.light, home: const NotificationSettingsScreen()),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Nhắc cho bé bú'), findsOneWidget);
    expect(find.text('Nhắc giờ ngủ'), findsOneWidget);
    expect(find.text('Nhắc sữa sắp hết hạn'), findsOneWidget);
    expect(find.text('Nhắc lịch tiêm chủng'), findsOneWidget);
    expect(find.text('Nhắc hút sữa định kỳ'), findsOneWidget);
  });
}
