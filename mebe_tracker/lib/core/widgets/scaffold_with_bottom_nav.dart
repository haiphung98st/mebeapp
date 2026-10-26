import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../icons/mebe_icons.dart';

class _NavTab {
  const _NavTab({required this.path, required this.icon, required this.label});
  final String path;
  final MeBeIconType icon;
  final String label;
}

/// Wraps the /home/* routes with a shared bottom navigation bar.
/// Tab contents are fully implemented in PROMPT 05.
class ScaffoldWithBottomNav extends StatefulWidget {
  const ScaffoldWithBottomNav({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    _NavTab(path: '/home', icon: MeBeIconType.home, label: 'Trang chủ'),
    _NavTab(path: '/home/feeding', icon: MeBeIconType.breastfeed, label: 'Ăn uống'),
    _NavTab(path: '/home/sleep', icon: MeBeIconType.sleep, label: 'Ngủ'),
    _NavTab(path: '/home/growth', icon: MeBeIconType.growth, label: 'Phát triển'),
    _NavTab(path: '/home/profile', icon: MeBeIconType.profile, label: 'Hồ sơ'),
  ];

  static int _indexForLocation(String location) {
    return _tabs.indexWhere((tab) => tab.path == location);
  }

  @override
  State<ScaffoldWithBottomNav> createState() => _ScaffoldWithBottomNavState();
}

class _ScaffoldWithBottomNavState extends State<ScaffoldWithBottomNav> {
  // Last known tab-root index, used only to compute which way the next
  // tab-to-tab switch should slide — untouched while the user is off on a
  // non-tab-root push (e.g. pumping/diaper/vaccine) so the direction stays
  // correct once they land back on a tab.
  int _lastTabIndex = 0;

  // The direction of the *current* tab transition: +1 slides the new tab in
  // from the right, -1 from the left. Unlike a build-local variable, this
  // persists as-is across rebuilds that aren't a fresh tab switch (e.g. a
  // rebuild mid-animation), so PageTransitionSwitcher's in-flight Tweens
  // never get rebuilt with a different (or reset-to-0) direction — that
  // used to cause a visible jump/stutter and made the slide flip direction
  // partway through.
  int _direction = 0;

  Widget _buildTransition(Widget child, Animation<double> primaryAnimation,
      Animation<double> secondaryAnimation) {
    final curvedIn = CurvedAnimation(
      parent: primaryAnimation,
      curve: Curves.easeOutCubic,
    );
    final curvedOut = CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeInCubic,
    );
    final slideIn = Tween<Offset>(
      begin: Offset(_direction >= 0 ? 1 : -1, 0),
      end: Offset.zero,
    ).animate(curvedIn);
    final slideOut = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(_direction >= 0 ? -1 : 1, 0),
    ).animate(curvedOut);
    return SlideTransition(
      position: slideOut,
      child: SlideTransition(position: slideIn, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = ScaffoldWithBottomNav._indexForLocation(location);
    final isTabRoot = currentIndex != -1;

    // Updated synchronously (no setState/postFrameCallback) so it never
    // changes mid-animation — only when a genuinely new tab is selected.
    if (isTabRoot && currentIndex != _lastTabIndex) {
      _direction = currentIndex > _lastTabIndex ? 1 : -1;
      _lastTabIndex = currentIndex;
    }

    return Scaffold(
      body: isTabRoot
          ? PageTransitionSwitcher(
              duration: const Duration(milliseconds: 280),
              // Always false: bookkeeping stays in "forward" mode (old child's
              // secondaryAnimation runs 0→1, new child's primaryAnimation runs
              // 0→1) regardless of tab direction. We pick the slide direction
              // ourselves via `_direction`, which sidesteps
              // PageTransitionSwitcher's asymmetric handling of `reverse` —
              // fixing the new child's primaryAnimation at 1.0 instead of
              // animating it — which was causing content to snap in instead
              // of sliding when moving to a lower-index tab.
              reverse: false,
              // A stable method reference (not an inline closure) so
              // `identical(old, new)` holds across rebuilds and
              // PageTransitionSwitcher doesn't needlessly rebuild in-flight
              // transitions every time this widget rebuilds.
              transitionBuilder: _buildTransition,
              child: KeyedSubtree(key: ValueKey(currentIndex), child: widget.child),
            )
          : widget.child,
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
              children: List.generate(ScaffoldWithBottomNav._tabs.length, (index) {
                final tab = ScaffoldWithBottomNav._tabs[index];
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
                            child: MeBeIcon(type: tab.icon, size: 22, isActive: isActive),
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
