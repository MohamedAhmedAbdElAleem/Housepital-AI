import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../nurse/data/models/nurse_profile_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/data/repositories/auth_repository.dart';

// -----------------------------------------------------------------------------
// 1. HOME BACKGROUND WIDGET
// -----------------------------------------------------------------------------
class NurseHomeBackground extends StatefulWidget {
  const NurseHomeBackground({super.key});

  @override
  State<NurseHomeBackground> createState() => _NurseHomeBackgroundState();
}

class _NurseHomeBackgroundState extends State<NurseHomeBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topBlobColor = theme.colorScheme.primary;
    final bottomBlobColor = theme.colorScheme.secondary;

    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: -120,
              right: -80,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, _) {
                  return Transform.scale(
                    scale: 1 + (_pulseController.value * 0.05),
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            topBlobColor.withAlpha(60),
                            topBlobColor.withAlpha(0),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 50,
              left: -100,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      bottomBlobColor.withAlpha(45),
                      bottomBlobColor.withAlpha(0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 2. NURSE HOME HEADER
// -----------------------------------------------------------------------------
class NurseHomeHeader extends StatelessWidget {
  final AuthUser? user;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationsTap;

  const NurseHomeHeader({
    super.key,
    required this.user,
    this.onProfileTap,
    this.onNotificationsTap,
  });

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                  // AuthUser doesn't have profileImage in its definition, 
                  // so we'll just use the initial for now.
                  child: Text(
                    user?.name[0].toUpperCase() ?? 'N',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
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
                  _greeting,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user?.name.split(' ').first ?? 'Nurse',
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
          GestureDetector(
            onTap: onNotificationsTap,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(isDark ? 20 : 30),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withAlpha(40), width: 1),
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 3. STATUS BANNER (Collapsible)
// -----------------------------------------------------------------------------
class ProfileStatusBanner extends StatelessWidget {
  final NurseProfile profile;
  final VoidCallback onTap;

  const ProfileStatusBanner({
    super.key,
    required this.profile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (profile.profileStatus == 'approved' ||
        profile.verificationStatus == 'approved') {
      return const SizedBox.shrink();
    }

    Color bgColor;
    Color textColor;
    IconData icon;
    String title;
    String message;
    String ctaText;

    switch (profile.profileStatus) {
      case 'rejected':
        bgColor = AppColors.error50;
        textColor = AppColors.error700;
        icon = Icons.error_outline;
        title = 'Profile Rejected';
        message = profile.rejectionReason ?? 'Please update your documents.';
        ctaText = 'Fix Now';
        break;
      case 'pending_review':
        bgColor = AppColors.warning50;
        textColor = AppColors.warning900;
        icon = Icons.hourglass_empty;
        title = 'Verification Pending';
        message = 'We are reviewing your profile. This usually takes 24h.';
        ctaText = 'View Status';
        break;
      case 'incomplete':
      default:
        bgColor = AppColors.warning50;
        textColor = AppColors.warning900;
        icon = Icons.info_outline;
        title = 'Complete Your Profile';
        message = 'You cannot receive requests until your profile is approved.';
        ctaText = 'Finish Setup';
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: textColor.withAlpha(40)),
          boxShadow: [
            BoxShadow(
              color: textColor.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: textColor, size: 20),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: textColor.withAlpha(200),
                fontSize: 13,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 12),
            if (profile.profileStatus != 'pending_review')
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: textColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      ctaText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 4. WORK ZONE SNAPSHOT
// -----------------------------------------------------------------------------
class WorkZoneSnapshot extends StatelessWidget {
  final WorkZone? workZone;
  final VoidCallback onEdit;

  const WorkZoneSnapshot({super.key, this.workZone, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    if (workZone == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.light400),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              size: 18,
              color: AppColors.primary500,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Work Zone',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${workZone!.address} • ${workZone!.radiusKm.toStringAsFixed(0)}km',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    fontFamily: 'Inter',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onEdit,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Change',
              style: TextStyle(
                color: AppColors.primary500,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 5. QUICK ACCESS DOCK
// -----------------------------------------------------------------------------
class QuickAccessDock extends StatelessWidget {
  final VoidCallback onProfileTap;
  final VoidCallback onWalletTap;
  final VoidCallback onHistoryTap;
  final VoidCallback onSettingsTap;

  const QuickAccessDock({
    super.key,
    required this.onProfileTap,
    required this.onWalletTap,
    required this.onHistoryTap,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildItem(Icons.person_outline_rounded, 'Profile', onProfileTap),
          _buildItem(
            Icons.account_balance_wallet_outlined,
            'Wallet',
            onWalletTap,
          ),
          _buildItem(Icons.history_rounded, 'History', onHistoryTap),
          _buildItem(Icons.settings_outlined, 'Settings', onSettingsTap),
        ],
      ),
    );
  }

  Widget _buildItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.light100,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}
