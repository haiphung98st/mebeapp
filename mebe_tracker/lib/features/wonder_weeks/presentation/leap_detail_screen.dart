import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../data/wonder_weeks_data.dart';

class LeapDetailScreen extends StatelessWidget {
  const LeapDetailScreen({super.key, required this.leap});

  final LeapData leap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.powder,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF5B3A8A),
            foregroundColor: AppColors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Leap ${leap.number}',
                style: AppTextStyles.headingLg.copyWith(color: AppColors.white),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF7B5AAA), Color(0xFF4A2878)],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Text('🧠', style: const TextStyle(fontSize: 48)),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        leap.name,
                        style: AppTextStyles.headingMd.copyWith(
                          color: AppColors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Tuần ${leap.stormStartWeek} – ${leap.sunnyEndWeek}',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.lilac,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xxxl,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _WeekTimeline(leap: leap),
                const SizedBox(height: AppSpacing.xl),
                _InfoCard(
                  icon: '💡',
                  title: 'Bé đang học gì?',
                  content: leap.description,
                ),
                const SizedBox(height: AppSpacing.lg),
                _SkillsCard(skills: leap.skills),
                const SizedBox(height: AppSpacing.lg),
                _TipsCard(tips: leap.tipsForMom),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekTimeline extends StatelessWidget {
  const _WeekTimeline({required this.leap});
  final LeapData leap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Lịch trình', style: AppTextStyles.bodyLg.copyWith(color: AppColors.ink)),
          const SizedBox(height: AppSpacing.md),
          _TimelineItem(
            icon: '⛈️',
            color: AppColors.warning,
            label: 'Giai đoạn bão',
            detail: 'Tuần ${leap.stormStartWeek} – ${leap.stormEndWeek}',
            description: 'Bé có thể quấy khóc, khó ngủ, bám mẹ hơn bình thường',
          ),
          const SizedBox(height: AppSpacing.md),
          _TimelineItem(
            icon: '☀️',
            color: AppColors.success,
            label: 'Giai đoạn nắng',
            detail: 'Tuần ${leap.stormEndWeek} – ${leap.sunnyEndWeek}',
            description: 'Bé trở nên vui vẻ, học các kỹ năng mới, phát triển rõ rệt',
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.detail,
    required this.description,
  });

  final String icon;
  final Color color;
  final String label;
  final String detail;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(icon, style: const TextStyle(fontSize: 20)),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(label,
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    detail,
                    style: AppTextStyles.label.copyWith(color: color),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: AppTextStyles.bodySm.copyWith(color: AppColors.body),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.content,
  });

  final String icon;
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: AppSpacing.sm),
              Text(title,
                  style: AppTextStyles.bodyLg.copyWith(color: AppColors.ink)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            content,
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.body,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillsCard extends StatelessWidget {
  const _SkillsCard({required this.skills});
  final List<String> skills;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFF7B5AAA).withOpacity(0.06),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: const Color(0xFF7B5AAA).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 20)),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Kỹ năng bé sẽ phát triển',
                style: AppTextStyles.bodyLg.copyWith(
                  color: const Color(0xFF5B3A8A),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...skills.map(
            (skill) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  ',
                      style: TextStyle(
                        color: Color(0xFF7B5AAA),
                        fontWeight: FontWeight.bold,
                      )),
                  Expanded(
                    child: Text(
                      skill,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.body,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipsCard extends StatelessWidget {
  const _TipsCard({required this.tips});
  final List<String> tips;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.blush,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.petal.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💝', style: TextStyle(fontSize: 20)),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Lời khuyên cho mẹ',
                style: AppTextStyles.bodyLg.copyWith(
                  color: AppColors.blossom,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...tips.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        margin: const EdgeInsets.only(right: AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.blossom,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${entry.key + 1}',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.body,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
