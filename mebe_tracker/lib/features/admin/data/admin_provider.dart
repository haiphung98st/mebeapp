import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Models ────────────────────────────────────────────────────────────────────

class AppConfig {
  const AppConfig({
    this.maintenanceMode = false,
    this.maintenanceModeMessage = 'Hệ thống đang bảo trì, vui lòng thử lại sau',
    this.forceUpdateVersion = '',
    this.announcementBanner = '',
    this.aiEnabled = true,
    this.aiMonthlyBudgetUsd = 50.0,
  });

  final bool maintenanceMode;
  final String maintenanceModeMessage;
  final String forceUpdateVersion;
  final String announcementBanner;
  final bool aiEnabled;
  final double aiMonthlyBudgetUsd;

  static const defaults = AppConfig();

  factory AppConfig.fromMap(Map<String, dynamic> map) {
    return AppConfig(
      maintenanceMode: (map['maintenanceMode'] as bool?) ?? false,
      maintenanceModeMessage: (map['maintenanceModeMessage'] as String?) ??
          'Hệ thống đang bảo trì, vui lòng thử lại sau',
      forceUpdateVersion: (map['forceUpdateVersion'] as String?) ?? '',
      announcementBanner: (map['announcementBanner'] as String?) ?? '',
      aiEnabled: (map['aiEnabled'] as bool?) ?? true,
      aiMonthlyBudgetUsd: ((map['aiMonthlyBudgetUsd'] as num?) ?? 50.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
        'maintenanceMode': maintenanceMode,
        'maintenanceModeMessage': maintenanceModeMessage,
        'forceUpdateVersion': forceUpdateVersion,
        'announcementBanner': announcementBanner,
        'aiEnabled': aiEnabled,
        'aiMonthlyBudgetUsd': aiMonthlyBudgetUsd,
      };
}

class AuditLog {
  const AuditLog({
    required this.id,
    required this.action,
    required this.adminUid,
    required this.adminEmail,
    this.targetUid,
    this.targetEmail,
    required this.details,
    required this.timestamp,
  });

  final String id;
  final String action;
  final String adminUid;
  final String adminEmail;
  final String? targetUid;
  final String? targetEmail;
  final Map<String, dynamic> details;
  final DateTime timestamp;

  factory AuditLog.fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return AuditLog(
      id: doc.id,
      action: (d['action'] as String?) ?? '',
      adminUid: (d['adminUid'] as String?) ?? '',
      adminEmail: (d['adminEmail'] as String?) ?? '',
      targetUid: d['targetUid'] as String?,
      targetEmail: d['targetEmail'] as String?,
      details: (d['details'] as Map<String, dynamic>?) ?? {},
      timestamp: (d['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

// ── Admin Notifier ────────────────────────────────────────────────────────────

class AdminNotifier extends StateNotifier<Null> {
  AdminNotifier() : super(null);

  final _functions = FirebaseFunctions.instanceFor(region: 'asia-southeast1');

  Future<void> grantPremium({
    required String uid,
    required int durationDays,
    required String reason,
    String? note,
  }) async {
    await _functions.httpsCallable('adminGrantPremium').call({
      'uid': uid,
      'durationDays': durationDays,
      'reason': reason,
      if (note != null && note.isNotEmpty) 'note': note,
    });
  }

  Future<void> revokePremium({required String uid, String? note}) async {
    await _functions.httpsCallable('adminRevokePremium').call({
      'uid': uid,
      if (note != null && note.isNotEmpty) 'note': note,
    });
  }

  Future<Map<String, dynamic>> getUser({String? uid, String? email}) async {
    final result = await _functions.httpsCallable('adminGetUser').call({
      if (uid != null) 'uid': uid,
      if (email != null) 'email': email,
    });
    return Map<String, dynamic>.from(result.data as Map);
  }

  Future<Map<String, dynamic>> getStats() async {
    final result = await _functions.httpsCallable('adminGetStats').call({});
    return Map<String, dynamic>.from(result.data as Map);
  }

  Future<void> setRole({required String uid, required String role}) async {
    await _functions.httpsCallable('adminSetRole').call({'uid': uid, 'role': role});
  }

  Future<void> updateConfig(Map<String, dynamic> config) async {
    await _functions.httpsCallable('adminUpdateConfig').call(config);
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final adminNotifierProvider = StateNotifierProvider<AdminNotifier, Null>(
  (_) => AdminNotifier(),
);

final adminAuditLogsProvider = StreamProvider.autoDispose<List<AuditLog>>((ref) {
  return FirebaseFirestore.instance
      .collection('adminLogs')
      .orderBy('timestamp', descending: true)
      .limit(100)
      .snapshots()
      .map((snap) => snap.docs.map(AuditLog.fromFirestore).toList());
});

final appConfigProvider = StreamProvider<AppConfig>((ref) {
  return FirebaseFirestore.instance.doc('appConfig/global').snapshots().map((snap) {
    if (!snap.exists || snap.data() == null) return AppConfig.defaults;
    return AppConfig.fromMap(snap.data()!);
  });
});
