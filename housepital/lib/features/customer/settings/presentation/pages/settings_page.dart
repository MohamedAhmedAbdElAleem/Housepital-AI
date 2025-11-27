import 'package:flutter/material.dart';
import '../../../../../core/utils/token_manager.dart';
import '../../../../../core/constants/app_routes.dart';
import 'personal_info_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _biometricEnabled = false;
  bool _twoFactorEnabled = true;
  bool _pushNotifications = false;
  bool _smsUpdates = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              color: const Color(0xFF1E293B),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // APPEARANCE SECTION
            _buildSectionLabel('Appearance'),
            const SizedBox(height: 12),
            _buildSettingsItem(
              icon: Icons.palette_outlined,
              iconColor: const Color(0xFF3B82F6),
              title: 'Theme',
              onTap: () {},
            ),

            const SizedBox(height: 24),

            // ACCOUNT SECTION
            _buildSectionLabel('Account'),
            const SizedBox(height: 12),
            _buildSettingsItem(
              icon: Icons.person_outline,
              iconColor: const Color(0xFF2ECC71),
              title: 'Personal Info',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PersonalInfoPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildSettingsItem(
              icon: Icons.link,
              iconColor: const Color(0xFF8B5CF6),
              title: 'Linked Accounts',
              subtitle: '2 Active',
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _buildSettingsItem(
              icon: Icons.account_balance_wallet_outlined,
              iconColor: const Color(0xFFF59E0B),
              title: 'Payment Methods',
              onTap: () {},
            ),

            const SizedBox(height: 24),

            // SECURITY & PRIVACY SECTION
            _buildSectionLabel('Security & Privacy'),
            const SizedBox(height: 12),
            _buildSettingsItemWithSwitch(
              icon: Icons.fingerprint,
              iconColor: const Color(0xFF3B82F6),
              title: 'Biometric ID',
              value: _biometricEnabled,
              onChanged: (value) {
                setState(() {
                  _biometricEnabled = value;
                });
              },
            ),
            const SizedBox(height: 12),
            _buildSettingsItemWithSwitch(
              icon: Icons.security,
              iconColor: const Color(0xFF8B5CF6),
              title: 'Two-Factor Auth',
              value: _twoFactorEnabled,
              onChanged: (value) {
                setState(() {
                  _twoFactorEnabled = value;
                });
              },
            ),
            const SizedBox(height: 12),
            _buildSettingsItem(
              icon: Icons.history,
              iconColor: const Color(0xFF6366F1),
              title: 'Clear AI History',
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _buildSettingsItem(
              icon: Icons.lock_outline,
              iconColor: const Color(0xFFEC4899),
              title: 'Change Password',
              onTap: () {},
            ),

            const SizedBox(height: 24),

            // NOTIFICATIONS SECTION
            _buildSectionLabel('Notifications'),
            const SizedBox(height: 12),
            _buildSettingsItemWithSwitch(
              icon: Icons.notifications_outlined,
              iconColor: const Color(0xFF3B82F6),
              title: 'Push Notifications',
              value: _pushNotifications,
              onChanged: (value) {
                setState(() {
                  _pushNotifications = value;
                });
              },
            ),
            const SizedBox(height: 12),
            _buildSettingsItemWithSwitch(
              icon: Icons.sms_outlined,
              iconColor: const Color(0xFF10B981),
              title: 'SMS Updates',
              value: _smsUpdates,
              onChanged: (value) {
                setState(() {
                  _smsUpdates = value;
                });
              },
            ),

            const SizedBox(height: 32),

            // SIGN OUT BUTTON
            GestureDetector(
              onTap: () {
                _showSignOutDialog(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  border: Border.all(color: const Color(0xFFEF4444)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.logout,
                      color: Color(0xFFEF4444),
                      size: 22,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Sign Out',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // FOOTER
            Center(
              child: Text(
                'Housepital App v1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey[600],
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItemWithSwitch({
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF2ECC71),
            activeTrackColor: const Color(0xFF2ECC71).withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Sign Out',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Clear token
              await TokenManager.deleteToken();
              // Navigate to login
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
