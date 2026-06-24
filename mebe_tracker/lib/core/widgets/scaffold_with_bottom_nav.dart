import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

class _NavTab {
  const _NavTab({required this.path, required this.icon, required this.label});
  final String path;
  final String icon;
  final String label;
}

/// Wraps the /home/* routes with a shared bottom navigation bar.
/// Tab contents are fully implemented in PROMPT 05.
class ScaffoldWithBottomNav extends StatelessWidget {
  const ScaffoldWithBottomNav({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    _NavTab(path: '/home', icon: '🏠', label: 'Trang chủ'),
    _NavTab(path: '/home/feeding', icon: '🍼', label: 'Ăn uống'),
    _NavTab(path: '/home/sleep', icon: '🌙', label: 'Ngủ'),
    _NavTab(path: '/home/growth', icon: '📈', label: 'Phát triển'),
    _NavTab(path: '/home/profile', icon: '👤', label: 'Hồ sơ'),
  ];

  int _indexForLocation(String location) {
    final index = _tabs.indexWhere((tab) => tab.path == location);
    return index == -1 ? -1 : index;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _indexForLocation(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.divider, width: 1.5)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 70,
            child: Row(
              children: List.generate(_tabs.length, (index) {
                final tab = _tabs[index];
                final isActive = index == currentIndex;
                return Expanded(
                  child: InkWell(
                    onTap: () => context.go(tab.path),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isActive ? AppColors.powder : Colors.transparent,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                            ),
                            child: Text(tab.icon, style: const TextStyle(fontSize: 18)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tab.label,
                            style: AppTextStyles.label.copyWith(
                              fontSize: 9,
                              color: isActive ? AppColors.blossom : AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
