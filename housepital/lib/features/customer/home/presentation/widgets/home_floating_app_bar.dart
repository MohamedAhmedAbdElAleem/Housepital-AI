import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../auth/data/models/user_model.dart';
import '../../../../../../generated/l10n/app_localizations.dart';

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

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      top: isScrolled ? 0 : -120,
      left: 0,
      right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 10, 24, 15),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0D0C11).withOpacity(0.8) : Colors.white.withOpacity(0.9),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                ),
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
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(1.5),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: ClipOval(
                          child: user?.profileImage != null && user!.profileImage!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: user!.profileImage!,
                                  width: 35,
                                  height: 35,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => _buildPlaceholder(),
                                  errorWidget: (_, __, ___) => _buildPlaceholder(),
                                )
                              : _buildPlaceholder(),
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
                        'Hi, ${user?.name?.split(" ")[0] ?? l10n.welcomeBack}!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                        ),
                      ),
                    ],
                  ),
                ),
                // Quick Action
                _buildActionIcon(Icons.search_rounded, () {
                  HapticFeedback.lightImpact();
                }),
                const SizedBox(width: 10),
                _buildActionIcon(Icons.notifications_none_rounded, () {
                  HapticFeedback.lightImpact();
                }, hasNotification: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[100],
      child: Icon(Icons.person_rounded, size: 18, color: Colors.grey[400]),
    );
  }

  Widget _buildActionIcon(IconData icon, VoidCallback onTap, {bool hasNotification = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.03),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 22, color: Colors.grey[800]),
          ),
          if (hasNotification)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF4B2B),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
