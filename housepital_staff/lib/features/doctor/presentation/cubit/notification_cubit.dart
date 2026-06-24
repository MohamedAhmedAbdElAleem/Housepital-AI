import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_client.dart';

class DoctorNotification {
  final String id;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final DateTime? createdAt;

  const DoctorNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory DoctorNotification.fromJson(Map<String, dynamic> json) {
    final createdAtRaw =
        json['createdAt'] ?? json['created_at'] ?? json['time'];
    DateTime? createdAt;

    if (createdAtRaw is String && createdAtRaw.isNotEmpty) {
      createdAt = DateTime.tryParse(createdAtRaw);
    }

    return DoctorNotification(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? json['type'] ?? 'Notification').toString(),
      body: (json['body'] ?? json['message'] ?? '').toString(),
      type: (json['type'] ?? 'general').toString(),
      isRead: (json['isRead'] ?? json['is_read'] ?? false) == true,
      createdAt: createdAt,
    );
  }

  DoctorNotification copyWith({bool? isRead}) {
    return DoctorNotification(
      id: id,
      title: title,
      body: body,
      type: type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<DoctorNotification> notifications;

  NotificationLoaded(this.notifications);

  int get unreadCount => notifications.where((item) => !item.isRead).length;
}

class NotificationError extends NotificationState {
  final String message;

  NotificationError(this.message);
}

class NotificationCubit extends Cubit<NotificationState> {
  final ApiClient _api;

  NotificationCubit({ApiClient? apiClient})
      : _api = apiClient ?? ApiClient(),
        super(NotificationInitial());

  Future<void> fetchNotifications() async {
    emit(NotificationLoading());

    try {
      final response = await _api.get('/notifications');
      final notifications = _extractNotifications(response);
      emit(NotificationLoaded(notifications));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final current = state;
    if (current is! NotificationLoaded) {
      return;
    }

    final updated = current.notifications.map((item) {
      if (item.id == notificationId) {
        return item.copyWith(isRead: true);
      }
      return item;
    }).toList();

    emit(NotificationLoaded(updated));

    if (notificationId.isEmpty) {
      return;
    }

    try {
      await _api.patch('/notifications/$notificationId/read');
    } catch (_) {
      // Keep optimistic update to avoid flicker.
    }
  }

  List<DoctorNotification> _extractNotifications(dynamic response) {
    dynamic data = response;

    if (data is Map<String, dynamic>) {
      data = data['notifications'] ?? data['data'] ?? data['items'] ?? const [];
    }

    if (data is! List) {
      return const [];
    }

    return data
        .whereType<Map>()
        .map((item) =>
            DoctorNotification.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}
