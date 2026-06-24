import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mebe_tracker/core/constants/app_colors.dart';
import 'package:mebe_tracker/core/theme/app_theme.dart';
import 'package:mebe_tracker/core/widgets/bunny_avatar.dart';
import 'package:mebe_tracker/core/widgets/bunny_header.dart';
import 'package:mebe_tracker/core/widgets/ring_chart.dart';
import 'package:mebe_tracker/core/widgets/stat_card.dart';

void main() {
  testWidgets('design system widgets render without error', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Column(
            children: [
              const BunnyAvatar(size: 60),
              const BunnyAvatar(size: 60, isAsleep: true, primaryColor: AppColors.cream),
              BunnyHeader(
                gradient: AppColors.gradientHome,
                title: 'Chào buổi sáng',
                subtitle: 'Chị Lan ơi!',
                child: const SizedBox(height: 40),
              ),
              const RingChart(
                value: 7,
                maxValue: 10,
                color: AppColors.blossom,
                trackColor: AppColors.blush,
                label: 'Cữ bú',
              ),
              const StatCard(
                icon: '⚖️',
                value: '6.8',
                title: 'kg',
                badge: 'P50',
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
