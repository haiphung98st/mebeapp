import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';

import 'app.dart';
import 'core/services/notification_service.dart';
import 'core/widgets/error_fallback.dart';
import 'features/widget/widget_service.dart';
import 'shared/services/live_activity_service.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
void _workmanagerDispatcher() {
  widgetBackgroundTask();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
    return true;
  };
  ErrorWidget.builder = (details) => const ErrorFallback();

  await NotificationService.instance.init();
  await NotificationService.instance.requestPermission();
  await LiveActivityService.instance.init();
  await WidgetService.init(_workmanagerDispatcher);
  await WidgetService.scheduleBackgroundRefresh();

  WidgetService.listenForWidgetLaunch((uri) {
    if (uri == null) return;
    // Handled in app_router.dart via GoRouter deep link redirect
  });

  runApp(const ProviderScope(child: MeBeApp()));
}
