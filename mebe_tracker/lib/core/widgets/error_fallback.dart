import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'bunny_avatar.dart';

/// Friendly replacement for Flutter's red error screen, shown app-wide via
/// `ErrorWidget.builder` whenever a widget fails to build.
class ErrorFallback extends StatelessWidget {
  const ErrorFallback({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.powder,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BunnyAvatar(size: 56, isAsleep: true),
          const SizedBox(height: 16),
          Text(
            'Có lỗi xảy ra. Thử lại nhé 🐰',
            style: AppTextStyles.bodyMd,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
