import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_colors.dart';

/// Wraps the /home/* routes with a shared bottom navigation bar.
/// Tab contents are fully implemented in PROMPT 05.
class ScaffoldWithBottomNav extends StatelessWidget {
  const ScaffoldWithBottomNav({super.key, required this.child});

  final Widget child;

  static const _tabs = ['/home', '/home/feeding', '/home/sleep', '/home/growth', '/home/profile'];

  int _indexForLocation(String location) {
    final index = _tabs.indexWhere((tab) => location == tab);
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _indexForLocation(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        backgroundColor: AppColors.white,
        onTap: (index) => context.go(_tabs[index]),
        items: const [
          BottomNavigationBarItem(icon: Text('🏠', style: TextStyle(fontSize: 20)), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Text('🍼', style: TextStyle(fontSize: 20)), label: 'Ăn uống'),
          BottomNavigationBarItem(icon: Text('🌙', style: TextStyle(fontSize: 20)), label: 'Ngủ'),
          BottomNavigationBarItem(icon: Text('📈', style: TextStyle(fontSize: 20)), label: 'Phát triển'),
          BottomNavigationBarItem(icon: Text('👤', style: TextStyle(fontSize: 20)), label: 'Hồ sơ'),
        ],
      ),
    );
  }
}
