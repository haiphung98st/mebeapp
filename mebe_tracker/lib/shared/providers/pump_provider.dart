import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/date_utils.dart';
import '../../features/widget/widget_service.dart';
import '../models/milk_stash_entry.dart';
import '../models/pump_entry.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';
import 'baby_provider.dart';
import 'home_provider.dart';

class PumpTimerState {
  const PumpTimerState({
    this.leftRunning = false,
    this.rightRunning = false,
    this.leftElapsedSeconds = 0,
    this.rightElapsedSeconds = 0,
    this.leftAmountMl = 0,
    this.rightAmountMl = 0,
    this.sessionStartTime,
  });

  final bool leftRunning;
  final bool rightRunning;
  final int leftElapsedSeconds;
  final int rightElapsedSeconds;
  final double leftAmountMl;
  final double rightAmountMl;
  final DateTime? sessionStartTime;

  bool get hasSession => sessionStartTime != null;

  PumpTimerState copyWith({
    bool? leftRunning,
    bool? rightRunning,
    int? leftElapsedSeconds,
    int? rightElapsedSeconds,
    double? leftAmountMl,
    double? rightAmountMl,
    DateTime? sessionStartTime,
  }) {
    return PumpTimerState(
      leftRunning: leftRunning ?? this.leftRunning,
      rightRunning: rightRunning ?? this.rightRunning,
      leftElapsedSeconds: leftElapsedSeconds ?? this.leftElapsedSeconds,
      rightElapsedSeconds: rightElapsedSeconds ?? this.rightElapsedSeconds,
      leftAmountMl: leftAmountMl ?? this.leftAmountMl,
      rightAmountMl: rightAmountMl ?? this.rightAmountMl,
      sessionStartTime: sessionStartTime ?? this.sessionStartTime,
    );
  }
}

class PumpTimerNotifier extends StateNotifier<PumpTimerState> {
  PumpTimerNotifier() : super(const PumpTimerState());

  Timer? _leftTicker;
  Timer? _rightTicker;

  void startSession() {
    if (state.hasSession) return;
    state = state.copyWith(sessionStartTime: DateTime.now());
  }

  void startLeft() {
    if (state.leftRunning) return;
    if (!state.hasSession) startSession();
    state = state.copyWith(leftRunning: true);
    _leftTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(leftElapsedSeconds: state.leftElapsedSeconds + 1);
    });
  }

  void pauseLeft() {
    _leftTicker?.cancel();
    state = state.copyWith(leftRunning: false);
  }

  void startRight() {
    if (state.rightRunning) return;
    if (!state.hasSession) startSession();
    state = state.copyWith(rightRunning: true);
    _rightTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(rightElapsedSeconds: state.rightElapsedSeconds + 1);
    });
  }

  void pauseRight() {
    _rightTicker?.cancel();
    state = state.copyWith(rightRunning: false);
  }

  void setLeftAmount(double amountMl) {
    state = state.copyWith(leftAmountMl: amountMl.clamp(0, 1000));
  }

  void setRightAmount(double amountMl) {
    state = state.copyWith(rightAmountMl: amountMl.clamp(0, 1000));
  }

  void reset() {
    _leftTicker?.cancel();
    _rightTicker?.cancel();
    state = const PumpTimerState();
  }

  @override
  void dispose() {
    _leftTicker?.cancel();
    _rightTicker?.cancel();
    super.dispose();
  }
}

final pumpTimerProvider = StateNotifierProvider<PumpTimerNotifier, PumpTimerState>(
  (ref) => PumpTimerNotifier(),
);

final milkStashProvider = StreamProvider<List<MilkStashEntry>>((ref) {
  final user = ref.watch(currentUserProvider);
  final baby = ref.watch(activeBabyProvider);
  if (user == null || baby == null) return Stream.value(const []);
  return ref.watch(firestoreServiceProvider).watchMilkStash(user.uid, baby.id);
});

final unusedMilkStashProvider = Provider<List<MilkStashEntry>>((ref) {
  final stash = ref.watch(milkStashProvider).value ?? const [];
  return stash.where((e) => !e.isUsed).toList();
});

final expiringStashProvider = Provider<List<MilkStashEntry>>((ref) {
  final stash = ref.watch(unusedMilkStashProvider);
  final cutoff = DateTime.now().add(const Duration(days: 2));
  return stash.where((e) => e.expiresAt != null && e.expiresAt!.isBefore(cutoff)).toList();
});

class DailyPumpTotal {
  const DailyPumpTotal({required this.day, required this.totalMl});
  final DateTime day;
  final double totalMl;
}

final weeklyPumpSummaryProvider = Provider<List<DailyPumpTotal>>((ref) {
  final pumps = ref.watch(allPumpsProvider).value ?? const [];
  final today = startOfDay(DateTime.now());
  return List.generate(7, (index) {
    final day = today.subtract(Duration(days: 6 - index));
    final total = pumps
        .where((p) => isSameDay(p.startTime, day))
        .fold<double>(0, (sum, p) => sum + (p.leftAmountMl ?? 0) + (p.rightAmountMl ?? 0));
    return DailyPumpTotal(day: day, totalMl: total);
  });
});

DateTime defaultExpiryFor(StashLocation location, DateTime pumpedAt) {
  switch (location) {
    case StashLocation.fridge:
      return pumpedAt.add(const Duration(days: 4));
    case StashLocation.freezer:
      return pumpedAt.add(const Duration(days: 180));
  }
}

class PumpRepository {
  PumpRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  Future<void> addPump(PumpEntry entry) async {
    await _firestoreService.addPump(entry);
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'pump_logged',
        parameters: {
          'storage': entry.storage.name,
          'total_ml': (entry.leftAmountMl ?? 0) + (entry.rightAmountMl ?? 0),
        },
      );
    } catch (_) {
      // Analytics failures must never block saving the pump entry.
    }
    WidgetService.triggerNativeRefresh().ignore();
  }

  Future<void> addMilkStash(MilkStashEntry entry) => _firestoreService.addMilkStash(entry);

  Future<void> markStashUsed(MilkStashEntry entry) =>
      _firestoreService.updateMilkStash(entry.copyWith(isUsed: true));

  Future<void> deleteMilkStash(String userId, String babyId, String entryId) =>
      _firestoreService.deleteMilkStash(userId, babyId, entryId);
}

final pumpRepositoryProvider = Provider<PumpRepository>((ref) {
  return PumpRepository(ref.watch(firestoreServiceProvider));
});
