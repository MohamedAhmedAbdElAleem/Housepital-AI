import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import '../network/api_constants.dart';
import '../utils/token_manager.dart';
import '../models/notification_model.dart';
import 'local_notification_service.dart';

/// Service that manages Socket.IO connection for real-time notifications.
/// Listens for 'notification' events from the server and:
/// 1. Triggers local push notifications on the device
/// 2. Notifies in-app listeners (NotificationProvider) for UI updates
class SocketNotificationService {
  SocketNotificationService._();
  static final SocketNotificationService instance =
      SocketNotificationService._();

  socket_io.Socket? _socket;
  bool _isConnected = false;
  Timer? _reconnectTimer;

  /// Stream controller to broadcast incoming notifications to the app
  final StreamController<NotificationModel> _notificationController =
      StreamController<NotificationModel>.broadcast();

  /// Stream that widgets/providers can listen to
  Stream<NotificationModel> get onNotification =>
      _notificationController.stream;

  /// Whether currently connected
  bool get isConnected => _isConnected;

  /// Connect to the Socket.IO server with authentication
  Future<void> connect() async {
    final token = await TokenManager.getToken();
    if (token == null) {
      debugPrint('⚠️ No token, skipping socket connection');
      return;
    }

    // Disconnect existing connection if any
    disconnect();

    final baseUrl = ApiConstants.baseUrl;
    debugPrint('🔌 Connecting to Socket.IO at $baseUrl');

    _socket = socket_io.io(
      baseUrl,
      socket_io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .setAuth({'token': token})
          .setQuery({'token': token})
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(2000)
          .build(),
    );

    _socket!.onConnect((_) {
      _isConnected = true;
      _reconnectTimer?.cancel();
      debugPrint('🔌 Socket.IO connected successfully');
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      debugPrint('🔌 Socket.IO disconnected');
      _scheduleReconnect();
    });

    _socket!.onConnectError((error) {
      _isConnected = false;
      debugPrint('🔌 Socket.IO connection error: $error');
      _scheduleReconnect();
    });

    // Listen for real-time notifications
    _socket!.on('notification', (data) {
      debugPrint('🔔 Received notification via socket: $data');
      _handleNotification(data);
    });

    // Handle notification read acknowledgment
    _socket!.on('notification_read', (data) {
      debugPrint('✅ Notification marked as read: ${data['notificationId']}');
    });

    _socket!.on('all_notifications_read', (_) {
      debugPrint('✅ All notifications marked as read');
    });

    // Connection health check
    _socket!.on('pong_server', (data) {
      debugPrint('🏓 Server pong: $data');
    });

    _socket!.connect();
  }

  /// Handle incoming notification data
  void _handleNotification(dynamic data) {
    try {
      final Map<String, dynamic> notifData;
      if (data is String) {
        notifData = jsonDecode(data) as Map<String, dynamic>;
      } else if (data is Map) {
        notifData = Map<String, dynamic>.from(data);
      } else {
        debugPrint('⚠️ Unknown notification format: ${data.runtimeType}');
        return;
      }

      final notification = NotificationModel.fromJson(notifData);

      // 1. Broadcast to in-app listeners (for UI updates)
      _notificationController.add(notification);

      // 2. Show local push notification on the device
      _showLocalNotification(notification);
    } catch (e) {
      debugPrint('❌ Error handling notification: $e');
    }
  }

  /// Show local push notification based on notification type
  void _showLocalNotification(NotificationModel notification) {
    try {
      final localService = LocalNotificationService.instance;
      _showLocalNotificationByType(localService, notification);
    } catch (e) {
      debugPrint('⚠️ Failed to show local notification: $e');
    }
  }

  void _showLocalNotificationByType(
    LocalNotificationService localService,
    NotificationModel notification,
  ) {
    switch (notification.type) {
      case 'booking_created':
      case 'booking_confirmed':
      case 'booking_assigned':
      case 'booking_in_progress':
      case 'booking_completed':
      case 'booking_cancelled':
      case 'nurse_arriving':
        localService.showBookingNotification(
          title: notification.title,
          body: notification.body,
          bookingId: notification.referenceId,
        );
        break;
      case 'chat_message':
        localService.showChatNotification(
          title: notification.title,
          body: notification.body,
          chatId: notification.referenceId,
        );
        break;
      case 'payment_received':
      case 'payment_reminder':
      case 'triage_result':
      case 'profile_verified':
      case 'profile_rejected':
      case 'appointment_reminder':
        if (notification.priority == 'urgent' ||
            notification.priority == 'high') {
          localService.showUrgentNotification(
            title: notification.title,
            body: notification.body,
            payload:
                '${notification.referenceType}:${notification.referenceId}',
          );
        } else {
          localService.showNotification(
            id: notification.id.hashCode,
            title: notification.title,
            body: notification.body,
            payload:
                '${notification.referenceType}:${notification.referenceId}',
          );
        }
        break;
      default:
        localService.showNotification(
          id: notification.id.hashCode,
          title: notification.title,
          body: notification.body,
          payload: 'system:${notification.id}',
        );
    }
  }

  /// Mark a notification as read via socket
  void markAsRead(String notificationId) {
    _socket?.emit('mark_read', {'notificationId': notificationId});
  }

  /// Mark all notifications as read via socket
  void markAllAsRead() {
    _socket?.emit('mark_all_read');
  }

  /// Ping server for connection health check
  void pingServer() {
    _socket?.emit('ping_server');
  }

  /// Schedule reconnection
  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () async {
      final hasToken = await TokenManager.hasToken();
      if (hasToken && !_isConnected) {
        debugPrint('🔌 Attempting to reconnect...');
        connect();
      }
    });
  }

  /// Disconnect from Socket.IO
  void disconnect() {
    _reconnectTimer?.cancel();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
    debugPrint('🔌 Socket.IO disconnected and disposed');
  }

  /// Dispose the service
  void dispose() {
    disconnect();
    _notificationController.close();
  }
}
