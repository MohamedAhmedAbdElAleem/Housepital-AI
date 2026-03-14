import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/notification_provider.dart';
import '../../../features/notifications/presentation/pages/notifications_page.dart';

/// A notification bell icon with an unread badge.
/// Use this widget in any app bar or header to show notification access.
class NotificationBell extends StatelessWidget {
  final Color iconColor;
  final double iconSize;

  const NotificationBell({
    super.key,
    this.iconColor = Colors.white,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, _) {
        final count = provider.unreadCount;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => ChangeNotifierProvider.value(
                      value: provider,
                      child: const NotificationsPage(),
                    ),
              ),
            );
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.notifications_outlined,
                  color: iconColor,
                  size: iconSize,
                ),
                if (count > 0)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Text(
                        count > 99 ? '99+' : count.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
