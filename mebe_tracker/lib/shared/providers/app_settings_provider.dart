import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum VolumeUnit { ml, oz }

const _unitKey = 'app_volume_unit';

class VolumeUnitNotifier extends StateNotifier<VolumeUnit> {
  VolumeUnitNotifier() : super(VolumeUnit.ml) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_unitKey);
    if (saved == VolumeUnit.oz.name) state = VolumeUnit.oz;
  }

  Future<void> setUnit(VolumeUnit unit) async {
    state = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_unitKey, unit.name);
  }
}

final volumeUnitProvider = StateNotifierProvider<VolumeUnitNotifier, VolumeUnit>(
  (ref) => VolumeUnitNotifier(),
);
