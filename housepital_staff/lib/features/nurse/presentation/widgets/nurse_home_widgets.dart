import 'package:flutter/material.dart';
import '../../../nurse/data/models/nurse_profile_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../../../l10n/app_localizations.dart';

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
  final NurseProfile? profile;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationsTap;

  const NurseHomeHeader({
    super.key,
    required this.user,
    this.profile,
    this.onProfileTap,
    this.onNotificationsTap,
  });

  String _getGreeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.goodMorning;
    if (hour < 17) return l10n.goodAfternoon;
    return l10n.goodEvening;
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
                  _getGreeting(l10n),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Colors.white.withAlpha(180),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user?.name.split(' ').first ?? (profile?.gender == 'male' ? l10n.nurseMale : (profile?.gender == 'female' ? l10n.nurseFemale : l10n.nurse)),
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

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    Color bgColor;
    Color textColor;
    IconData icon;
    String title;
    String message;
    String ctaText;

    switch (profile.profileStatus) {
      case 'rejected':
        bgColor = isDark ? AppColors.error900.withAlpha(50) : AppColors.error50;
        textColor = isDark ? AppColors.error200 : AppColors.error700;
        icon = Icons.error_outline;
        title = l10n.updateDocuments;
        message = profile.rejectionReason ?? l10n.updateDocuments;
        ctaText = l10n.fixNow;
        break;
      case 'pending_review':
        bgColor = isDark ? AppColors.warning900.withAlpha(50) : AppColors.warning50;
        textColor = isDark ? AppColors.warning200 : AppColors.warning900;
        icon = Icons.hourglass_empty;
        title = l10n.reviewDuration;
        message = l10n.reviewDuration;
        ctaText = l10n.viewStatus;
        break;
      case 'incomplete':
      default:
        bgColor = isDark ? AppColors.warning900.withAlpha(50) : AppColors.warning50;
        textColor = isDark ? AppColors.warning200 : AppColors.warning900;
        icon = Icons.info_outline;
        title = l10n.editProfileData;
        message = l10n.profileApprovalRequired;
        ctaText = l10n.finishSetup;
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
          border: Border.all(color: textColor.withAlpha(isDark ? 80 : 40)),
          boxShadow: [
            BoxShadow(
              color: textColor.withAlpha(isDark ? 10 : 20),
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
                      style: TextStyle(
                        color: isDark ? AppColors.dark900 : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withAlpha(isDark ? 40 : 100)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(isDark ? 40 : 25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.location_on_rounded,
              size: 18,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.yourWorkZone,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withAlpha(150),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${workZone!.address} • ${workZone!.radiusKm.toStringAsFixed(0)}km',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
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
            child: Text(
              l10n.change,
              style: TextStyle(
                color: theme.colorScheme.primary,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 40 : 10),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildItem(context, Icons.person_outline_rounded, l10n.profile, onProfileTap),
          _buildItem(context, Icons.account_balance_wallet_outlined, l10n.wallet, onWalletTap),
          _buildItem(context, Icons.history_rounded, l10n.history, onHistoryTap),
          _buildItem(context, Icons.settings_outlined, l10n.settings, onSettingsTap),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withAlpha(isDark ? 100 : 255),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: theme.colorScheme.onSurface, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}
