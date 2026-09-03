import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/icons/mebe_icons.dart';

/// One tappable icon+label entry inside a [HomeFeatureGroup]. Pass
/// [iconType] to render a MeBeIcon gradient illustration instead of the
/// plain [icon] emoji — used for the higher-visibility activity groups.
class HomeFeature {
  const HomeFeature({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPremium = false,
    this.iconType,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;
  final bool isPremium;
  final MeBeIconType? iconType;
}

/// Collapsible card grouping a set of related [HomeFeature]s — tap the
/// header to expand/collapse a 4-column icon grid underneath.
class HomeFeatureGroup extends StatefulWidget {
  const HomeFeatureGroup({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.featureIconBg,
    required this.name,
    required this.description,
    required this.features,
    this.badge,
    this.isPremium = false,
    this.initiallyExpanded = false,
    this.statsStrip,
  });

  final String icon;
  final Color iconBg;
  final Color featureIconBg;
  final String name;
  final String description;
  final List<HomeFeature> features;
  final String? badge;
  final bool isPremium;
  final bool initiallyExpanded;

  /// Optional row shown above the icon grid — fills what would otherwise
  /// be dead whitespace with today's at-a-glance numbers.
  final Widget? statsStrip;

  @override
  State<HomeFeatureGroup> createState() => _HomeFeatureGroupState();
}

class _HomeFeatureGroupState extends State<HomeFeatureGroup> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.blossom.withValues(alpha: _expanded ? 0.13 : 0.07),
            blurRadius: _expanded ? 20 : 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 14,
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: widget.iconBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(widget.icon, style: const TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(widget.name, style: AppTextStyles.headingSm),
                        const SizedBox(height: 1),
                        Text(widget.description, style: AppTextStyles.bodySm),
                      ],
                    ),
                  ),
                  if (widget.badge != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.powder,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      child: Text(
                        widget.badge!,
                        style: AppTextStyles.label.copyWith(color: AppColors.blossom),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ] else if (widget.isPremium) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.lilac,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      child: Text(
                        '⭐ Premium',
                        style: AppTextStyles.label.copyWith(color: AppColors.lavender),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: const Icon(Icons.expand_more, color: AppColors.muted, size: 20),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _expanded ? _buildGrid() : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(height: 1, color: AppColors.divider),
        if (widget.statsStrip != null) widget.statsStrip!,
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 10),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.features.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 0,
              crossAxisSpacing: 0,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, i) => _FeatureButton(
              feature: widget.features[i],
              iconBg: widget.featureIconBg,
            ),
          ),
        ),
      ],
    );
  }
}

class _FeatureButton extends StatelessWidget {
  const _FeatureButton({required this.feature, required this.iconBg});

  final HomeFeature feature;
  final Color iconBg;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: feature.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              if (feature.iconType != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: MeBeIcon(type: feature.iconType!, size: 54, isActive: true),
                )
              else
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(feature.icon, style: const TextStyle(fontSize: 24)),
                ),
              if (feature.isPremium)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text('⭐', style: TextStyle(fontSize: 9)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            feature.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w700, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
