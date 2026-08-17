import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notification_config_provider.dart';

final isNightModeAutoProvider = Provider<bool>((ref) {
  final config = ref.watch(notificationConfigProvider);
  final hour = DateTime.now().hour;
  final start = config.quietHourStart; // default 22
  final end = config.quietHourEnd;     // default 6
  return start > end
      ? (hour >= start || hour < end)
      : (hour >= start && hour < end);
});

class NightModeOverrideNotifier extends StateNotifier<bool?> {
  NightModeOverrideNotifier() : super(null);

  void forceEnable() => state = true;
  void forceDisable() => state = false;
  void setAuto() => state = null;
}

final nightModeOverrideProvider =
    StateNotifierProvider<NightModeOverrideNotifier, bool?>(
        (_) => NightModeOverrideNotifier());

final nightModeProvider = Provider<bool>((ref) {
  final override = ref.watch(nightModeOverrideProvider);
  return override ?? ref.watch(isNightModeAutoProvider);
});
