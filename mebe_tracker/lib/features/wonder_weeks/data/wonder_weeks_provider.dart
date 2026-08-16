import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/baby_provider.dart';
import 'wonder_weeks_data.dart';

final wonderWeeksCurrentLeapProvider = Provider<LeapData?>((ref) {
  final baby = ref.watch(activeBabyProvider);
  if (baby == null) return null;
  return WonderWeeksService.currentLeap(baby.dateOfBirth, baby.edd);
});

final wonderWeeksNextLeapProvider = Provider<LeapData?>((ref) {
  final baby = ref.watch(activeBabyProvider);
  if (baby == null) return null;
  return WonderWeeksService.nextLeap(baby.dateOfBirth, baby.edd);
});

final wonderWeeksAllStatesProvider = Provider<List<LeapState>>((ref) {
  final baby = ref.watch(activeBabyProvider);
  if (baby == null) return const [];
  return WonderWeeksService.allLeapStates(baby.dateOfBirth, baby.edd);
});

final wonderWeeksCurrentWeekProvider = Provider<int>((ref) {
  final baby = ref.watch(activeBabyProvider);
  if (baby == null) return 0;
  return WonderWeeksService.weeksFromBase(baby.dateOfBirth, baby.edd);
});
