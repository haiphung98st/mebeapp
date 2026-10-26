import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/bunny_header.dart';
import '../../../shared/providers/home_provider.dart';
import 'bottle_manual_sheet.dart';
import 'breastfeeding_manual_sheet.dart';
import 'widgets/bottlefeeding_tab.dart';
import 'package:mebe_tracker/core/icons/mebe_glyphs.dart';
import 'package:mebe_tracker/core/icons/mebe_icons.dart';
import 'widgets/breastfeeding_tab.dart';

class FeedingScreen extends ConsumerStatefulWidget {
  const FeedingScreen({super.key});

  @override
  ConsumerState<FeedingScreen> createState() => _FeedingScreenState();
}

class _FeedingScreenState extends ConsumerState<FeedingScreen> {
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
    final todayCount = ref.watch(todayFeedingsProvider).length;
    return Scaffold(
      backgroundColor: AppColors.powder,
      floatingActionButton: FloatingActionButton.extended(
        icon: const MeBeGlyph(MeBeGlyphType.editOutlined),
        label: const Text('Nhập tay'),
        backgroundColor: AppColors.blossom,
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => _selectedIndex == 0
              ? const BreastfeedingManualSheet()
              : const BottleManualSheet(),
        ),
      ),
      body: Column(
        children: [
          BunnyHeader(
            gradient: AppColors.gradientFeeding,
            earLeftColor: AppColors.feedingEarLeft,
            earRightColor: AppColors.feedingEarRight,
            title: 'Ăn uống',
            subtitle: 'Hôm nay: $todayCount cữ',
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
    (icon: MeBeIconType.breastfeed, label: 'Bú mẹ'),
    (icon: MeBeIconType.bottle, label: 'Bú bình'),
    (icon: MeBeIconType.pump, label: 'Hút sữa'),
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
                    MeBeIcon(type: segment.icon, size: 18),
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
