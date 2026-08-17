import 'dart:io';

import 'package:live_activities/live_activities.dart';
import 'package:uuid/uuid.dart';

/// Wraps the live_activities plugin for Dynamic Island / Lock Screen
/// Live Activities (iOS 16.1+). All calls are no-ops on Android, on older
/// iOS versions, and on builds signed with a personal (free) Apple team —
/// the plugin always requests a push token internally, which Apple blocks
/// for personal teams, so every call is guarded to fail silently instead
/// of throwing.
class LiveActivityService {
  LiveActivityService._();

  static final instance = LiveActivityService._();

  final _plugin = LiveActivities();
  final _uuid = const Uuid();
  String? _feedingActivityId;
  String? _pumpActivityId;
  String? _sleepActivityId;

  static const _appGroupId = 'group.com.mebe.mebetracker';

  Future<void> init() async {
    if (!Platform.isIOS) return;
    await _guard(() => _plugin.init(appGroupId: _appGroupId));
  }

  // ── FEEDING ──────────────────────────────────────────────────────────────

  Future<void> startFeeding({
    required String babyName,
    required String sideLabel,
    required DateTime startTime,
  }) async {
    if (!Platform.isIOS) return;
    await _endFeeding();
    final data = _buildData(
      timerType: 'feeding',
      label: sideLabel,
      startTime: startTime,
      babyName: babyName,
    );
    final id = _uuid.v4();
    _feedingActivityId = await _guard<String?>(() => _plugin.createActivity(id, data)) ?? id;
  }

  Future<void> updateFeeding({
    required String sideLabel,
    required int elapsedSeconds,
    required DateTime startTime,
  }) async {
    if (!Platform.isIOS || _feedingActivityId == null) return;
    final data = _buildData(
      timerType: 'feeding',
      label: sideLabel,
      startTime: startTime,
      elapsedSeconds: elapsedSeconds,
    );
    await _guard(() => _plugin.updateActivity(_feedingActivityId!, data));
  }

  Future<void> stopFeeding() async {
    if (!Platform.isIOS) return;
    await _endFeeding();
  }

  Future<void> _endFeeding() async {
    if (_feedingActivityId == null) return;
    await _guard(() => _plugin.endActivity(_feedingActivityId!));
    _feedingActivityId = null;
  }

  // ── PUMP ─────────────────────────────────────────────────────────────────

  Future<void> startPump({
    required String babyName,
    required DateTime startTime,
  }) async {
    if (!Platform.isIOS) return;
    await _endPump();
    final data = _buildData(
      timerType: 'pump',
      label: 'Đang hút sữa',
      startTime: startTime,
      babyName: babyName,
    );
    final id = _uuid.v4();
    _pumpActivityId = await _guard<String?>(() => _plugin.createActivity(id, data)) ?? id;
  }

  Future<void> updatePump({
    required int elapsedSeconds,
    required DateTime startTime,
  }) async {
    if (!Platform.isIOS || _pumpActivityId == null) return;
    final data = _buildData(
      timerType: 'pump',
      label: 'Đang hút sữa',
      startTime: startTime,
      elapsedSeconds: elapsedSeconds,
    );
    await _guard(() => _plugin.updateActivity(_pumpActivityId!, data));
  }

  Future<void> stopPump() async {
    if (!Platform.isIOS) return;
    await _endPump();
  }

  Future<void> _endPump() async {
    if (_pumpActivityId == null) return;
    await _guard(() => _plugin.endActivity(_pumpActivityId!));
    _pumpActivityId = null;
  }

  // ── SLEEP ────────────────────────────────────────────────────────────────

  Future<void> startSleep({
    required String babyName,
    required DateTime startTime,
    int targetMinutes = 0,
  }) async {
    if (!Platform.isIOS) return;
    await _endSleep();
    final data = _buildData(
      timerType: 'sleep',
      label: 'Đang ngủ',
      startTime: startTime,
      babyName: babyName,
      totalTargetSeconds: targetMinutes * 60,
    );
    final id = _uuid.v4();
    _sleepActivityId = await _guard<String?>(() => _plugin.createActivity(id, data)) ?? id;
  }

  Future<void> updateSleep({
    required int elapsedSeconds,
    required DateTime startTime,
    int targetMinutes = 0,
  }) async {
    if (!Platform.isIOS || _sleepActivityId == null) return;
    final data = _buildData(
      timerType: 'sleep',
      label: 'Đang ngủ',
      startTime: startTime,
      elapsedSeconds: elapsedSeconds,
      totalTargetSeconds: targetMinutes * 60,
    );
    await _guard(() => _plugin.updateActivity(_sleepActivityId!, data));
  }

  Future<void> stopSleep() async {
    if (!Platform.isIOS) return;
    await _endSleep();
  }

  Future<void> _endSleep() async {
    if (_sleepActivityId == null) return;
    await _guard(() => _plugin.endActivity(_sleepActivityId!));
    _sleepActivityId = null;
  }

  // ── HELPERS ──────────────────────────────────────────────────────────────

  Future<T?> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _buildData({
    required String timerType,
    required String label,
    required DateTime startTime,
    String? babyName,
    int elapsedSeconds = 0,
    int totalTargetSeconds = 0,
  }) {
    return {
      'timerType': timerType,
      'elapsedSeconds': elapsedSeconds,
      'label': label,
      'startTime': startTime.millisecondsSinceEpoch,
      'totalTargetSeconds': totalTargetSeconds,
      if (babyName != null) 'babyName': babyName,
    };
  }
}
