import 'dart:async';
import 'package:flutter/foundation.dart';
import 'socket_notification_service.dart';

// ═══════════════════════════════════════════════════════════════════════════════
//  VITALS SOCKET SERVICE
//  Manages real-time vitals streaming via Socket.IO for a specific booking.
//  Uses the existing SocketNotificationService connection.
// ═══════════════════════════════════════════════════════════════════════════════

/// Real-time vitals data from Socket.IO
class VitalsUpdate {
  final String deviceId;
  final String bookingId;
  final double? temperature;
  final int? heartRate;
  final int? oxygenSaturation;
  final bool fingerDetected;
  final bool sensorFault;
  final bool sos;
  final String connectionType;
  final String? temperatureStatus;
  final String? heartRateStatus;
  final String? oxygenSaturationStatus;
  final DateTime timestamp;

  VitalsUpdate({
    required this.deviceId,
    required this.bookingId,
    this.temperature,
    this.heartRate,
    this.oxygenSaturation,
    this.fingerDetected = false,
    this.sensorFault = false,
    this.sos = false,
    this.connectionType = 'wifi',
    this.temperatureStatus,
    this.heartRateStatus,
    this.oxygenSaturationStatus,
    required this.timestamp,
  });

  factory VitalsUpdate.fromSocket(Map<String, dynamic> data) {
    final vitals = data['vitals'] as Map<String, dynamic>? ?? {};
    final classification =
        data['classification'] as Map<String, dynamic>? ?? {};

    return VitalsUpdate(
      deviceId: data['deviceId'] ?? '',
      bookingId: data['bookingId'] ?? '',
      temperature: vitals['temperature']?.toDouble(),
      heartRate: vitals['heartRate']?.toInt(),
      oxygenSaturation: vitals['oxygenSaturation']?.toInt(),
      fingerDetected: vitals['fingerDetected'] ?? false,
      sensorFault: vitals['sensorFault'] ?? false,
      sos: data['sos'] ?? false,
      connectionType: data['connectionType'] ?? 'wifi',
      temperatureStatus: classification['temperatureStatus'],
      heartRateStatus: classification['heartRateStatus'],
      oxygenSaturationStatus: classification['oxygenSaturationStatus'],
      timestamp: data['timestamp'] != null
          ? DateTime.parse(data['timestamp'])
          : DateTime.now(),
    );
  }
}

/// Critical alert from Socket.IO
class VitalsCriticalAlert {
  final String deviceId;
  final String bookingId;
  final List<String> alerts;
  final bool sos;
  final DateTime timestamp;

  VitalsCriticalAlert({
    required this.deviceId,
    required this.bookingId,
    required this.alerts,
    this.sos = false,
    required this.timestamp,
  });

  factory VitalsCriticalAlert.fromSocket(Map<String, dynamic> data) {
    return VitalsCriticalAlert(
      deviceId: data['deviceId'] ?? '',
      bookingId: data['bookingId'] ?? '',
      alerts: List<String>.from(data['alerts'] ?? []),
      sos: data['sos'] ?? false,
      timestamp: data['timestamp'] != null
          ? DateTime.parse(data['timestamp'])
          : DateTime.now(),
    );
  }
}

/// SOS event from Socket.IO
class VitalsSosEvent {
  final String deviceId;
  final String bookingId;
  final bool active;
  final DateTime timestamp;

  VitalsSosEvent({
    required this.deviceId,
    required this.bookingId,
    required this.active,
    required this.timestamp,
  });

  factory VitalsSosEvent.fromSocket(Map<String, dynamic> data) {
    return VitalsSosEvent(
      deviceId: data['deviceId'] ?? '',
      bookingId: data['bookingId'] ?? '',
      active: data['active'] ?? true,
      timestamp: data['timestamp'] != null
          ? DateTime.parse(data['timestamp'])
          : DateTime.now(),
    );
  }
}

/// Service that manages Socket.IO room subscriptions for vitals monitoring.
/// Leverages the existing SocketNotificationService connection.
class VitalsSocketService {
  final String bookingId;
  bool _isSubscribed = false;
  bool _isDisposed = false;

  /// Stream controllers for vitals events
  final _vitalsController = StreamController<VitalsUpdate>.broadcast();
  final _criticalController =
      StreamController<VitalsCriticalAlert>.broadcast();
  final _sosController = StreamController<VitalsSosEvent>.broadcast();
  final _deviceAssignedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _deviceReleasedController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Public streams
  Stream<VitalsUpdate> get onVitalsUpdate => _vitalsController.stream;
  Stream<VitalsCriticalAlert> get onCriticalAlert =>
      _criticalController.stream;
  Stream<VitalsSosEvent> get onSosEvent => _sosController.stream;
  Stream<Map<String, dynamic>> get onDeviceAssigned =>
      _deviceAssignedController.stream;
  Stream<Map<String, dynamic>> get onDeviceReleased =>
      _deviceReleasedController.stream;

  /// Whether we have an active Socket.IO subscription
  bool get isSubscribed => _isSubscribed;

  /// Whether the underlying socket is connected
  bool get isSocketConnected =>
      SocketNotificationService.instance.isConnected;

  VitalsSocketService({required this.bookingId});

  /// Subscribe to the booking's vitals room via Socket.IO.
  /// Call this when the screen opens.
  void subscribe() {
    if (_isDisposed) return;

    final socket = SocketNotificationService.instance.socket;
    if (socket == null || !SocketNotificationService.instance.isConnected) {
      debugPrint(
          '📊 VitalsSocket: Socket not connected, will retry when connected');
      _scheduleRetrySubscription();
      return;
    }

    // Join the booking room
    socket.emit('vitals:subscribe', bookingId);
    _isSubscribed = true;
    debugPrint('📊 VitalsSocket: Subscribed to booking $bookingId');

    // Listen for vitals:update events
    socket.on('vitals:update', _handleVitalsUpdate);

    // Listen for vitals:critical events
    socket.on('vitals:critical', _handleCriticalAlert);

    // Listen for vitals:sos events
    socket.on('vitals:sos', _handleSosEvent);

    // Listen for device assignment/release events
    socket.on('device:assigned', _handleDeviceAssigned);
    socket.on('device:released', _handleDeviceReleased);
  }

  /// Unsubscribe from the booking's vitals room.
  /// Call this when the screen closes.
  void unsubscribe() {
    final socket = SocketNotificationService.instance.socket;
    if (socket != null && _isSubscribed) {
      socket.emit('vitals:unsubscribe', bookingId);

      // Remove listeners
      socket.off('vitals:update', _handleVitalsUpdate);
      socket.off('vitals:critical', _handleCriticalAlert);
      socket.off('vitals:sos', _handleSosEvent);
      socket.off('device:assigned', _handleDeviceAssigned);
      socket.off('device:released', _handleDeviceReleased);

      _isSubscribed = false;
      debugPrint('📊 VitalsSocket: Unsubscribed from booking $bookingId');
    }
  }

  void _handleVitalsUpdate(dynamic data) {
    if (_isDisposed) return;
    try {
      final map = _toMap(data);
      if (map != null) {
        final update = VitalsUpdate.fromSocket(map);
        // Only process updates for our booking
        if (update.bookingId == bookingId ||
            update.bookingId.isEmpty) {
          _vitalsController.add(update);
        }
      }
    } catch (e) {
      debugPrint('📊 VitalsSocket: Error parsing vitals update: $e');
    }
  }

  void _handleCriticalAlert(dynamic data) {
    if (_isDisposed) return;
    try {
      final map = _toMap(data);
      if (map != null) {
        _criticalController.add(VitalsCriticalAlert.fromSocket(map));
      }
    } catch (e) {
      debugPrint('📊 VitalsSocket: Error parsing critical alert: $e');
    }
  }

  void _handleSosEvent(dynamic data) {
    if (_isDisposed) return;
    try {
      final map = _toMap(data);
      if (map != null) {
        _sosController.add(VitalsSosEvent.fromSocket(map));
      }
    } catch (e) {
      debugPrint('📊 VitalsSocket: Error parsing SOS event: $e');
    }
  }

  void _handleDeviceAssigned(dynamic data) {
    if (_isDisposed) return;
    try {
      final map = _toMap(data);
      if (map != null) {
        _deviceAssignedController.add(map);
      }
    } catch (e) {
      debugPrint('📊 VitalsSocket: Error parsing device assigned: $e');
    }
  }

  void _handleDeviceReleased(dynamic data) {
    if (_isDisposed) return;
    try {
      final map = _toMap(data);
      if (map != null) {
        _deviceReleasedController.add(map);
      }
    } catch (e) {
      debugPrint('📊 VitalsSocket: Error parsing device released: $e');
    }
  }

  Map<String, dynamic>? _toMap(dynamic data) {
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  void _scheduleRetrySubscription() {
    if (_isDisposed) return;
    Future.delayed(const Duration(seconds: 3), () {
      if (!_isDisposed && !_isSubscribed) {
        subscribe();
      }
    });
  }

  /// Dispose all resources. Must be called when done.
  void dispose() {
    _isDisposed = true;
    unsubscribe();
    _vitalsController.close();
    _criticalController.close();
    _sosController.close();
    _deviceAssignedController.close();
    _deviceReleasedController.close();
    debugPrint('📊 VitalsSocket: Disposed for booking $bookingId');
  }
}
