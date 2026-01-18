import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  factory NotificationService() => instance;

  NotificationService._internal();

  Future<void> init() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - can navigate to specific screen
  }

  /// Show notification for low stock warning
  Future<void> showLowStockNotification({
    required String barangNama,
    required int stok,
    required int stokMinimum,
  }) async {
    if (!_isInitialized) await init();

    const androidDetails = AndroidNotificationDetails(
      'low_stock_channel',
      'Stok Menipis',
      channelDescription: 'Notifikasi ketika stok barang menipis',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Friendly message for parents
    String message = stok <= 0
        ? '$barangNama habis! Yuk segera restok biar tidak kehabisan.'
        : 'Stok $barangNama tinggal $stok lagi (batas: $stokMinimum). Waktunya belanja!';

    await _notifications.show(
      barangNama.hashCode, // Unique ID per item
      'Stok Menipis',
      message,
      details,
      payload: barangNama,
    );
  }

  /// Show notification for multiple low stock items
  Future<void> showMultipleLowStockNotification({
    required int jumlahBarang,
  }) async {
    if (!_isInitialized) await init();

    const androidDetails = AndroidNotificationDetails(
      'low_stock_channel',
      'Stok Menipis',
      channelDescription: 'Notifikasi ketika stok barang menipis',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      'Waktunya Cek Stok!',
      'Ada $jumlahBarang barang yang stoknya menipis. Yuk cek sekarang!',
      details,
      payload: 'low_stock_list',
    );
  }

  /// Show success notification (friendly feedback)
  Future<void> showSuccessNotification({
    required String title,
    required String message,
  }) async {
    if (!_isInitialized) await init();

    const androidDetails = AndroidNotificationDetails(
      'success_channel',
      'Sukses',
      channelDescription: 'Notifikasi sukses',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      message,
      details,
    );
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Request notification permissions (for iOS and Android 13+)
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final granted = await androidPlugin?.requestNotificationsPermission();
      return granted ?? false;
    } else if (Platform.isIOS) {
      final iosPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final granted = await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    return true;
  }
}

// Helper class for Color in notification (non-widget context)
class Color {
  final int value;
  const Color(this.value);

  static Color fromARGB(int a, int r, int g, int b) {
    return Color(
      (a & 0xff) << 24 | (r & 0xff) << 16 | (g & 0xff) << 8 | (b & 0xff),
    );
  }
}
