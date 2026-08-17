import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/notification_service.dart';
import '../../features/wonder_weeks/data/wonder_weeks_data.dart';
import '../providers/baby_provider.dart';
import '../providers/sleep_provider.dart';

/// Watches baby profile + wonder weeks and schedules smart notifications.
/// Mount this provider in the app to auto-activate.
final smartNotificationSchedulerProvider = Provider<void>((ref) {
  final baby = ref.watch(activeBabyProvider);
  if (baby == null) return;

  final svc = NotificationService.instance;

  // Schedule Wonder Weeks alerts for all future leaps
  final leapInfos = wonderWeeksLeaps.map((l) => (
        number: l.number,
        name: l.name,
        stormStartWeek: l.stormStartWeek,
        stormEndWeek: l.stormEndWeek,
      )).toList();

  svc.scheduleWonderWeeksAlerts(
    dateOfBirth: baby.dateOfBirth,
    edd: baby.edd,
    leaps: leapInfos,
  );

  // Schedule monthly anniversary and first birthday
  svc.scheduleAnniversaryReminders(
    babyName: baby.name,
    dateOfBirth: baby.dateOfBirth,
  );
});

/// True when baby has an active sleep session. Use to suppress non-urgent notifications.
final isBabySleepingProvider = Provider<bool>((ref) {
  return ref.watch(activeSleepProvider).isActive;
});
