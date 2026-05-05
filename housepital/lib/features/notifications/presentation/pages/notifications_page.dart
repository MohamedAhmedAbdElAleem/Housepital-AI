import 'dart:ui';
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

  // Design system (Glass & Grid Engine - Green)
  static const _primary = Color(0xFF2ECC71);
  static const _primaryDark = Color(0xFF27AE60);
  static const _surface = Color(0xFFF0F4F8);
  static const _card = Colors.white;
  static const _textPrimary = Color(0xFF1A202C);
  static const _textSecondary = Color(0xFF718096);
  static const _textMuted = Color(0xFFA0AEC0);
  static const _unreadBg = Color(0xFFE8F8F5);

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
    final canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: _surface,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildAppBar(canPop),
            Expanded(
              child: Consumer<NotificationProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading && provider.notifications.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: _primary),
                    );
                  }

                  if (provider.notifications.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    itemCount: provider.notifications.length + 1,
                    itemBuilder: (context, index) {
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
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(bool canPop) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 24,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primary, _primaryDark],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryDark.withAlpha(60),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Rings
          Positioned(
            top: -20,
            right: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(15),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -10,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(10),
              ),
            ),
          ),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Back Button (Hide if we can't pop)
              if (canPop) ...[
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(40),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withAlpha(50)),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],

              // Info
              Expanded(
                child: Consumer<NotificationProvider>(
                  builder: (context, provider, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Notifications',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                        ),
                        if (provider.unreadCount > 0) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${provider.unreadCount} unread messages',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: Colors.white.withAlpha(200),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),

              // Menu Button
              Consumer<NotificationProvider>(
                builder: (context, provider, _) {
                  return Material(
                    color: Colors.transparent,
                    child: PopupMenuButton<String>(
                      icon: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(30),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.more_vert_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      offset: const Offset(0, 50),
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                      itemBuilder: (context) => [
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
                              Text('Mark all as read', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
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
                                style: TextStyle(color: Colors.red, fontFamily: 'Inter', fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: _primary.withAlpha(20),
              shape: BoxShape.circle,
              border: Border.all(color: _primary.withAlpha(40)),
            ),
            child: Icon(
              Icons.notifications_active_outlined,
              size: 72,
              color: _primary.withAlpha(150),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'All caught up!',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You have no new notifications.\nCheck back later.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              color: _textSecondary.withAlpha(180),
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
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE53E3E), Color(0xFFC53030)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 32),
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
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isUnread ? _unreadBg : _card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isUnread
                  ? _primary.withAlpha(40)
                  : Colors.black.withAlpha(10),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: isUnread ? ImageFilter.blur(sigmaX: 8, sigmaY: 8) : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: _getTypeColor(notification.type).withAlpha(25),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _getTypeColor(notification.type).withAlpha(40),
                        ),
                      ),
                      child: Icon(
                        _getTypeIcon(notification.type),
                        color: _getTypeColor(notification.type),
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
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
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                                    color: _textPrimary,
                                  ),
                                ),
                              ),
                              if (isUnread)
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: _primary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: _primary.withAlpha(100),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            notification.body,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: _textSecondary.withAlpha(isUnread ? 255 : 200),
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.schedule_rounded, size: 12, color: _textMuted.withAlpha(150)),
                              const SizedBox(width: 4),
                              Text(
                                notification.timeAgo,
                                style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: _textMuted),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'booking_created': return Icons.calendar_today_rounded;
      case 'booking_confirmed': return Icons.check_circle_rounded;
      case 'booking_assigned': return Icons.person_pin_rounded;
      case 'booking_in_progress': return Icons.medical_services_rounded;
      case 'booking_completed': return Icons.task_alt_rounded;
      case 'booking_cancelled': return Icons.cancel_rounded;
      case 'nurse_arriving': return Icons.directions_car_rounded;
      case 'payment_received': return Icons.payment_rounded;
      case 'payment_reminder': return Icons.account_balance_wallet_rounded;
      case 'chat_message': return Icons.chat_bubble_rounded;
      case 'triage_result': return Icons.health_and_safety_rounded;
      case 'profile_verified': return Icons.verified_user_rounded;
      case 'profile_rejected': return Icons.gpp_bad_rounded;
      case 'appointment_reminder': return Icons.alarm_rounded;
      case 'promotion': return Icons.local_offer_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'booking_created': return const Color(0xFF3B82F6);
      case 'booking_confirmed': return _primary;
      case 'booking_assigned': return const Color(0xFF8B5CF6);
      case 'booking_in_progress': return const Color(0xFFF59E0B);
      case 'booking_completed': return _primary;
      case 'booking_cancelled': return const Color(0xFFEF4444);
      case 'nurse_arriving': return const Color(0xFF06B6D4);
      case 'payment_received': return _primary;
      case 'payment_reminder': return const Color(0xFFF59E0B);
      case 'chat_message': return const Color(0xFF3B82F6);
      case 'triage_result': return const Color(0xFF06B6D4);
      case 'profile_verified': return _primary;
      case 'profile_rejected': return const Color(0xFFEF4444);
      case 'appointment_reminder': return const Color(0xFFF59E0B);
      case 'promotion': return const Color(0xFFD946EF);
      default: return const Color(0xFF64748B);
    }
  }

  void _onNotificationTap(NotificationModel notification) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(
              _getTypeIcon(notification.type),
              color: _getTypeColor(notification.type),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                notification.title,
                style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.body,
              style: const TextStyle(fontFamily: 'Inter', fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 16),
            Text(
              notification.timeAgo,
              style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: _textMuted),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Close', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(NotificationProvider provider) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Text('Clear all notifications?', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
            content: const Text(
              'This will permanently delete all your notifications. You cannot undo this action.',
              style: TextStyle(fontFamily: 'Inter', height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: _textSecondary, fontFamily: 'Inter', fontWeight: FontWeight.w600),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  provider.clearAllNotifications();
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text(
                  'Clear All',
                  style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
    );
  }
}
