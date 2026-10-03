import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/models/bedtime_story.dart';
import '../data/bedtime_provider.dart';
import 'widgets/story_cover_card.dart';

const _kBg = Color(0xFFF5EFFF);

class BedtimeStoryListScreen extends ConsumerStatefulWidget {
  const BedtimeStoryListScreen({super.key, this.initialCategoryId});
  final String? initialCategoryId;

  @override
  ConsumerState<BedtimeStoryListScreen> createState() =>
      _BedtimeStoryListScreenState();
}

class _BedtimeStoryListScreenState
    extends ConsumerState<BedtimeStoryListScreen> {
  final _searchCtrl = TextEditingController();
  String _selectedCategory = '';
  AgeGroup? _selectedAge;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategoryId ?? '';
    _searchCtrl.addListener(() {
      setState(() => _query = _searchCtrl.text);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(bedtimeCategoriesProvider);
    final allStories = ref.watch(bedtimeAllStoriesProvider).value ?? [];
    final favIds = ref.watch(bedtimeFavoritesProvider).value ?? [];

    // Filter
    List<BedtimeStory> stories;
    if (_query.trim().isNotEmpty) {
      stories = ref.watch(searchStoriesProvider(_query));
    } else if (_selectedCategory.isEmpty) {
      stories = allStories;
    } else {
      stories = ref.watch(storiesByCategoryProvider(_selectedCategory)).value ?? [];
    }
    if (_selectedAge != null) {
      stories = stories.where((s) => s.ageGroups.contains(_selectedAge)).toList();
    }

    final featured = stories.take(4).toList();
    final ranked = stories.toList();

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          size: 18, color: AppColors.body),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text('Tất cả truyện',
                        style: AppTextStyles.headingMd
                            .copyWith(color: AppColors.nightDeep)),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.lavender.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('🐭', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),

            // ── Search bar ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusFull),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.nightDeep.withValues(alpha: 0.07),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: TextField(
                  controller: _searchCtrl,
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.ink),
                  decoration: InputDecoration(
                    hintText: 'Tìm truyện, nhân vật, chủ đề...',
                    hintStyle:
                        AppTextStyles.bodyMd.copyWith(color: AppColors.muted),
                    prefixIcon: const Icon(Icons.search,
                        color: AppColors.muted, size: 20),
                    suffixIcon: const Icon(Icons.tune,
                        color: AppColors.muted, size: 20),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Category chips ─────────────────────────────────────────
            categoriesAsync.when(
              loading: () => const SizedBox(height: 40),
              error: (_, __) => const SizedBox.shrink(),
              data: (cats) {
                final all = [
                  _Cat(id: '', name: 'Tất cả', icon: '⊞'),
                  ...cats.map((c) => _Cat(id: c.id, name: c.name)),
                ];
                return SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg),
                    itemCount: all.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (_, i) {
                      final cat = all[i];
                      final isActive = cat.id == _selectedCategory;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedCategory = cat.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.nightDeep
                                : AppColors.white,
                            borderRadius: BorderRadius.circular(
                                AppSpacing.radiusFull),
                            border: Border.all(
                              color: isActive
                                  ? AppColors.nightDeep
                                  : AppColors.divider,
                            ),
                          ),
                          child: Text(
                            '${cat.icon != null ? '${cat.icon} ' : ''}${cat.name}',
                            style: AppTextStyles.label.copyWith(
                              color: isActive
                                  ? AppColors.white
                                  : AppColors.ink,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.sm),

            // ── Age + Sort row ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  _DropdownChip<AgeGroup?>(
                    label: _selectedAge?.labelVi ?? 'Mọi độ tuổi',
                    onTap: () => _showAgeFilter(context),
                  ),
                  const Spacer(),
                  _DropdownChip<String>(
                    label: 'Mới nhất',
                    icon: Icons.swap_vert,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // ── Story list ─────────────────────────────────────────────
            Expanded(
              child: stories.isEmpty
                  ? Center(
                      child: Text('Không tìm thấy truyện',
                          style: AppTextStyles.bodyMd
                              .copyWith(color: AppColors.muted)))
                  : ListView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg),
                      children: [
                        // Đề xuất hôm nay
                        _SectionHeader(title: '⭐  Đề xuất hôm nay'),
                        const SizedBox(height: AppSpacing.sm),
                        _FeaturedGrid(
                            stories: featured, favIds: favIds, ref: ref),
                        const SizedBox(height: AppSpacing.lg),
                        // Nghe nhiều nhất
                        _SectionHeader(title: '❤️  Nghe nhiều nhất'),
                        const SizedBox(height: AppSpacing.sm),
                        ...ranked.asMap().entries.map((e) =>
                            _RankedTile(
                                rank: e.key + 1,
                                story: e.value,
                                isFav: favIds.contains(e.value.id),
                                onFav: () => _toggleFav(ref, e.value.id))),
                        const SizedBox(height: AppSpacing.xxxl),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleFav(WidgetRef ref, String id) {
    final repo = ref.read(bedtimeUserRepositoryProvider);
    repo?.toggleFavorite(id);
  }

  void _showAgeFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (_) => _AgeFilterSheet(
        selected: _selectedAge,
        onSelect: (age) => setState(() {
          _selectedAge = age;
          Navigator.pop(context);
        }),
      ),
    );
  }
}

class _Cat {
  _Cat({required this.id, required this.name, this.icon});
  final String id;
  final String name;
  final String? icon;
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Text(title,
      style: AppTextStyles.headingSm.copyWith(color: AppColors.ink));
}

class _DropdownChip<T> extends StatelessWidget {
  const _DropdownChip(
      {required this.label, required this.onTap, this.icon});
  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style:
                    AppTextStyles.label.copyWith(color: AppColors.body, fontSize: 12)),
            const SizedBox(width: 2),
            Icon(icon ?? Icons.keyboard_arrow_down,
                size: 14, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

class _FeaturedGrid extends StatelessWidget {
  const _FeaturedGrid(
      {required this.stories,
      required this.favIds,
      required this.ref});
  final List<BedtimeStory> stories;
  final List<String> favIds;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    if (stories.isEmpty) return const SizedBox.shrink();
    final items = stories.take(4).toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
      ),
      itemBuilder: (_, i) => StoryCoverCard(
        story: items[i],
        isFavorite: favIds.contains(items[i].id),
        onFavoriteTap: () =>
            ref.read(bedtimeUserRepositoryProvider)?.toggleFavorite(items[i].id),
      ),
    );
  }
}

class _RankedTile extends StatelessWidget {
  const _RankedTile(
      {required this.rank,
      required this.story,
      required this.isFav,
      required this.onFav});
  final int rank;
  final BedtimeStory story;
  final bool isFav;
  final VoidCallback onFav;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.nightDeep.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 28,
            child: Text(
              '$rank',
              style: AppTextStyles.headingSm.copyWith(
                color: rank <= 3 ? AppColors.blossom : AppColors.muted,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Mini cover
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              gradient: const LinearGradient(
                colors: [AppColors.nightDeep, AppColors.nightMid],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
                child: Text('📖', style: TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(story.title,
                    style:
                        AppTextStyles.bodyMd.copyWith(color: AppColors.ink)),
                const SizedBox(height: 2),
                Text(
                  '${story.durationLabel}  •  ${story.ageGroups.isNotEmpty ? story.ageGroups.first.labelVi : ''}',
                  style:
                      AppTextStyles.bodySm.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
          // Play button
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.nightDeep,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow,
                  color: AppColors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _AgeFilterSheet extends StatelessWidget {
  const _AgeFilterSheet({required this.selected, required this.onSelect});
  final AgeGroup? selected;
  final void Function(AgeGroup?) onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Chọn độ tuổi',
              style: AppTextStyles.headingSm.copyWith(color: AppColors.ink)),
          const SizedBox(height: AppSpacing.md),
          _AgeOption(null, 'Mọi độ tuổi', selected, onSelect),
          ...AgeGroup.values
              .map((g) => _AgeOption(g, g.labelVi, selected, onSelect)),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _AgeOption extends StatelessWidget {
  const _AgeOption(
      this.value, this.label, this.selected, this.onSelect);
  final AgeGroup? value;
  final String label;
  final AgeGroup? selected;
  final void Function(AgeGroup?) onSelect;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: () => onSelect(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: AppTextStyles.bodyMd.copyWith(
                      color: isSelected
                          ? AppColors.blossom
                          : AppColors.ink)),
            ),
            if (isSelected)
              const Icon(Icons.check, color: AppColors.blossom, size: 18),
          ],
        ),
      ),
    );
  }
}
