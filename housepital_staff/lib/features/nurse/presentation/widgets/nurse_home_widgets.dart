import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../../nurse/data/models/nurse_profile_model.dart';
import '../../../../core/constants/app_colors.dart';

// -----------------------------------------------------------------------------
// 1. STATUS BANNER (Collapsible)
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
    // If approved, don't show the banner (or show minimal if needed, but design says collapse)
    if (profile.profileStatus == 'approved') {
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
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade800;
        icon = Icons.error_outline;
        title = 'Profile Rejected';
        message = profile.rejectionReason ?? 'Please update your documents.';
        ctaText = 'Fix Now';
        break;
      case 'pending_review':
        bgColor = Colors.amber.shade50;
        textColor = Colors.amber.shade900;
        icon = Icons.hourglass_empty;
        title = 'Verification Pending';
        message = 'We are reviewing your profile. This usually takes 24h.';
        ctaText = 'View Status';
        break;
      case 'incomplete':
      default:
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade900;
        icon = Icons.info_outline;
        title = 'Complete Your Profile';
        message = 'You cannot receive requests until your profile is approved.';
        ctaText = 'Finish Setup';
        break;
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: textColor.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: textColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 14),
            ),
            const SizedBox(height: 12),
            if (profile.profileStatus != 'pending_review')
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: textColor,
                  borderRadius: BorderRadius.circular(20),
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
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward,
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
// 2. AVAILABILITY SWITCH (Big Toggle)
// -----------------------------------------------------------------------------
class AvailabilitySwitch extends StatelessWidget {
  final bool isOnline;
  final bool isEnabled;
  final ValueChanged<bool> onChanged;

  const AvailabilitySwitch({
    super.key,
    required this.isOnline,
    required this.isEnabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color = isOnline ? Colors.green : Colors.grey;
    final text = isOnline ? 'ONLINE' : 'OFFLINE';
    final subtext =
        isOnline ? 'You are visible to patients' : 'Go online to start working';

    return GestureDetector(
      onTap: isEnabled ? () => onChanged(!isOnline) : null,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
            border:
                isOnline
                    ? Border.all(color: Colors.green.withOpacity(0.5), width: 2)
                    : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: color,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtext,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 60,
                height: 34,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(34),
                  color: isOnline ? Colors.green : Colors.grey[300],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Align(
                    alignment:
                        isOnline ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 3. WORK ZONE SNAPSHOT
// -----------------------------------------------------------------------------
class WorkZoneSnapshot extends StatelessWidget {
  final WorkZone? workZone;
  final VoidCallback onEdit;

  const WorkZoneSnapshot({super.key, this.workZone, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    if (workZone == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '${workZone!.address} • ${workZone!.radiusKm.toStringAsFixed(0)}km radius',
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          InkWell(
            onTap: onEdit,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                'Edit',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 4. QUICK ACCESS DOCK
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
      padding: const EdgeInsets.symmetric(vertical: 20),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildItem(Icons.person_outline, 'Profile', onProfileTap),
          _buildItem(
            Icons.account_balance_wallet_outlined,
            'Wallet',
            onWalletTap,
          ),
          _buildItem(Icons.history, 'History', onHistoryTap),
          _buildItem(Icons.settings_outlined, 'Settings', onSettingsTap),
        ],
      ),
    );
  }

  Widget _buildItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[50], // Very subtle
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.grey[800], size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
