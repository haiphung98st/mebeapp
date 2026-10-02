import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/models/bedtime_story.dart';
import '../data/bedtime_provider.dart';

class BedtimeHomeScreen extends ConsumerWidget {
  const BedtimeHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storiesAsync = ref.watch(bedtimeAllStoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.nightDeep,
      appBar: AppBar(
        backgroundColor: AppColors.nightDeep,
        foregroundColor: AppColors.white,
        title: const Text('Thỏ kể chuyện'),
        centerTitle: true,
      ),
      body: storiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Lỗi: $e', style: const TextStyle(color: AppColors.white)),
        ),
        data: (stories) => _Body(stories: stories),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.stories});

  final List<BedtimeStory> stories;

  @override
  Widget build(BuildContext context) {
    if (stories.isEmpty) {
      return Center(
        child: Text(
          'Chưa có câu chuyện nào.',
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.muted),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: stories.length,
      itemBuilder: (context, i) => _StoryTile(story: stories[i]),
    );
  }
}

class _StoryTile extends StatelessWidget {
  const _StoryTile({required this.story});

  final BedtimeStory story;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.nightMid,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          story.title,
          style: AppTextStyles.headingSm.copyWith(color: AppColors.white),
        ),
        subtitle: Text(
          story.summary,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.muted),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              story.durationLabel,
              style: AppTextStyles.label.copyWith(color: AppColors.lavender),
            ),
            if (story.isPremium)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.blossom.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Premium',
                  style: AppTextStyles.label
                      .copyWith(color: AppColors.blossom, fontSize: 9),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
