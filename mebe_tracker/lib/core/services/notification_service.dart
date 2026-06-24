import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Thin wrapper around flutter_local_notifications for one-off local alerts
/// (e.g. milk stash expiring soon). Initialized once from main().
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
    _initialized = true;
  }

  Future<void> showExpiringMilkNotification(double amountMl) async {
    if (!_initialized) await init();
    await _plugin.show(
      1001,
      '🐰 Sữa sắp hết hạn',
      'Còn ${amountMl.toStringAsFixed(0)}ml sữa sẽ hết hạn trong 24h tới',
      const NotificationDetails(
        android: AndroidNotificationDetails('milk_stash', 'Kho sữa'),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> showLowDiaperCountNotification() async {
    if (!_initialized) await init();
    await _plugin.show(
      1002,
      '🐰 Bé có vẻ ít thay tã hôm nay',
      'Hôm nay bé chưa thay tã đủ 3 lần. Kiểm tra bé nhé!',
      const NotificationDetails(
        android: AndroidNotificationDetails('diaper_alert', 'Thay tã'),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
