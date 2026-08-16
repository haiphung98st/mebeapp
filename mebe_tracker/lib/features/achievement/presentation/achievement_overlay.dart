import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../data/achievement_data.dart';
import '../data/achievement_provider.dart';

class AchievementListener extends ConsumerStatefulWidget {
  const AchievementListener({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<AchievementListener> createState() => _AchievementListenerState();
}

class _AchievementListenerState extends ConsumerState<AchievementListener> {
  final List<AchievementDef> _queue = [];
  bool _showing = false;

  @override
  Widget build(BuildContext context) {
    ref.watch(achievementEvaluatorProvider);

    ref.listen(achievementNotifierProvider, (previous, next) {
      if (next.newlyUnlocked.isEmpty) return;
      for (final id in next.newlyUnlocked) {
        final def = allAchievements.firstWhere(
          (a) => a.id == id,
          orElse: () => const AchievementDef(
            id: '',
            name: '',
            description: '',
            icon: '🏆',
            category: AchievementCategory.app,
          ),
        );
        if (def.id.isNotEmpty) _queue.add(def);
      }
      ref.read(achievementNotifierProvider.notifier).clearNewlyUnlocked();
      _showNext();
    });

    return widget.child;
  }

  void _showNext() {
    if (_showing || _queue.isEmpty || !mounted) return;
    final ach = _queue.removeAt(0);
    _showing = true;
    _showToast(ach).then((_) {
      _showing = false;
      _showNext();
    });
  }

  Future<void> _showToast(AchievementDef ach) async {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _AchievementToast(
        achievement: ach,
        onDismiss: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
    await Future.delayed(const Duration(seconds: 3));
    if (entry.mounted) entry.remove();
  }
}

class _AchievementToast extends StatefulWidget {
  const _AchievementToast({required this.achievement, required this.onDismiss});
  final AchievementDef achievement;
  final VoidCallback onDismiss;

  @override
  State<_AchievementToast> createState() => _AchievementToastState();
}

class _AchievementToastState extends State<_AchievementToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();

    Future.delayed(const Duration(milliseconds: 2600), () {
      if (mounted) {
        _ctrl.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + AppSpacing.lg,
      left: AppSpacing.lg,
      right: AppSpacing.lg,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: widget.onDismiss,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blossom.withOpacity(0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: AppColors.blossom.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.blush,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          widget.achievement.icon,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🏆 Thành tích mới!',
                            style: AppTextStyles.bodySm
                                .copyWith(color: AppColors.blossom),
                          ),
                          Text(
                            widget.achievement.name,
                            style: AppTextStyles.headingSm
                                .copyWith(color: AppColors.ink),
                          ),
                          Text(
                            widget.achievement.description,
                            style: AppTextStyles.bodySm,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
