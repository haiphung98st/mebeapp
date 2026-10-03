import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

class BedtimeSoundsScreen extends StatefulWidget {
  const BedtimeSoundsScreen({super.key});

  @override
  State<BedtimeSoundsScreen> createState() => _BedtimeSoundsScreenState();
}

class _BedtimeSoundsScreenState extends State<BedtimeSoundsScreen> {
  String _selectedCategory = '';

  List<_Sound> get _filtered => _selectedCategory.isEmpty
      ? _sounds
      : _sounds.where((s) => s.category == _selectedCategory).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFFF),
      body: CustomScrollView(
        slivers: [
          // ── Hero header ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Container(
                  height: 220,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF3D1A6E), Color(0xFF7B5AAA)],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Decorative icons
                      const Positioned(
                          top: 70, right: 40,
                          child: Text('🌙', style: TextStyle(fontSize: 32))),
                      const Positioned(
                          top: 90, right: 80,
                          child: Text('🎵', style: TextStyle(fontSize: 18))),
                      const Positioned(
                          bottom: 40, right: 50,
                          child: Text('✨', style: TextStyle(fontSize: 14))),
                      // Title block
                      Positioned(
                        left: AppSpacing.lg,
                        bottom: AppSpacing.lg,
                        right: 120,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Âm thanh\nthư giãn',
                              style: AppTextStyles.headingLg.copyWith(
                                  color: AppColors.white),
                            ),
                            const SizedBox(height: 4),
                            Text('Thanh âm êm dịu, bé ngủ an yên',
                                style: AppTextStyles.bodyMd.copyWith(
                                    color: AppColors.lavender)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                size: 18, color: AppColors.white),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.more_horiz,
                              size: 18, color: AppColors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Category chips ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg),
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (_, i) {
                    final cat = _categories[i];
                    final isActive = cat.id == _selectedCategory;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedCategory = cat.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.blossom
                              : AppColors.white,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusFull),
                          border: Border.all(
                            color: isActive
                                ? AppColors.blossom
                                : AppColors.divider,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (cat.icon != null) ...[
                              Text(cat.icon!,
                                  style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              cat.name,
                              style: AppTextStyles.label.copyWith(
                                color: isActive
                                    ? AppColors.white
                                    : AppColors.ink,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // ── Sound grid ───────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) => _SoundCard(sound: _filtered[i]),
                childCount: _filtered.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxxl)),
        ],
      ),
    );
  }
}

// ── Static Data ───────────────────────────────────────────────────────────────

class _CategoryItem {
  const _CategoryItem(this.id, this.name, [this.icon]);
  final String id;
  final String name;
  final String? icon;
}

const _categories = [
  _CategoryItem('', 'Tất cả', '⊞'),
  _CategoryItem('rain', 'Mưa', '🌧️'),
  _CategoryItem('ocean', 'Biển', '🌊'),
  _CategoryItem('wind', 'Gió', '🌬️'),
  _CategoryItem('fire', 'Lửa', '🔥'),
  _CategoryItem('white', 'White noise', '📺'),
];

class _Sound {
  const _Sound(this.title, this.emoji, this.bgGradient, this.category);
  final String title;
  final String emoji;
  final List<Color> bgGradient;
  final String category;
}

const _sounds = [
  _Sound('Gió lộng', '🌾', [Color(0xFFB3D9FF), Color(0xFF6FA8DC)], 'wind'),
  _Sound('Lửa lò sưởi tí tách', '🔥',
      [Color(0xFFFFB347), Color(0xFFCC5500)], 'fire'),
  _Sound('Mưa rơi', '🌧️', [Color(0xFF8EC5FC), Color(0xFFE0C3FC)], 'rain'),
  _Sound('Sóng biển', '🌊', [Color(0xFF4FC3F7), Color(0xFF0288D1)], 'ocean'),
  _Sound('White noise', '📺', [Color(0xFFB0BEC5), Color(0xFF607D8B)], 'white'),
  _Sound('Tiếng chim', '🐦', [Color(0xFFA8E6CF), Color(0xFF3D9970)], 'wind'),
  _Sound('Máy hút bụi', '🌀',
      [Color(0xFFCFD8DC), Color(0xFF90A4AE)], 'white'),
  _Sound('Máy sấy tóc', '💨', [Color(0xFFFFD3B6), Color(0xFFFF9A3C)], 'wind'),
];

// ── Sound Card ────────────────────────────────────────────────────────────────

class _SoundCard extends StatefulWidget {
  const _SoundCard({required this.sound});
  final _Sound sound;

  @override
  State<_SoundCard> createState() => _SoundCardState();
}

class _SoundCardState extends State<_SoundCard> {
  bool _isPlaying = false;
  bool _isFav = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isPlaying = !_isPlaying),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.sound.bgGradient,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.sound.bgGradient[1].withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Stack(
          children: [
            // Background emoji (large, faded)
            Positioned(
              top: -8,
              left: -8,
              child: Opacity(
                opacity: 0.18,
                child: Text(widget.sound.emoji,
                    style: const TextStyle(fontSize: 90)),
              ),
            ),
            // Favorite
            Positioned(
              top: AppSpacing.sm,
              right: AppSpacing.sm,
              child: GestureDetector(
                onTap: () => setState(() => _isFav = !_isFav),
                child: Icon(
                  _isFav ? Icons.favorite : Icons.favorite_border,
                  color: _isFav ? AppColors.blossom : AppColors.white,
                  size: 20,
                ),
              ),
            ),
            // Play button center
            Center(
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: AppColors.white,
                  size: 28,
                ),
              ),
            ),
            // Title at bottom
            Positioned(
              bottom: AppSpacing.md,
              left: AppSpacing.md,
              right: AppSpacing.md,
              child: Text(
                widget.sound.title,
                style: AppTextStyles.bodyMd
                    .copyWith(color: AppColors.white),
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
