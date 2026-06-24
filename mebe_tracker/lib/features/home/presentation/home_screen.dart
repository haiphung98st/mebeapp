import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Placeholder dashboard, fleshed out fully in PROMPT 05.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.powder,
      body: Center(
        child: Text('Trang chủ', style: AppTextStyles.headingLg),
      ),
    );
  }
}
