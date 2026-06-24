import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mebe_tracker/core/theme/app_theme.dart';
import 'package:mebe_tracker/features/subscription/presentation/premium_gate.dart';
import 'package:mebe_tracker/features/subscription/presentation/subscription_screen.dart';
import 'package:mebe_tracker/shared/providers/auth_provider.dart';
import 'package:mebe_tracker/shared/providers/subscription_provider.dart';

void main() {
  testWidgets('SubscriptionScreen renders pricing options and CTA', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [currentUserProvider.overrideWithValue(null)],
        child: MaterialApp(theme: AppTheme.light, home: const SubscriptionScreen()),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('MeBé Premium 🎀'), findsOneWidget);
    expect(find.text('Hàng tháng'), findsOneWidget);
    expect(find.text('Hàng năm'), findsOneWidget);
    expect(find.text('Dùng thử Premium 7 ngày miễn phí'), findsOneWidget);
  });

  testWidgets('PremiumGate shows locked teaser when not premium', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [isPremiumProvider.overrideWithValue(false)],
        child: const MaterialApp(
          home: Scaffold(
            body: PremiumGate(feature: 'vaccine_schedule', child: Text('Premium content')),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Premium content'), findsNothing);
    expect(find.text('Tính năng Premium — nhấn để mở khóa'), findsOneWidget);
  });

  testWidgets('PremiumGate shows child when premium', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [isPremiumProvider.overrideWithValue(true)],
        child: const MaterialApp(
          home: Scaffold(
            body: PremiumGate(feature: 'vaccine_schedule', child: Text('Premium content')),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Premium content'), findsOneWidget);
  });
}
