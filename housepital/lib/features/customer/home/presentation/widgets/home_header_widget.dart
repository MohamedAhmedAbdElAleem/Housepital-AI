import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../../auth/data/models/user_model.dart';
import '../../../../notifications/presentation/pages/notifications_page.dart';
import '../../../../../core/providers/notification_provider.dart';
import '../../../../../generated/l10n/app_localizations.dart';
import '../../../../../core/constants/app_colors.dart';

class HomeHeaderWidget extends StatelessWidget {
  final UserModel? user;
  final bool isLoading;
  final VoidCallback? onProfileTap;

  const HomeHeaderWidget({
    super.key,
    required this.user,
    required this.isLoading,
    this.onProfileTap,
  });

  String _getGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    final l10n = AppLocalizations.of(context)!;
    final String baseGreeting;
    if (hour < 12) {
      baseGreeting = l10n.goodMorning;
    } else if (hour < 17) {
      baseGreeting = l10n.goodAfternoon;
    } else {
      baseGreeting = l10n.goodEvening;
    }
    
    final icon = hour < 12 ? '☀️' : (hour < 17 ? '🌤️' : '🌙');
    return '$baseGreeting $icon';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 20,
        20,
        16,
      ),
      child: Row(
        children: [
          // Avatar
          GestureDetector(
            onTap: onProfileTap,
            child: Hero(
              tag: 'user_avatar',
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withAlpha(80),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(40),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: theme.colorScheme.surface,
                  child: isLoading
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: theme.colorScheme.primary,
                          ),
                        )
                      : user?.profileImage != null && user!.profileImage!.isNotEmpty
                          ? ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: user!.profileImage!,
                                width: 52,
                                height: 52,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                errorWidget: (context, url, error) => Text(
                                  user!.name.isNotEmpty ? user!.name[0].toUpperCase() : 'U',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            )
                          : user?.name != null
                              ? Text(
                                  user!.name.isNotEmpty ? user!.name[0].toUpperCase() : 'U',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                )
                              : Icon(
                                  Icons.person_rounded,
                                  color: theme.colorScheme.primary,
                                  size: 28,
                                ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getGreeting(context),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user?.name.split(' ').first ?? l10n.welcomeBack,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Notification Bell
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              final count = provider.unreadCount;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider.value(
                        value: provider,
                        child: const NotificationsPage(),
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(isDark ? 20 : 30),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withAlpha(40),
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 22,
                      ),
                      if (count > 0)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.error500,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              count > 9 ? '9+' : count.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
