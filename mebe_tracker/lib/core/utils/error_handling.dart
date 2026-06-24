import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

/// Runs a write action (e.g. saving a log entry), reporting failures to
/// Crashlytics and showing a friendly retry message instead of failing silently.
Future<void> runWriteAction(
  BuildContext context,
  Future<void> Function() action, {
  String? successMessage,
  VoidCallback? onSuccess,
}) async {
  try {
    await action();
    if (!context.mounted) return;
    onSuccess?.call();
    if (successMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(successMessage)));
    }
  } catch (error, stackTrace) {
    await FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: false);
    if (!context.mounted) return;
    showFriendlyErrorSnackBar(context);
  }
}

void showFriendlyErrorSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Có lỗi xảy ra. Thử lại nhé 🐰')),
  );
}
