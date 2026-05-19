import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/nurse_profile_cubit.dart';
import '../../data/models/nurse_profile_model.dart';
import '../../../../l10n/app_localizations.dart';

class NurseProfilePage extends StatefulWidget {
  const NurseProfilePage({super.key});

  @override
  State<NurseProfilePage> createState() => _NurseProfilePageState();
}

class _NurseProfilePageState extends State<NurseProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<NurseProfileCubit>().loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.myProfile,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: AppColors.primary500,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocBuilder<NurseProfileCubit, NurseProfileState>(
        builder: (context, state) {
          if (state is NurseProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NurseProfileError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
                    const SizedBox(height: 24),
                    Text(
                      'Unable to Load Profile',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface.withAlpha(150)),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => context.read<NurseProfileCubit>().loadProfile(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary500,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          NurseProfile? profile = state is NurseProfileLoaded 
              ? state.profile 
              : context.read<NurseProfileCubit>().currentProfile;

          if (profile == null) {
            return const Center(child: Text('No profile data available'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(context, profile, l10n),
                const SizedBox(height: 24),

                if (profile.profileStatus != 'approved') ...[
                  _buildStatusCard(context, profile),
                  const SizedBox(height: 24),
                ],

                _buildSectionTitle(context, l10n.myProfile),
                _buildSettingsCard(context, [
                  _buildSettingsTile(
                    context,
                    icon: Icons.person_outline,
                    title: l10n.myProfile,
                    subtitle: 'Standard personal info',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.nursePersonalInfo),
                  ),
                  _buildSettingsTile(
                    context,
                    icon: Icons.badge_outlined,
                    title: l10n.credentials,
                    subtitle: 'Medical licenses, ID, and certificates',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.nurseCredentials),
                  ),
                  _buildSettingsTile(
                    context,
                    icon: Icons.map_outlined,
                    title: l10n.serviceAreas,
                    subtitle: 'Geographical zones for travel',
                    showBottomDivider: false,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.nurseServiceAreas),
                  ),
                ]),
                const SizedBox(height: 24),

                _buildSectionTitle(context, l10n.performanceReviews),
                _buildSettingsCard(context, [
                  _buildSettingsTile(
                    context,
                    icon: Icons.schedule,
                    title: 'Availability & Schedule',
                    subtitle: 'Working hours, days off, shift preferences',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.nurseSchedule),
                  ),
                  _buildSettingsTile(
                    context,
                    icon: Icons.account_balance_wallet_outlined,
                    title: '${l10n.wallet} & Earnings',
                    subtitle: 'Payouts, pending balance, history',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.nurseWallet),
                  ),
                  _buildSettingsTile(
                    context,
                    icon: Icons.star_outline,
                    title: l10n.performanceReviews,
                    subtitle: 'Read patient feedback',
                    showBottomDivider: false,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.nurseReviews),
                  ),
                ]),
                const SizedBox(height: 24),

                _buildSectionTitle(context, l10n.settings),
                _buildSettingsCard(context, [
                  _buildSettingsTile(
                    context,
                    icon: Icons.settings_outlined,
                    title: l10n.settings,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.nurseSettings),
                  ),
                  _buildSettingsTile(
                    context,
                    icon: Icons.logout_rounded,
                    title: l10n.signOut,
                    iconColor: Colors.red,
                    textColor: Colors.red,
                    showBottomDivider: false,
                    onTap: () => _showLogoutConfirmation(context, l10n),
                  ),
                ]),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, NurseProfile profile, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final userName = profile.userName ?? 'Nurse';
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'N';
    final specialization = profile.specialization ?? 'Registered Nurse';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary600, AppColors.primary400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary500.withAlpha(theme.brightness == Brightness.dark ? 40 : 80),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.surface,
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 10)],
                ),
                child: Center(
                  child: Text(
                    userInitial,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      specialization,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white.withAlpha(230)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(40),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickStat('Visits', '${profile.completedVisits}', Icons.check_circle_outline),
                Container(width: 1, height: 40, color: Colors.white.withAlpha(40)),
                _buildQuickStat('Rating', '⭐ ${profile.rating.toStringAsFixed(1)}', Icons.star_border),
                Container(width: 1, height: 40, color: Colors.white.withAlpha(40)),
                _buildQuickStat(l10n.wallet, 'EGP 0', Icons.account_balance_wallet_outlined),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 12)),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, List<Widget> children) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withAlpha(theme.brightness == Brightness.dark ? 50 : 100)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(theme.brightness == Brightness.dark ? 40 : 10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    Color? textColor,
    bool showBottomDivider = true,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (iconColor ?? AppColors.primary500).withAlpha(isDark ? 30 : 25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor ?? AppColors.primary500, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor ?? theme.colorScheme.onSurface,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withAlpha(150)),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurface.withAlpha(100), size: 24),
              ],
            ),
          ),
          if (showBottomDivider)
            Divider(height: 1, thickness: 1, color: theme.colorScheme.outline.withAlpha(50), indent: 64),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, NurseProfile profile) {
    final theme = Theme.of(context);
    final statusInfo = _getStatusInfo(profile.profileStatus, theme.brightness == Brightness.dark);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusInfo['bgColor'],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusInfo['borderColor']),
      ),
      child: Row(
        children: [
          Icon(statusInfo['icon'], color: statusInfo['textColor'], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusInfo['title'],
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: statusInfo['textColor']),
                ),
                Text(
                  statusInfo['message'],
                  style: TextStyle(fontSize: 12, color: statusInfo['textColor']),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withAlpha(100),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(theme.brightness == Brightness.dark ? 40 : 25),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded, color: Colors.red, size: 32),
            ),
            const SizedBox(height: 20),
            Text(
              '${l10n.signOut}?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              'Are you sure you want to sign out of your account?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withAlpha(150)),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      foregroundColor: theme.colorScheme.onSurface.withAlpha(150),
                      side: BorderSide(color: theme.colorScheme.outline.withAlpha(100)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(l10n.goBack, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.read<AuthCubit>().logout();
                      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(l10n.signOut),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(String status, bool isDark) {
    switch (status) {
      case 'incomplete':
        return {
          'icon': Icons.info_outline,
          'title': 'Profile Incomplete',
          'message': 'Please complete your profile to start receiving bookings',
          'textColor': isDark ? Colors.orange[200] : Colors.orange[800],
          'bgColor': Colors.orange.withAlpha(isDark ? 40 : 25),
          'borderColor': Colors.orange.withAlpha(isDark ? 80 : 50),
        };
      case 'pending_review':
        return {
          'icon': Icons.hourglass_empty,
          'title': 'Pending Approval',
          'message': 'Your profile is under review. We\'ll notify you soon',
          'textColor': isDark ? Colors.blue[200] : Colors.blue[800],
          'bgColor': Colors.blue.withAlpha(isDark ? 40 : 25),
          'borderColor': Colors.blue.withAlpha(isDark ? 80 : 50),
        };
      case 'rejected':
        return {
          'icon': Icons.error_outline,
          'title': 'Profile Rejected',
          'message': 'Your profile was rejected. Please review and resubmit',
          'textColor': isDark ? Colors.red[200] : Colors.red[800],
          'bgColor': Colors.red.withAlpha(isDark ? 40 : 25),
          'borderColor': Colors.red.withAlpha(isDark ? 80 : 50),
        };
      default:
        return {
          'icon': Icons.check_circle,
          'title': 'Profile Approved',
          'message': 'Your profile is active and you can receive bookings',
          'textColor': isDark ? Colors.green[200] : Colors.green[800],
          'bgColor': Colors.green.withAlpha(isDark ? 40 : 25),
          'borderColor': Colors.green.withAlpha(isDark ? 80 : 50),
        };
    }
  }
}
