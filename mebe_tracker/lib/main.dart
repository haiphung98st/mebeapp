import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';

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
  // Lets bedtime sounds/lullabies keep playing with the app backgrounded or
  // the screen locked, and surfaces OS media controls (lock screen, Control
  // Center, Android notification) for them.
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.mebe.mebeTracker.audio',
    androidNotificationChannelName: 'MeBé — Âm thanh & nhạc ru',
    androidNotificationOngoing: true,
  );

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
    return true;
  };
  ErrorWidget.builder = (details) => const ErrorFallback();

  runApp(const ProviderScope(child: MeBeApp()));

  // Non-essential startup work (notification permission dialog, live
  // activity push-token registration, widget/workmanager setup) runs after
  // the first frame instead of blocking it — any one of these plugins
  // hanging (e.g. live_activities awaiting an APNs push token with no
  // network) must not leave the app stuck on the native launch screen.
  unawaited(_initBackgroundServices());
}

Future<void> _initBackgroundServices() async {
  try {
    await NotificationService.instance.init();
    await NotificationService.instance.requestPermission();
  } catch (_) {}
  try {
    await LiveActivityService.instance.init();
  } catch (_) {}
  try {
    await WidgetService.init(_workmanagerDispatcher);
    await WidgetService.scheduleBackgroundRefresh();
  } catch (_) {}

  WidgetService.listenForWidgetLaunch((uri) {
    if (uri == null) return;
    // Handled in app_router.dart via GoRouter deep link redirect
  });
}
