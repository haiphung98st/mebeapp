import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/bunny_avatar.dart';

class _OnboardingPage {
  const _OnboardingPage({required this.icon, required this.title, required this.body});
  final Widget icon;
  final String title;
  final String body;
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  late final List<_OnboardingPage> _pages = [
    const _OnboardingPage(
      icon: BunnyAvatar(size: 120),
      title: 'Chào mừng đến với MeBé 🎀',
      body: 'Người bạn đồng hành của mẹ và bé',
    ),
    const _OnboardingPage(
      icon: Text('🍼', style: TextStyle(fontSize: 96)),
      title: 'Theo dõi mọi khoảnh khắc',
      body: 'Cữ bú, giấc ngủ, hút sữa, phát triển',
    ),
    const _OnboardingPage(
      icon: Text('👨‍👩‍👧', style: TextStyle(fontSize: 96)),
      title: 'Cùng nhau chăm bé',
      body: 'Chia sẻ với bố, ông bà, người thân',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _pages.length - 1;
    return Scaffold(
      backgroundColor: AppColors.powder,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final page = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        page.icon,
                        const SizedBox(height: AppSpacing.xxl),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.displaySm,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          page.body,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyLg,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                final active = i == _index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? AppColors.blossom : AppColors.divider,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (isLast) {
                      context.go('/login');
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                  child: Text(isLast ? 'Bắt đầu' : 'Tiếp theo'),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
