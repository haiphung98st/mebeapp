import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/live_activity_service.dart';
import 'baby_provider.dart';
import 'feeding_provider.dart';
import 'pump_provider.dart';
import 'sleep_provider.dart';

/// Feeds timer-state changes into LiveActivityService.
/// Mount this provider once (e.g. in app.dart or a top-level Consumer)
/// by calling `ref.watch(liveActivityCoordinatorProvider)`.
final liveActivityCoordinatorProvider = Provider<void>((ref) {
  if (!Platform.isIOS) return;

  final baby = ref.watch(activeBabyProvider);
  final babyName = baby?.name ?? 'Bé';

  // ── FEEDING ──────────────────────────────────────────────────────────
  ref.listen<FeedingTimerState>(feedingTimerProvider, (prev, next) {
    final la = LiveActivityService.instance;
    final prevRunning = prev?.isRunning ?? false;
    final nextRunning = next.isRunning;
    final startTime = next.startTime ?? DateTime.now();

    if (!prevRunning && nextRunning) {
      final sideLabel = next.side.name == 'breastLeft'
          ? 'Bú trái'
          : next.side.name == 'breastRight'
              ? 'Bú phải'
              : 'Bú bình';
      la.startFeeding(
          babyName: babyName, sideLabel: sideLabel, startTime: startTime);
    } else if (prevRunning && !nextRunning) {
      la.stopFeeding();
    } else if (nextRunning) {
      final sideLabel = next.side.name == 'breastLeft'
          ? 'Bú trái'
          : next.side.name == 'breastRight'
              ? 'Bú phải'
              : 'Bú bình';
      la.updateFeeding(
          sideLabel: sideLabel,
          elapsedSeconds: next.elapsedSeconds,
          startTime: startTime);
    }
  });

  // ── PUMP ─────────────────────────────────────────────────────────────
  ref.listen<PumpTimerState>(pumpTimerProvider, (prev, next) {
    final la = LiveActivityService.instance;
    final prevActive = prev?.leftRunning == true || prev?.rightRunning == true;
    final nextActive = next.leftRunning || next.rightRunning;
    final startTime = next.sessionStartTime ?? DateTime.now();

    if (!prevActive && nextActive) {
      la.startPump(babyName: babyName, startTime: startTime);
    } else if (prevActive && !nextActive) {
      la.stopPump();
    }
  });

  // ── SLEEP ────────────────────────────────────────────────────────────
  ref.listen<ActiveSleepState>(activeSleepProvider, (prev, next) {
    final la = LiveActivityService.instance;
    final wasActive = prev?.isActive ?? false;
    final isActive = next.isActive;
    final startTime = next.startTime ?? DateTime.now();

    if (!wasActive && isActive) {
      la.startSleep(babyName: babyName, startTime: startTime);
    } else if (wasActive && !isActive) {
      la.stopSleep();
    }
  });
});
