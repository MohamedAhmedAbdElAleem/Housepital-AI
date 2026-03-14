/// Notification model matching the backend Notification schema
class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String? titleAr;
  final String? bodyAr;
  final String type;
  final String? referenceId;
  final String? referenceType;
  final bool isRead;
  final DateTime? readAt;
  final String? imageUrl;
  final String priority;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.titleAr,
    this.bodyAr,
    required this.type,
    this.referenceId,
    this.referenceType,
    this.isRead = false,
    this.readAt,
    this.imageUrl,
    this.priority = 'normal',
    this.metadata = const {},
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      titleAr: json['titleAr'],
      bodyAr: json['bodyAr'],
      type: json['type'] ?? 'system',
      referenceId: json['referenceId'],
      referenceType: json['referenceType'],
      isRead: json['isRead'] ?? false,
      readAt: json['readAt'] != null ? DateTime.tryParse(json['readAt']) : null,
      imageUrl: json['imageUrl'],
      priority: json['priority'] ?? 'normal',
      metadata:
          json['metadata'] is Map<String, dynamic> ? json['metadata'] : {},
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'].toString()) ??
                  DateTime.now()
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'titleAr': titleAr,
      'bodyAr': bodyAr,
      'type': type,
      'referenceId': referenceId,
      'referenceType': referenceType,
      'isRead': isRead,
      'readAt': readAt?.toIso8601String(),
      'imageUrl': imageUrl,
      'priority': priority,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  NotificationModel copyWith({bool? isRead, DateTime? readAt}) {
    return NotificationModel(
      id: id,
      userId: userId,
      title: title,
      body: body,
      titleAr: titleAr,
      bodyAr: bodyAr,
      type: type,
      referenceId: referenceId,
      referenceType: referenceType,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      imageUrl: imageUrl,
      priority: priority,
      metadata: metadata,
      createdAt: createdAt,
    );
  }

  /// Get a user-friendly icon based on notification type
  String get iconName {
    switch (type) {
      case 'booking_created':
        return 'calendar_today';
      case 'booking_confirmed':
        return 'check_circle';
      case 'booking_assigned':
        return 'person_pin';
      case 'booking_in_progress':
        return 'medical_services';
      case 'booking_completed':
        return 'task_alt';
      case 'booking_cancelled':
        return 'cancel';
      case 'nurse_arriving':
        return 'directions_car';
      case 'payment_received':
        return 'payment';
      case 'payment_reminder':
        return 'account_balance_wallet';
      case 'chat_message':
        return 'chat_bubble';
      case 'triage_result':
        return 'health_and_safety';
      case 'profile_verified':
        return 'verified_user';
      case 'profile_rejected':
        return 'gpp_bad';
      case 'appointment_reminder':
        return 'alarm';
      case 'promotion':
        return 'local_offer';
      default:
        return 'notifications';
    }
  }

  /// Time ago string
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }
}
