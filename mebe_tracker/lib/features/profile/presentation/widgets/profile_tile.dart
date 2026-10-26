import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/providers/subscription_provider.dart';
import 'package:mebe_tracker/core/icons/mebe_glyphs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One row inside a profile [Card] section: leading icon, label, optional
/// subtitle, and a trailing widget (defaults to a chevron). Set
/// [isPremiumRequired] to show a small lock badge for non-Premium users.
class ProfileTile extends ConsumerWidget {
  const ProfileTile({
    super.key,
    this.icon,
    this.glyph,
    required this.label,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.textColor,
    this.isPremiumRequired = false,
  }) : assert(icon != null || glyph != null, 'Provide either icon or glyph');

  final IconData? icon;
  final MeBeGlyphType? glyph;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? textColor;
  final bool isPremiumRequired;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);
    final locked = isPremiumRequired && !isPremium;
    final color = textColor ?? AppColors.ink;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 2),
      leading: glyph != null
          ? MeBeGlyph(glyph!, color: textColor ?? AppColors.blossom, size: 22)
          : Icon(icon, color: textColor ?? AppColors.blossom, size: 22),
      title: Text(label, style: AppTextStyles.bodyLg.copyWith(color: color)),
      subtitle: subtitle != null
          ? Text(subtitle!, style: AppTextStyles.bodySm)
          : null,
      trailing: trailing ??
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (locked) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  margin: const EdgeInsets.only(right: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.lilac,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: const MeBeGlyph(MeBeGlyphType.lockOutline, size: 12, color: AppColors.lavender),
                ),
              ],
              const MeBeGlyph(MeBeGlyphType.chevronRight, color: AppColors.muted, size: 20),
            ],
          ),
    );
  }
}
