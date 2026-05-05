import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/nurse_profile_cubit.dart';
import '../../data/models/nurse_profile_model.dart';

class NurseProfilePage extends StatefulWidget {
  const NurseProfilePage({super.key});

  @override
  State<NurseProfilePage> createState() => _NurseProfilePageState();
}

class _NurseProfilePageState extends State<NurseProfilePage> {
  @override
  void initState() {
    super.initState();
    // Load profile if not already loaded
    context.read<NurseProfileCubit>().loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
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
                    Icon(
                      Icons.error_outline,
                      size: 80,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Unable to Load Profile',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<NurseProfileCubit>().loadProfile();
                      },
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

          NurseProfile? profile;
          if (state is NurseProfileLoaded) {
            profile = state.profile;
          } else {
            profile = context.read<NurseProfileCubit>().currentProfile;
          }

          if (profile == null) {
            return const Center(
              child: Text('No profile data available'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header Card
                _buildProfileHeader(profile),
                const SizedBox(height: 24),

                // Status Section
                if (profile.profileStatus != 'approved') ...[
                  _buildStatusCard(profile),
                  const SizedBox(height: 24),
                ],

                // Account Section
                _buildSectionTitle('Account'),
                _buildSettingsCard([
                  _buildSettingsTile(
                    icon: Icons.person_outline,
                    title: 'My Profile',
                    subtitle: 'Standard personal info',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.nursePersonalInfo,
                      );
                    },
                  ),
                  _buildSettingsTile(
                    icon: Icons.badge_outlined,
                    title: 'Professional Credentials',
                    subtitle: 'Medical licenses, ID, and certificates',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.nurseCredentials,
                      );
                    },
                  ),
                  _buildSettingsTile(
                    icon: Icons.map_outlined,
                    title: 'Service Areas',
                    subtitle: 'Geographical zones for travel',
                    showBottomDivider: false,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.nurseServiceAreas,
                      );
                    },
                  ),
                ]),
                const SizedBox(height: 24),

                // Services Section
                _buildSectionTitle('Services'),
                _buildSettingsCard([
                  _buildSettingsTile(
                    icon: Icons.schedule,
                    title: 'Availability & Schedule',
                    subtitle: 'Working hours, days off, shift preferences',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.nurseSchedule,
                      );
                    },
                  ),
                  _buildSettingsTile(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Wallet & Earnings',
                    subtitle: 'Payouts, pending balance, history',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.nurseWallet,
                      );
                    },
                  ),
                  _buildSettingsTile(
                    icon: Icons.star_outline,
                    title: 'Performance & Reviews',
                    subtitle: 'Read patient feedback',
                    showBottomDivider: false,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.nurseReviews,
                      );
                    },
                  ),
                ]),
                const SizedBox(height: 24),

                // Support Section
                _buildSectionTitle('Support'),
                _buildSettingsCard([
                  _buildSettingsTile(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.nurseSettings,
                      );
                    },
                  ),
                  _buildSettingsTile(
                    icon: Icons.logout_rounded,
                    title: 'Sign Out',
                    iconColor: Colors.red,
                    textColor: Colors.red,
                    showBottomDivider: false,
                    onTap: () {
                      _showLogoutConfirmation(context);
                    },
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

  Widget _buildProfileHeader(NurseProfile profile) {
    final userName = profile.userName ?? 'Nurse';
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'N';
    final specialization = profile.specialization ?? 'Registered Nurse';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary500,
            AppColors.primary400,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary500.withOpacity(0.3),
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
              // Avatar
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
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
              // Name and Specialization
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      specialization,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick Stats
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickStat(
                  'Visits',
                  '${profile.completedVisits}',
                  Icons.check_circle_outline,
                ),
                Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
                _buildQuickStat(
                  'Rating',
                  '⭐ ${profile.rating.toStringAsFixed(1)}',
                  Icons.star_border,
                ),
                Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
                _buildQuickStat(
                  'Earnings',
                  'EGP 0', // Using placeholder as earnings aren't in profile yet
                  Icons.account_balance_wallet_outlined,
                ),
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
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    Color? textColor,
    bool showBottomDivider = true,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16), // Match card border radius
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (iconColor ?? AppColors.primary500).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? AppColors.primary500,
                    size: 22,
                  ),
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
                          color: textColor ?? AppColors.textPrimary,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey[400],
                  size: 24,
                ),
              ],
            ),
          ),
          if (showBottomDivider)
            Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey[100],
              indent: 64,
            ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(NurseProfile profile) {
    final statusInfo = _getStatusInfo(profile.profileStatus);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusInfo['bgColor'],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusInfo['borderColor'],
        ),
      ),
      child: Row(
        children: [
          Icon(
            statusInfo['icon'],
            color: statusInfo['textColor'],
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusInfo['title'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: statusInfo['textColor'],
                  ),
                ),
                Text(
                  statusInfo['message'],
                  style: TextStyle(
                    fontSize: 12,
                    color: statusInfo['textColor'],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Colors.red,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sign Out?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Are you sure you want to sign out of your account?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.read<AuthCubit>().logout();
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.login,
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Sign Out'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'incomplete':
        return {
          'icon': Icons.info_outline,
          'title': 'Profile Incomplete',
          'message': 'Please complete your profile to start receiving bookings',
          'textColor': Colors.orange,
          'bgColor': Colors.orange.withOpacity(0.1),
          'borderColor': Colors.orange.withOpacity(0.3),
        };
      case 'pending_review':
        return {
          'icon': Icons.hourglass_empty,
          'title': 'Pending Approval',
          'message': 'Your profile is under review. We\'ll notify you soon',
          'textColor': Colors.blue,
          'bgColor': Colors.blue.withOpacity(0.1),
          'borderColor': Colors.blue.withOpacity(0.3),
        };
      case 'rejected':
        return {
          'icon': Icons.error_outline,
          'title': 'Profile Rejected',
          'message': 'Your profile was rejected. Please review and resubmit',
          'textColor': Colors.red,
          'bgColor': Colors.red.withOpacity(0.1),
          'borderColor': Colors.red.withOpacity(0.3),
        };
      default:
        return {
          'icon': Icons.check_circle,
          'title': 'Profile Approved',
          'message': 'Your profile is active and you can receive bookings',
          'textColor': Colors.green,
          'bgColor': Colors.green.withOpacity(0.1),
          'borderColor': Colors.green.withOpacity(0.3),
        };
    }
  }
}
