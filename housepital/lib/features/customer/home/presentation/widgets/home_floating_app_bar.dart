import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../auth/data/models/user_model.dart';
import '../../../../notifications/presentation/pages/notifications_page.dart';
import '../../../../../core/providers/notification_provider.dart';
import '../../../../../generated/l10n/app_localizations.dart';
import '../../../../../core/constants/app_colors.dart';
import '../pages/search_page.dart';

class HomeFloatingAppBar extends StatelessWidget {
  final bool isScrolled;
  final UserModel? user;

  const HomeFloatingAppBar({
    super.key,
    required this.isScrolled,
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notificationProvider = context.watch<NotificationProvider>();
    final unreadCount = notificationProvider.unreadCount;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      top: isScrolled ? MediaQuery.of(context).padding.top + 10 : -100,
      left: 20,
      right: 20,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isDark 
                    ? AppColors.dark700.withOpacity(0.8) 
                    : Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark 
                      ? Colors.white.withOpacity(0.1) 
                      : AppColors.primary500.withOpacity(0.1),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  // Mini Avatar
                  Hero(
                    tag: 'home_avatar_mini',
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(1.5),
                        child: CircleAvatar(
                          backgroundColor: isDark ? AppColors.dark700 : Colors.white,
                          child: ClipOval(
                            child: user?.profileImage != null && user!.profileImage!.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: user!.profileImage!,
                                    width: 35,
                                    height: 35,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => _buildPlaceholder(isDark),
                                    errorWidget: (_, __, ___) => _buildPlaceholder(isDark),
                                  )
                                : _buildPlaceholder(isDark),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Hi, ${user?.name.split(" ")[0] ?? l10n.welcomeBack}!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Quick Action Search
                  _buildActionIcon(
                    Icons.search_rounded, 
                    () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SearchPage()),
                      );
                    },
                    isDark: isDark,
                  ),
                  const SizedBox(width: 10),
                  // Quick Action Notifications
                  _buildActionIcon(
                    Icons.notifications_none_rounded, 
                    () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider.value(
                            value: notificationProvider,
                            child: const NotificationsPage(),
                          ),
                        ),
                      );
                    },
                    isDark: isDark,
                    badgeCount: unreadCount,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(bool isDark) {
    return Container(
      color: isDark ? AppColors.dark600 : Colors.grey[100],
      child: Icon(Icons.person_rounded, size: 18, color: isDark ? Colors.grey[600] : Colors.grey[400]),
    );
  }

  Widget _buildActionIcon(IconData icon, VoidCallback onTap, {required bool isDark, int badgeCount = 0}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon, 
              size: 22, 
              color: isDark ? Colors.white : AppColors.dark200,
            ),
          ),
          if (badgeCount > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(3),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error500,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppColors.dark700 : Colors.white,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  badgeCount > 9 ? '9+' : badgeCount.toString(),
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
