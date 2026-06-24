import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service that manages local (on-device) push notifications.
/// Displays notifications in the system tray when the app is in
/// the background OR foreground.
class LocalNotificationService {
  LocalNotificationService._();
  static final LocalNotificationService instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Callback when user taps a notification
  static void Function(String? payload)? onNotificationTap;

  /// Initialize the notification plugin
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Android settings
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      // iOS settings
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );

      await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
      );

      // Create notification channels for Android
      await _createNotificationChannels();

      _isInitialized = true;
      debugPrint('🔔 Local notification service initialized');
    } catch (e) {
      debugPrint('⚠️ Local notification init failed (will retry later): $e');
    }
  }

  /// Request notification permissions (Android 13+ and iOS)
  Future<bool> requestPermission() async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.notification.request();
        debugPrint('🔔 Notification permission: $status');
        return status.isGranted;
      } else if (Platform.isIOS) {
        final result = await _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: true, sound: true);
        return result ?? false;
      }
    } catch (e) {
      debugPrint('⚠️ Permission request failed: $e');
    }
    return true;
  }

  /// Check if notifications are permitted
  Future<bool> isPermissionGranted() async {
    try {
      if (Platform.isAndroid) {
        return await Permission.notification.isGranted;
      }
    } catch (e) {
      debugPrint('⚠️ Permission check failed: $e');
    }
    return true;
  }

  /// Create Android notification channels
  Future<void> _createNotificationChannels() async {
    final androidPlugin =
        _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    if (androidPlugin == null) return;

    // Main notification channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'housepital_notifications',
        'Housepital Notifications',
        description: 'General notifications from Housepital',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );

    // Booking updates channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'housepital_bookings',
        'Booking Updates',
        description: 'Notifications about your bookings',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );

    // Chat messages channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'housepital_chat',
        'Chat Messages',
        description: 'New chat messages',
        importance: Importance.defaultImportance,
        playSound: true,
      ),
    );

    // Urgent/Emergency channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'housepital_urgent',
        'Urgent Alerts',
        description: 'Urgent notifications requiring immediate attention',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      ),
    );
  }

  /// Handle notification tap
  static void _onNotificationResponse(NotificationResponse response) {
    debugPrint('🔔 Notification tapped: ${response.payload}');
    onNotificationTap?.call(response.payload);
  }

  /// Show a notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String channelId = 'housepital_notifications',
    String channelName = 'Housepital Notifications',
    Importance importance = Importance.high,
    Priority priority = Priority.high,
  }) async {
    try {
      if (!_isInitialized) await initialize();
      if (!_isInitialized) return; // Still failed, skip silently

      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        importance: importance,
        priority: priority,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
        styleInformation: BigTextStyleInformation(body),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _plugin.show(id, title, body, details, payload: payload);
      debugPrint('🔔 Local notification shown: $title');
    } catch (e) {
      debugPrint('⚠️ Failed to show notification: $e');
    }
  }

  /// Show a booking notification
  Future<void> showBookingNotification({
    required String title,
    required String body,
    String? bookingId,
  }) async {
    await showNotification(
      id: bookingId.hashCode,
      title: title,
      body: body,
      payload: 'booking:$bookingId',
      channelId: 'housepital_bookings',
      channelName: 'Booking Updates',
    );
  }

  /// Show a chat message notification
  Future<void> showChatNotification({
    required String title,
    required String body,
    String? chatId,
  }) async {
    await showNotification(
      id: chatId.hashCode,
      title: title,
      body: body,
      payload: 'chat:$chatId',
      channelId: 'housepital_chat',
      channelName: 'Chat Messages',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
  }

  /// Show an urgent notification
  Future<void> showUrgentNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: title,
      body: body,
      payload: payload,
      channelId: 'housepital_urgent',
      channelName: 'Urgent Alerts',
      importance: Importance.max,
      priority: Priority.max,
    );
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    try {
      await _plugin.cancel(id);
    } catch (e) {
      debugPrint('⚠️ Failed to cancel notification: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('⚠️ Failed to cancel all notifications: $e');
    }
  }
}
