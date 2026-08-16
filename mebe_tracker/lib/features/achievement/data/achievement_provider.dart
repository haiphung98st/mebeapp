import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/providers/baby_provider.dart';
import '../../../shared/providers/home_provider.dart';
import '../../../shared/providers/subscription_provider.dart';
import '../../wonder_weeks/data/wonder_weeks_provider.dart';
import 'achievement_data.dart';

const _kPrefsKey = 'mebe_unlocked_achievements';

class AchievementState {
  const AchievementState({
    required this.unlocked,
    this.newlyUnlocked = const [],
  });

  final Set<String> unlocked;
  final List<String> newlyUnlocked;

  AchievementState copyWith({Set<String>? unlocked, List<String>? newlyUnlocked}) =>
      AchievementState(
        unlocked: unlocked ?? this.unlocked,
        newlyUnlocked: newlyUnlocked ?? this.newlyUnlocked,
      );
}

class AchievementNotifier extends StateNotifier<AchievementState> {
  AchievementNotifier() : super(const AchievementState(unlocked: {})) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kPrefsKey);
    if (raw != null) {
      final list = (jsonDecode(raw) as List).cast<String>();
      state = state.copyWith(unlocked: Set<String>.from(list));
    }
  }

  Future<void> _save(Set<String> unlocked) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrefsKey, jsonEncode(unlocked.toList()));
  }

  Future<List<String>> evaluate(AchievementInput input) async {
    final computed = AchievementEvaluator.evaluate(input);
    final newlyUnlocked = computed.difference(state.unlocked).toList();
    if (newlyUnlocked.isNotEmpty) {
      final updated = {...state.unlocked, ...computed};
      state = state.copyWith(unlocked: updated, newlyUnlocked: newlyUnlocked);
      await _save(updated);
    } else {
      if (state.newlyUnlocked.isNotEmpty) {
        state = state.copyWith(newlyUnlocked: []);
      }
    }
    return newlyUnlocked;
  }

  void clearNewlyUnlocked() {
    if (state.newlyUnlocked.isNotEmpty) {
      state = state.copyWith(newlyUnlocked: []);
    }
  }
}

final achievementNotifierProvider =
    StateNotifierProvider<AchievementNotifier, AchievementState>((ref) {
  return AchievementNotifier();
});

final achievementEvaluatorProvider = Provider<void>((ref) {
  final feedings = ref.watch(allFeedingsProvider).value ?? const [];
  final sleeps = ref.watch(allSleepsProvider).value ?? const [];
  final diapers = ref.watch(allDiapersProvider).value ?? const [];
  final pumps = ref.watch(allPumpsProvider).value ?? const [];
  final baby = ref.watch(activeBabyProvider);
  final isPremium = ref.watch(isPremiumProvider);
  final wwWeek = ref.watch(wonderWeeksCurrentWeekProvider);

  if (baby == null) return;

  final input = AchievementInput(
    feedings: feedings,
    sleeps: sleeps,
    diapers: diapers,
    pumps: pumps,
    babyCreated: true,
    isPremium: isPremium,
    babyWeekFromEdd: wwWeek,
  );

  ref.read(achievementNotifierProvider.notifier).evaluate(input).ignore();
});
