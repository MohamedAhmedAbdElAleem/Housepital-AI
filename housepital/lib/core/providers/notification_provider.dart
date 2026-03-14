import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/notification_api_service.dart';
import '../services/socket_notification_service.dart';
import '../services/local_notification_service.dart';
import '../utils/token_manager.dart';

/// Provider that manages notification state for the entire app.
/// Combines REST API (for history) and Socket.IO (for real-time).
class NotificationProvider extends ChangeNotifier {
  final NotificationApiService _apiService;
  final SocketNotificationService _socketService;

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  StreamSubscription<NotificationModel>? _socketSubscription;

  // Settings
  bool _pushNotificationsEnabled = true;
  bool _inAppNotificationsEnabled = true;

  NotificationProvider({
    NotificationApiService? apiService,
    SocketNotificationService? socketService,
  }) : _apiService = apiService ?? NotificationApiService(),
       _socketService = socketService ?? SocketNotificationService.instance;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  bool get pushNotificationsEnabled => _pushNotificationsEnabled;
  bool get inAppNotificationsEnabled => _inAppNotificationsEnabled;

  /// Initialize the notification system
  Future<void> initialize() async {
    try {
      final hasToken = await TokenManager.hasToken();
      if (!hasToken) return;

      // Initialize local notifications (safe, won't crash)
      await LocalNotificationService.instance.initialize();
      await LocalNotificationService.instance.requestPermission();

      // Set up notification tap handler
      LocalNotificationService.onNotificationTap = _handleNotificationTap;

      // Connect to socket for real-time
      await _socketService.connect();

      // Listen for real-time notifications
      _socketSubscription?.cancel();
      _socketSubscription = _socketService.onNotification.listen((
        notification,
      ) {
        _onNewNotification(notification);
      });
    } catch (e) {
      debugPrint('⚠️ Notification system init error: $e');
    }

    // Load initial notifications from API
    await loadNotifications(refresh: true);
  }

  /// Load notifications from the REST API
  Future<void> loadNotifications({bool refresh = false}) async {
    if (_isLoading) return;
    if (!refresh && !_hasMore) return;

    _isLoading = true;
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
    }
    notifyListeners();

    try {
      final response = await _apiService.getNotifications(
        page: _currentPage,
        limit: 30,
      );

      if (refresh) {
        _notifications = response.notifications;
      } else {
        _notifications.addAll(response.notifications);
      }

      _unreadCount = response.unreadCount;
      _hasMore = _currentPage < response.pages;
      _currentPage++;
    } catch (e) {
      debugPrint('❌ Error loading notifications: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Handle a new real-time notification
  void _onNewNotification(NotificationModel notification) {
    // Add to the top of the list
    _notifications.insert(0, notification);
    _unreadCount++;
    notifyListeners();

    debugPrint('🔔 New notification in provider: ${notification.title}');
  }

  /// Handle notification tap (from local notification)
  void _handleNotificationTap(String? payload) {
    if (payload == null) return;
    debugPrint('🔔 Notification tapped with payload: $payload');
    // Navigation will be handled by the UI layer
  }

  /// Mark a single notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiService.markAsRead(notificationId);
      _socketService.markAsRead(notificationId);

      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1 && !_notifications[index].isRead) {
        _notifications[index] = _notifications[index].copyWith(
          isRead: true,
          readAt: DateTime.now(),
        );
        _unreadCount = (_unreadCount - 1).clamp(0, _unreadCount);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error marking as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _apiService.markAllAsRead();
      _socketService.markAllAsRead();

      _notifications =
          _notifications
              .map((n) => n.copyWith(isRead: true, readAt: DateTime.now()))
              .toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error marking all as read: $e');
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _apiService.deleteNotification(notificationId);
      final wasUnread = _notifications.any(
        (n) => n.id == notificationId && !n.isRead,
      );
      _notifications.removeWhere((n) => n.id == notificationId);
      if (wasUnread) {
        _unreadCount = (_unreadCount - 1).clamp(0, _unreadCount);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error deleting notification: $e');
    }
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      await _apiService.clearAllNotifications();
      _notifications.clear();
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error clearing notifications: $e');
    }
  }

  /// Toggle push notifications
  void togglePushNotifications(bool enabled) {
    _pushNotificationsEnabled = enabled;
    notifyListeners();
  }

  /// Toggle in-app notifications
  void toggleInAppNotifications(bool enabled) {
    _inAppNotificationsEnabled = enabled;
    notifyListeners();
  }

  /// Refresh unread count from server
  Future<void> refreshUnreadCount() async {
    try {
      _unreadCount = await _apiService.getUnreadCount();
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error refreshing unread count: $e');
    }
  }

  /// Disconnect from socket and clean up
  void disconnectSocket() {
    _socketSubscription?.cancel();
    _socketService.disconnect();
  }

  @override
  void dispose() {
    _socketSubscription?.cancel();
    super.dispose();
  }
}
