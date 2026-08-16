import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/providers/baby_provider.dart';
import 'easy_data.dart';

String _prefsKey(String babyId) => 'easy_schedule_$babyId';

final easyScheduleProvider =
    AsyncNotifierProvider<EasyScheduleNotifier, List<EasyBlock>>(
        EasyScheduleNotifier.new);

class EasyScheduleNotifier extends AsyncNotifier<List<EasyBlock>> {
  @override
  Future<List<EasyBlock>> build() async {
    final baby = ref.watch(activeBabyProvider);
    if (baby == null) return defaultEasySchedule;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey(baby.id));
    if (raw == null) return defaultEasySchedule;
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => EasyBlock.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return defaultEasySchedule;
    }
  }

  Future<void> save(List<EasyBlock> blocks) async {
    final baby = ref.read(activeBabyProvider);
    if (baby == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _prefsKey(baby.id), jsonEncode(blocks.map((b) => b.toJson()).toList()));
    state = AsyncData(blocks);
  }

  Future<void> addBlock(EasyBlock block) async {
    final current = state.value ?? [];
    await save([...current, block]);
  }

  Future<void> removeBlock(String id) async {
    final current = state.value ?? [];
    await save(current.where((b) => b.id != id).toList());
  }

  Future<void> resetToDefault() async {
    await save(defaultEasySchedule);
  }
}
