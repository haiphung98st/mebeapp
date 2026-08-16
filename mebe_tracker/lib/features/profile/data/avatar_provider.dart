import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/providers/baby_provider.dart';
import 'avatar_config.dart';

String _prefsKey(String babyId) => 'avatar_config_$babyId';

final avatarConfigProvider =
    AsyncNotifierProvider<AvatarConfigNotifier, AvatarConfig>(
        AvatarConfigNotifier.new);

class AvatarConfigNotifier extends AsyncNotifier<AvatarConfig> {
  @override
  Future<AvatarConfig> build() async {
    final baby = ref.watch(activeBabyProvider);
    if (baby == null) return const AvatarConfig();
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey(baby.id));
    if (raw == null) return const AvatarConfig();
    try {
      return AvatarConfig.fromJsonString(raw);
    } catch (_) {
      return const AvatarConfig();
    }
  }

  Future<void> save(AvatarConfig config) async {
    final baby = ref.read(activeBabyProvider);
    if (baby == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey(baby.id), config.toJsonString());
    state = AsyncData(config);
  }
}
