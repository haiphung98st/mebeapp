import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../icons/mebe_icons.dart';

/// Shown when a stream/future provider fails to load, with a retry action.
class ErrorCard extends StatelessWidget {
  const ErrorCard({super.key, this.message = 'Không tải được dữ liệu', required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.peachLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const MeBeIcon(type: MeBeIconType.mascotBunny, size: 20),
              const SizedBox(width: 6),
              Flexible(
                child: Text(message, style: AppTextStyles.bodyMd, textAlign: TextAlign.center),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(onPressed: onRetry, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}
