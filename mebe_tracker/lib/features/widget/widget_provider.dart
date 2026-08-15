import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/providers/baby_provider.dart';
import '../../shared/providers/home_provider.dart';
import '../../shared/providers/subscription_provider.dart';
import 'widget_data.dart';
import 'widget_service.dart';

export 'widget_data.dart';
export 'widget_service.dart';

class WidgetDataNotifier extends AsyncNotifier<WidgetData> {
  @override
  Future<WidgetData> build() async {
    final baby = ref.watch(activeBabyProvider);
    if (baby == null) return WidgetData.empty();

    final feedings = ref.watch(allFeedingsProvider).value ?? const [];
    final sleeps = ref.watch(allSleepsProvider).value ?? const [];
    final isPremium = ref.watch(isPremiumProvider);

    final todayFeedings = ref.watch(todayFeedingsProvider);
    final todaySleeps = ref.watch(todaySleepsProvider);
    final todayDiapers = ref.watch(todayDiapersProvider);
    final todayPumps = ref.watch(todayPumpsProvider);
    final nextFeedingTime = ref.watch(nextFeedingTimeProvider);

    final lastFeeding = feedings.isNotEmpty ? feedings.first : null;
    final isSleeping = sleeps.any((s) => s.endTime == null);
    final sleepStartTime =
        isSleeping ? sleeps.firstWhere((s) => s.endTime == null).startTime : null;

    final todaySleepMinutes =
        todaySleeps.fold<int>(0, (sum, e) => sum + (e.durationMinutes ?? 0));
    final todayPumpMl = todayPumps.fold<double>(
      0,
      (sum, e) => sum + (e.leftAmountMl ?? 0) + (e.rightAmountMl ?? 0),
    );
    final babyAgeWeeks =
        DateTime.now().difference(baby.dateOfBirth).inDays ~/ 7;

    final data = WidgetData(
      babyName: baby.name,
      babyAgeWeeks: babyAgeWeeks,
      lastFeedingTime: lastFeeding?.startTime,
      lastFeedingType: lastFeeding?.type.name ?? '',
      nextFeedingTime: nextFeedingTime,
      isSleeping: isSleeping,
      sleepStartTime: sleepStartTime,
      todayFeedingCount: todayFeedings.length,
      todaySleepMinutes: todaySleepMinutes,
      todayDiaperCount: todayDiapers.length,
      todayPumpMl: todayPumpMl,
      isPremium: isPremium,
    );

    WidgetService.update(data).ignore();
    return data;
  }
}

final widgetDataProvider =
    AsyncNotifierProvider<WidgetDataNotifier, WidgetData>(WidgetDataNotifier.new);
