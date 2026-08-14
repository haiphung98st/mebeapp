import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppToast {
  AppToast._();

  static void success(BuildContext context, String message) {
    _show(context, message, AppColors.success);
  }

  static void error(BuildContext context, String message) {
    _show(context, message, AppColors.error);
  }

  static void info(BuildContext context, String message) {
    _show(context, message, AppColors.info);
  }

  static void _show(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
  }
}
