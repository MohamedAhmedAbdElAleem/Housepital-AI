import 'package:flutter/foundation.dart';
import '../network/api_service.dart';
import '../models/notification_model.dart';

/// REST API service for notification CRUD operations
class NotificationApiService {
  final ApiService _apiService;

  NotificationApiService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  /// Get all notifications (paginated)
  Future<NotificationListResponse> getNotifications({
    int page = 1,
    int limit = 30,
  }) async {
    try {
      final response = await _apiService.get(
        '/api/notifications?page=$page&limit=$limit',
      );
      return NotificationListResponse.fromJson(response);
    } catch (e) {
      debugPrint('❌ Error fetching notifications: $e');
      rethrow;
    }
  }

  /// Get unread count
  Future<int> getUnreadCount() async {
    try {
      final response = await _apiService.get('/api/notifications/unread-count');
      return response['unreadCount'] ?? 0;
    } catch (e) {
      debugPrint('❌ Error fetching unread count: $e');
      return 0;
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiService.put('/api/notifications/$notificationId/read');
    } catch (e) {
      debugPrint('❌ Error marking notification as read: $e');
      rethrow;
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _apiService.put('/api/notifications/read-all');
    } catch (e) {
      debugPrint('❌ Error marking all as read: $e');
      rethrow;
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _apiService.delete('/api/notifications/$notificationId');
    } catch (e) {
      debugPrint('❌ Error deleting notification: $e');
      rethrow;
    }
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      await _apiService.delete('/api/notifications/clear-all');
    } catch (e) {
      debugPrint('❌ Error clearing notifications: $e');
      rethrow;
    }
  }
}

/// Response model for notification list
class NotificationListResponse {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final int page;
  final int pages;
  final int total;

  NotificationListResponse({
    required this.notifications,
    required this.unreadCount,
    this.page = 1,
    this.pages = 1,
    this.total = 0,
  });

  factory NotificationListResponse.fromJson(Map<String, dynamic> json) {
    final list =
        (json['notifications'] as List?)
            ?.map((n) => NotificationModel.fromJson(n))
            .toList() ??
        [];

    final pagination = json['pagination'] as Map<String, dynamic>?;

    return NotificationListResponse(
      notifications: list,
      unreadCount: json['unreadCount'] ?? 0,
      page: pagination?['page'] ?? 1,
      pages: pagination?['pages'] ?? 1,
      total: pagination?['total'] ?? list.length,
    );
  }
}
