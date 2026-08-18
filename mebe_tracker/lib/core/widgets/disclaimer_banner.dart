import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

/// Amber medical-disclaimer strip. Pass [dismissible]: false to keep it
/// permanently visible (AiChatScreen); trackers that mostly show numbers
/// let the user dismiss it for the rest of the session.
class DisclaimerBanner extends StatefulWidget {
  const DisclaimerBanner({
    super.key,
    required this.text,
    this.dismissible = true,
  });

  final String text;
  final bool dismissible;

  @override
  State<DisclaimerBanner> createState() => _DisclaimerBannerState();
}

class _DisclaimerBannerState extends State<DisclaimerBanner> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.warning),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              widget.text,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.warning, height: 1.4),
            ),
          ),
          if (widget.dismissible) ...[
            const SizedBox(width: AppSpacing.xs),
            GestureDetector(
              onTap: () => setState(() => _dismissed = true),
              child: const Icon(Icons.close, size: 16, color: AppColors.warning),
            ),
          ],
        ],
      ),
    );
  }
}
