import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/baby_provider.dart';
import 'motor_entry.dart';

final allMotorsProvider = StreamProvider<List<MotorEntry>>((ref) {
  final user = ref.watch(currentUserProvider);
  final baby = ref.watch(activeBabyProvider);
  if (user == null || baby == null) return Stream.value(const []);
  return ref.watch(firestoreServiceProvider).watchMotors(user.uid, baby.id);
});

// Returns totals per day for the last 7 days: map of weekday label → total seconds
final weeklyMotorSummaryProvider = Provider<Map<String, int>>((ref) {
  final all = ref.watch(allMotorsProvider).value ?? [];
  final now = DateTime.now();
  final result = <String, int>{};
  for (var i = 6; i >= 0; i--) {
    final day = now.subtract(Duration(days: i));
    final key = _dayLabel(day);
    result[key] = 0;
  }
  for (final entry in all) {
    final diff = now.difference(entry.startTime).inDays;
    if (diff > 6) continue;
    final key = _dayLabel(entry.startTime);
    result[key] = (result[key] ?? 0) + entry.durationSeconds;
  }
  return result;
});

String _dayLabel(DateTime d) {
  const days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
  return days[d.weekday - 1];
}

class MotorNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> log(BabyActivity activity, int durationSeconds, {String? notes}) async {
    final user = ref.read(currentUserProvider);
    final baby = ref.read(activeBabyProvider);
    if (user == null || baby == null) return;

    final entry = MotorEntry(
      id: const Uuid().v4(),
      babyId: baby.id,
      userId: user.uid,
      activity: activity,
      startTime: DateTime.now(),
      durationSeconds: durationSeconds,
      notes: notes,
    );
    await ref.read(firestoreServiceProvider).addMotor(entry);
  }

  Future<void> delete(String entryId) async {
    final user = ref.read(currentUserProvider);
    final baby = ref.read(activeBabyProvider);
    if (user == null || baby == null) return;
    await ref.read(firestoreServiceProvider).deleteMotor(user.uid, baby.id, entryId);
  }
}

final motorNotifierProvider = NotifierProvider<MotorNotifier, void>(MotorNotifier.new);
