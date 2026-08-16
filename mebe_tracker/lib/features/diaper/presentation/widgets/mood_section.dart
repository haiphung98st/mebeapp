import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/mood_entry.dart';
import '../../data/mood_provider.dart';

class MoodSection extends ConsumerWidget {
  const MoodSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayMoods = ref.watch(todayMoodsProvider);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.mint.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🧸', style: TextStyle(fontSize: 18)),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Tâm trạng hôm nay',
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _MoodPicker(onSelect: (mood) => ref.read(moodNotifierProvider.notifier).log(mood)),
          if (todayMoods.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _MoodTimeline(moods: todayMoods, onDelete: (id) => ref.read(moodNotifierProvider.notifier).delete(id)),
          ],
        ],
      ),
    );
  }
}

class _MoodPicker extends StatelessWidget {
  const _MoodPicker({required this.onSelect});
  final void Function(BabyMood) onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: BabyMood.values.map((mood) {
        return GestureDetector(
          onTap: () => onSelect(mood),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.powder,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.divider),
                ),
                child: Center(
                  child: Text(mood.emoji, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                mood.label,
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.muted,
                  fontSize: 9,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _MoodTimeline extends StatelessWidget {
  const _MoodTimeline({required this.moods, required this.onDelete});
  final List<MoodEntry> moods;
  final void Function(String) onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: AppColors.divider),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Ghi nhận hôm nay',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: moods.map((e) => _MoodDot(entry: e, onDelete: onDelete)).toList(),
        ),
      ],
    );
  }
}

class _MoodDot extends StatelessWidget {
  const _MoodDot({required this.entry, required this.onDelete});
  final MoodEntry entry;
  final void Function(String) onDelete;

  @override
  Widget build(BuildContext context) {
    final h = entry.time.hour.toString().padLeft(2, '0');
    final m = entry.time.minute.toString().padLeft(2, '0');

    return GestureDetector(
      onLongPress: () => _confirmDelete(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.powder,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(entry.mood.emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(
              '$h:$m',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.body, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xoá ghi nhận?'),
        content: Text('Xoá tâm trạng ${entry.mood.emoji} ${entry.mood.label}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete(entry.id);
            },
            child: const Text('Xoá', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
