import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/notification_provider.dart';
import '../../../../core/models/notification_model.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();

  // Design system
  static const _primary = Color(0xFF00C853);
  static const _primaryDark = Color(0xFF009624);
  static const _surface = Color(0xFFF8FAFC);
  static const _card = Colors.white;
  static const _textPrimary = Color(0xFF0F172A);
  static const _textSecondary = Color(0xFF475569);
  static const _textMuted = Color(0xFF94A3B8);
  static const _unreadBg = Color(0xFFF0FFF4);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();

    _scrollController.addListener(_onScroll);

    // Load notifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications(refresh: true);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<NotificationProvider>().loadNotifications();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildAppBar(),
            Consumer<NotificationProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.notifications.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: _primary),
                    ),
                  );
                }

                if (provider.notifications.isEmpty) {
                  return SliverFillRemaining(child: _buildEmptyState());
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      if (index == provider.notifications.length) {
                        return provider.hasMore
                            ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: _primary,
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                            : const SizedBox.shrink();
                      }
                      return _buildNotificationTile(
                        provider.notifications[index],
                        index,
                      );
                    }, childCount: provider.notifications.length + 1),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: _primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        Consumer<NotificationProvider>(
          builder: (context, provider, _) {
            return PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
              onSelected: (value) {
                switch (value) {
                  case 'read_all':
                    provider.markAllAsRead();
                    break;
                  case 'clear_all':
                    _showClearAllDialog(provider);
                    break;
                }
              },
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'read_all',
                      child: Row(
                        children: [
                          Icon(
                            Icons.done_all_rounded,
                            size: 20,
                            color: _primary,
                          ),
                          SizedBox(width: 12),
                          Text('Mark all as read'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'clear_all',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_sweep_rounded,
                            size: 20,
                            color: Colors.red,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Clear all',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
        title: Consumer<NotificationProvider>(
          builder: (context, provider, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                if (provider.unreadCount > 0)
                  Text(
                    '${provider.unreadCount} unread',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
              ],
            );
          },
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_primary, _primaryDark],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_rounded,
              size: 64,
              color: _primary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll notify you when something\nimportant happens',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: _textSecondary.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(NotificationModel notification, int index) {
    final isUnread = !notification.isRead;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
      ),
      onDismissed: (_) {
        context.read<NotificationProvider>().deleteNotification(
          notification.id,
        );
      },
      child: GestureDetector(
        onTap: () {
          if (isUnread) {
            context.read<NotificationProvider>().markAsRead(notification.id);
          }
          _onNotificationTap(notification);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isUnread ? _unreadBg : _card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  isUnread
                      ? _primary.withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getTypeColor(
                    notification.type,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _getTypeIcon(notification.type),
                  color: _getTypeColor(notification.type),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  isUnread ? FontWeight.w700 : FontWeight.w600,
                              color: _textPrimary,
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: _primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: const TextStyle(
                        fontSize: 13,
                        color: _textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification.timeAgo,
                      style: const TextStyle(fontSize: 11, color: _textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'booking_created':
        return Icons.calendar_today_rounded;
      case 'booking_confirmed':
        return Icons.check_circle_rounded;
      case 'booking_assigned':
        return Icons.person_pin_rounded;
      case 'booking_in_progress':
        return Icons.medical_services_rounded;
      case 'booking_completed':
        return Icons.task_alt_rounded;
      case 'booking_cancelled':
        return Icons.cancel_rounded;
      case 'nurse_arriving':
        return Icons.directions_car_rounded;
      case 'payment_received':
        return Icons.payment_rounded;
      case 'payment_reminder':
        return Icons.account_balance_wallet_rounded;
      case 'chat_message':
        return Icons.chat_bubble_rounded;
      case 'triage_result':
        return Icons.health_and_safety_rounded;
      case 'profile_verified':
        return Icons.verified_user_rounded;
      case 'profile_rejected':
        return Icons.gpp_bad_rounded;
      case 'appointment_reminder':
        return Icons.alarm_rounded;
      case 'promotion':
        return Icons.local_offer_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'booking_created':
        return const Color(0xFF1E88E5);
      case 'booking_confirmed':
        return _primary;
      case 'booking_assigned':
        return const Color(0xFF7B1FA2);
      case 'booking_in_progress':
        return const Color(0xFFFF9800);
      case 'booking_completed':
        return _primary;
      case 'booking_cancelled':
        return const Color(0xFFE53935);
      case 'nurse_arriving':
        return const Color(0xFF00BCD4);
      case 'payment_received':
        return _primary;
      case 'payment_reminder':
        return const Color(0xFFF59E0B);
      case 'chat_message':
        return const Color(0xFF1E88E5);
      case 'triage_result':
        return const Color(0xFF00BCD4);
      case 'profile_verified':
        return _primary;
      case 'profile_rejected':
        return const Color(0xFFE53935);
      case 'appointment_reminder':
        return const Color(0xFFFF9800);
      case 'promotion':
        return const Color(0xFF9C27B0);
      default:
        return const Color(0xFF607D8B);
    }
  }

  void _onNotificationTap(NotificationModel notification) {
    // Navigate based on notification type
    switch (notification.referenceType) {
      case 'booking':
        // Navigate to booking details if needed
        debugPrint('Navigate to booking: ${notification.referenceId}');
        break;
      case 'chat':
        debugPrint('Navigate to chat: ${notification.referenceId}');
        break;
      default:
        debugPrint('Notification tapped: ${notification.type}');
    }
  }

  void _showClearAllDialog(NotificationProvider provider) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Clear all notifications?'),
            content: const Text(
              'This will permanently delete all your notifications.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: _textSecondary),
                ),
              ),
              TextButton(
                onPressed: () {
                  provider.clearAllNotifications();
                  Navigator.pop(ctx);
                },
                child: const Text(
                  'Clear All',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
