import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/models/bedtime_story.dart';

class StoryCoverCard extends StatelessWidget {
  const StoryCoverCard({
    super.key,
    required this.story,
    this.width = 160,
    this.height = 200,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteTap,
  });

  final BedtimeStory story;
  final double width;
  final double height;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  // Different gradient palettes cycle per story index based on sort order
  static const _gradients = [
    [Color(0xFF3D1A6E), Color(0xFF7B5AAA)],
    [Color(0xFF1A3D6E), Color(0xFF5A7AAA)],
    [Color(0xFF1A6E3D), Color(0xFF5AAA7B)],
    [Color(0xFF6E3D1A), Color(0xFFAA7B5A)],
    [Color(0xFF6E1A3D), Color(0xFFAA5A7B)],
  ];

  @override
  Widget build(BuildContext context) {
    final gradIdx = story.sortOrder % _gradients.length;
    final grad = _gradients[gradIdx];

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        height: height,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: grad,
            ),
            boxShadow: [
              BoxShadow(
                color: grad[0].withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Stack(
            children: [
              // Decorative moon emoji (placeholder for cover art)
              Positioned(
                top: 16,
                left: 12,
                child: Opacity(
                  opacity: 0.25,
                  child: Text('🌙',
                      style: TextStyle(fontSize: width * 0.45)),
                ),
              ),
              // Bottom gradient for text
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: height * 0.55,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(AppSpacing.radiusMd),
                      bottomRight: Radius.circular(AppSpacing.radiusMd),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                    ),
                  ),
                ),
              ),
              // Favorite button
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: onFavoriteTap,
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? AppColors.blossom : AppColors.white,
                    size: 20,
                  ),
                ),
              ),
              // Premium badge
              if (story.isPremium)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.blossom,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: Text(
                      'Premium',
                      style:
                          AppTextStyles.label.copyWith(color: AppColors.white, fontSize: 9),
                    ),
                  ),
                ),
              // Title + meta
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      story.title,
                      style: AppTextStyles.bodyMd
                          .copyWith(color: AppColors.white),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.nightlight_round,
                            size: 11, color: AppColors.lavender),
                        const SizedBox(width: 3),
                        Text(
                          story.durationLabel,
                          style: AppTextStyles.bodySm
                              .copyWith(color: AppColors.lavender, fontSize: 11),
                        ),
                        if (story.ageGroups.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.face,
                              size: 11, color: AppColors.lavender),
                          const SizedBox(width: 3),
                          Text(
                            story.ageGroups.first.labelVi,
                            style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.lavender, fontSize: 11),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
