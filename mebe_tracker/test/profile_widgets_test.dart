import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mebe_tracker/core/theme/app_theme.dart';
import 'package:mebe_tracker/features/profile/presentation/profile_screen.dart';
import 'package:mebe_tracker/shared/models/baby_profile.dart';
import 'package:mebe_tracker/shared/models/family_member.dart';
import 'package:mebe_tracker/shared/providers/auth_provider.dart';
import 'package:mebe_tracker/shared/providers/baby_provider.dart';
import 'package:mebe_tracker/shared/providers/family_sharing_provider.dart';

void main() {
  testWidgets('ProfileScreen renders settings sections', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWithValue(null),
          activeBabyProvider.overrideWithValue(null),
          babiesProvider.overrideWith((ref) => Stream.value(const <BabyProfile>[])),
          familyMembersProvider.overrideWith((ref) => Stream.value(const <FamilyMember>[])),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const ProfileScreen()),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('NHẮC NHỞ'), findsOneWidget);
    expect(find.text('TÀI KHOẢN'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('ỨNG DỤNG'), 300, scrollable: find.byType(Scrollable));
    await tester.pump();
    expect(find.text('ỨNG DỤNG'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('THÔNG TIN'), 300, scrollable: find.byType(Scrollable));
    await tester.pump();
    expect(find.text('THÔNG TIN'), findsOneWidget);
    expect(find.text('Đăng xuất'), findsOneWidget);
  });
}
