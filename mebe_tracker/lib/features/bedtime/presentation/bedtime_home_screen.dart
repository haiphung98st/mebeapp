import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/models/bedtime_story.dart';
import '../../../shared/providers/baby_provider.dart';
import '../data/bedtime_provider.dart';
import 'widgets/story_cover_card.dart';

const _kBg = Color(0xFFF5EFFF);

class BedtimeHomeScreen extends ConsumerWidget {
  const BedtimeHomeScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Chào buổi sáng!';
    if (h < 18) return 'Chào buổi chiều!';
    return 'Chào buổi tối!';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baby = ref.watch(activeBabyProvider);
    final categoriesAsync = ref.watch(bedtimeCategoriesProvider);
    final storiesAsync = ref.watch(bedtimeAllStoriesProvider);

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.nightDeep.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: const Icon(Icons.close,
                            size: 18, color: AppColors.body),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_greeting(),
                              style: AppTextStyles.headingMd
                                  .copyWith(color: AppColors.nightDeep)),
                          Text(
                            'Cùng bé đi ngủ nào ba mẹ ơi!',
                            style: AppTextStyles.bodySm
                                .copyWith(color: AppColors.body),
                          ),
                        ],
                      ),
                    ),
                    // Search
                    GestureDetector(
                      onTap: () => context.push('/bedtime/stories'),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.nightDeep.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: const Icon(Icons.search,
                            size: 18, color: AppColors.body),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    // Baby avatar
                    if (baby?.avatarUrl != null)
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage(baby!.avatarUrl!),
                      )
                    else
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.lavender,
                        child: Text(
                          baby?.name.isNotEmpty == true
                              ? baby!.name[0].toUpperCase()
                              : '🐰',
                          style: AppTextStyles.bodySm
                              .copyWith(color: AppColors.white),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ── Hero promo card ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                child: _HeroCard(),
              ),
            ),

            // ── Category chips ───────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.lg),
                child: categoriesAsync.when(
                  loading: () => const SizedBox(height: 40),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (cats) => _CategoryChips(categories: cats),
                ),
              ),
            ),

            // ── Truyện nổi bật ───────────────────────────────────────────
            SliverToBoxAdapter(
              child: _SectionHeader(
                icon: '⭐',
                title: 'Truyện nổi bật',
                onMore: () => context.push('/bedtime/stories'),
              ),
            ),
            SliverToBoxAdapter(
              child: storiesAsync.when(
                loading: () => const _HorizontalPlaceholder(),
                error: (_, __) => const SizedBox.shrink(),
                data: (stories) => _FeaturedStories(stories: stories),
              ),
            ),

            // ── Âm thanh thư giãn ────────────────────────────────────────
            SliverToBoxAdapter(
              child: _SectionHeader(
                icon: '🌊',
                title: 'Âm thanh thư giãn',
                onMore: () => context.push('/bedtime/sounds'),
              ),
            ),
            const SliverToBoxAdapter(child: _AmbientSoundsRow()),

            // ── Nhạc ru ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _SectionHeader(
                icon: '🎵',
                title: 'Nhạc ru',
                onMore: () => context.push('/bedtime/lullaby'),
              ),
            ),
            const SliverToBoxAdapter(child: _LullabyPreviewRow()),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxxl)),
          ],
        ),
      ),
    );
  }
}

// ── Hero Card ─────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8DCFF), Color(0xFFD4C4FF)],
        ),
      ),
      child: Stack(
        children: [
          // Moon illustration placeholder
          Positioned(
            right: 16,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFF9E9A0),
                      const Color(0xFFF0C83C),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF0C83C).withValues(alpha: 0.4),
                      blurRadius: 20,
                    )
                  ],
                ),
                child: const Center(
                  child: Text('🌙', style: TextStyle(fontSize: 48)),
                ),
              ),
            ),
          ),
          // Stars
          const Positioned(top: 16, right: 130,
              child: Text('⭐', style: TextStyle(fontSize: 16))),
          const Positioned(top: 50, right: 160,
              child: Text('✨', style: TextStyle(fontSize: 10))),
          const Positioned(bottom: 24, right: 140,
              child: Text('⭐', style: TextStyle(fontSize: 10))),
          // Text + button
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hành trình vào giấc\ncùng bé',
                  style: AppTextStyles.headingMd
                      .copyWith(color: AppColors.nightDeep),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Tự chọn truyện, âm thanh trắng\nvà nhạc ru để tạo danh sách nghe.',
                  style:
                      AppTextStyles.bodySm.copyWith(color: AppColors.body),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => context.push('/bedtime/stories'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.nightDeep,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.play_arrow,
                            color: AppColors.white, size: 16),
                        const SizedBox(width: 4),
                        Text('Bắt đầu',
                            style: AppTextStyles.label
                                .copyWith(color: AppColors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Category Chips ────────────────────────────────────────────────────────────

class _CategoryChips extends StatefulWidget {
  const _CategoryChips({required this.categories});
  final List<StoryCategory> categories;

  @override
  State<_CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<_CategoryChips> {
  String _selected = '';

  @override
  Widget build(BuildContext context) {
    final all = [
      _FakeCategory(id: '', name: 'Tất cả', icon: '⊞'),
      ...widget.categories.map((c) => _FakeCategory(id: c.id, name: c.name)),
    ];
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: all.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (_, i) {
          final item = all[i];
          final isActive = item.id == _selected;
          return GestureDetector(
            onTap: () {
              setState(() => _selected = item.id);
              if (item.id.isNotEmpty) {
                context.push('/bedtime/stories?categoryId=${item.id}');
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color:
                    isActive ? AppColors.nightDeep : AppColors.white,
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusFull),
                border: Border.all(
                  color: isActive
                      ? AppColors.nightDeep
                      : AppColors.divider,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (item.icon != null) ...[
                    Text(item.icon!, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    item.name,
                    style: AppTextStyles.label.copyWith(
                      color: isActive ? AppColors.white : AppColors.ink,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FakeCategory {
  _FakeCategory({required this.id, required this.name, this.icon});
  final String id;
  final String name;
  final String? icon;
}

// ── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(
      {required this.title, required this.onMore, required this.icon});
  final String title;
  final String icon;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.sm),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(title,
                style:
                    AppTextStyles.headingSm.copyWith(color: AppColors.ink)),
          ),
          GestureDetector(
            onTap: onMore,
            child: Row(
              children: [
                Text('Xem thêm',
                    style: AppTextStyles.label
                        .copyWith(color: AppColors.blossom, fontSize: 13)),
                const Icon(Icons.chevron_right,
                    size: 16, color: AppColors.blossom),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Featured Stories ──────────────────────────────────────────────────────────

class _FeaturedStories extends StatelessWidget {
  const _FeaturedStories({required this.stories});
  final List<BedtimeStory> stories;

  @override
  Widget build(BuildContext context) {
    if (stories.isEmpty) {
      return const _HorizontalPlaceholder();
    }
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: stories.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (_, i) => StoryCoverCard(story: stories[i]),
      ),
    );
  }
}

class _HorizontalPlaceholder extends StatelessWidget {
  const _HorizontalPlaceholder();
  @override
  Widget build(BuildContext context) => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
}

// ── Ambient Sounds Row ────────────────────────────────────────────────────────

const _ambientSounds = [
  _AmbientItem('🌧️', 'Mưa rơi'),
  _AmbientItem('🌊', 'Sóng biển'),
  _AmbientItem('🎵', 'Nhạc ru'),
  _AmbientItem('🔥', 'Lửa lò'),
  _AmbientItem('🌬️', 'Gió nhẹ'),
  _AmbientItem('📺', 'White noise'),
];

class _AmbientItem {
  const _AmbientItem(this.icon, this.label);
  final String icon;
  final String label;
}

class _AmbientSoundsRow extends StatelessWidget {
  const _AmbientSoundsRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: _ambientSounds.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (_, i) {
          final item = _ambientSounds[i];
          return GestureDetector(
            onTap: () => context.push('/bedtime/sounds'),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.lilac,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.lavender.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: Center(
                    child: Text(item.icon,
                        style: const TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.label,
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.body, fontSize: 11),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Lullaby Preview Row ───────────────────────────────────────────────────────

const _lullabies = [
  _LullabyItem('Giấc Mơ Nhỏ', '2:36', false),
  _LullabyItem('Đêm Bình Yên', '2:51', false),
  _LullabyItem('Ru Con', '3:45', true),
  _LullabyItem('Lời Mẹ Ru', '4:10', true),
];

class _LullabyItem {
  const _LullabyItem(this.title, this.duration, this.hasLyrics);
  final String title;
  final String duration;
  final bool hasLyrics;
}

class _LullabyPreviewRow extends StatelessWidget {
  const _LullabyPreviewRow();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _lullabies.map((item) {
        return GestureDetector(
          onTap: () => context.push('/bedtime/lullaby'),
          child: Container(
            margin: const EdgeInsets.fromLTRB(
                AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              boxShadow: [
                BoxShadow(
                  color: AppColors.nightDeep.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.nightDeep, AppColors.nightMid],
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: const Center(
                    child: Text('🎵', style: TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title,
                          style: AppTextStyles.bodyMd
                              .copyWith(color: AppColors.ink)),
                      const SizedBox(height: 2),
                      Text(
                        '${item.hasLyrics ? 'Có lời' : 'Không lời'} • ${item.duration}',
                        style: AppTextStyles.bodySm
                            .copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.lilac,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow,
                      color: AppColors.nightDeep, size: 20),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
