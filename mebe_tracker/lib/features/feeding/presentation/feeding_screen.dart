import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/bunny_header.dart';
import 'widgets/bottlefeeding_tab.dart';
import 'widgets/breastfeeding_tab.dart';

class FeedingScreen extends StatefulWidget {
  const FeedingScreen({super.key});

  @override
  State<FeedingScreen> createState() => _FeedingScreenState();
}

class _FeedingScreenState extends State<FeedingScreen> {
  int _selectedIndex = 0;

  void _onSegmentTap(int index) {
    if (index == 2) {
      context.go('/home/pumping');
      return;
    }
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.powder,
      body: Column(
        children: [
          BunnyHeader(
            gradient: AppColors.gradientFeeding,
            earLeftColor: AppColors.feedingEarLeft,
            earRightColor: AppColors.feedingEarRight,
            title: 'Ăn uống',
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.lg),
              child: _FeedingSegmentedTabs(
                selectedIndex: _selectedIndex,
                onTap: _onSegmentTap,
              ),
            ),
          ),
          Expanded(
            child: _selectedIndex == 0 ? const BreastfeedingTab() : const BottlefeedingTab(),
          ),
        ],
      ),
    );
  }
}

class _FeedingSegmentedTabs extends StatelessWidget {
  const _FeedingSegmentedTabs({required this.selectedIndex, required this.onTap});

  final int selectedIndex;
  final void Function(int) onTap;

  static const _segments = [
    (icon: '🤱', label: 'Bú mẹ'),
    (icon: '🍼', label: 'Bú bình'),
    (icon: '🥛', label: 'Hút sữa'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_segments.length, (index) {
        final segment = _segments[index];
        final isActive = index == selectedIndex;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: InkWell(
              onTap: () => onTap(index),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.white : Colors.white24,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(segment.icon, style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 2),
                    Text(
                      segment.label,
                      style: AppTextStyles.label.copyWith(
                        color: isActive ? AppColors.blossom : AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
