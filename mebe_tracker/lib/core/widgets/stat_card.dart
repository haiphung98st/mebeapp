import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

/// Rounded, lightly-shadowed stat tile (e.g. weight / height / head
/// circumference summary on the Growth screen).
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.title,
    this.subtitle,
    this.badge,
    this.badgeColor,
    this.valueColor,
  });

  final String icon;
  final String value;
  final String title;
  final String? subtitle;
  final String? badge;
  final Color? badgeColor;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.blossom.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.headingLg.copyWith(
              color: valueColor ?? AppColors.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: AppTextStyles.bodySm,
            textAlign: TextAlign.center,
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(
                subtitle!,
                style: AppTextStyles.bodySm,
                textAlign: TextAlign.center,
              ),
            ),
          if (badge != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                badge!,
                style: AppTextStyles.label.copyWith(
                  color: badgeColor ?? AppColors.success,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
