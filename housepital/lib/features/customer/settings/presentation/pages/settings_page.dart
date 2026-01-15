import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../core/utils/token_manager.dart';
import '../../../../../core/constants/app_routes.dart';
import '../../../../../core/network/api_service.dart';
import '../../../../auth/data/models/user_model.dart';
import '../../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../../auth/data/datasources/auth_remote_datasource.dart';
import '../../../../auth/presentation/pages/login_page.dart';
import '../../../profile/presentation/pages/account_page.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Design System
// ═══════════════════════════════════════════════════════════════════════════
class _SettingsDesign {
  // Colors
  static const Color primaryGreen = Color(0xFF2ECC71);
  static const Color secondaryGreen = Color(0xFF27AE60);
  static const Color surface = Color(0xFFF8FAFC);
  static const Color cardBg = Colors.white;
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color divider = Color(0xFFE2E8F0);
  static const Color danger = Color(0xFFEF4444);

  // Gradients
  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Section Colors
  static const Color accountColor = Color(0xFF3B82F6);
  static const Color securityColor = Color(0xFF8B5CF6);
  static const Color notificationColor = Color(0xFFF59E0B);
  static const Color appearanceColor = Color(0xFF06B6D4);
  static const Color privacyColor = Color(0xFFEC4899);
  static const Color dataColor = Color(0xFF10B981);

  // Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: primaryGreen.withOpacity(0.3),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with TickerProviderStateMixin {
  // User Data
  UserModel? _user;
  bool _isLoading = true;

  // Animations
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  // Settings State
  bool _biometricEnabled = false;
  bool _twoFactorEnabled = true;
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsUpdates = false;
  bool _darkMode = false;
  String _selectedLanguage = 'English';

  // Expanded Sections
  final Set<String> _expandedSections = {};

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadUserData();
  }

  void _initAnimations() {
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final apiService = ApiService();
      final remoteDataSource = AuthRemoteDataSourceImpl(apiService: apiService);
      final repository = AuthRepositoryImpl(remoteDataSource: remoteDataSource);

      final response = await repository.getCurrentUser();

      if (mounted) {
        setState(() {
          _user = response.user;
          _isLoading = false;
        });
        _animController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _animController.forward();
      }
    }
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  void _toggleSection(String section) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_expandedSections.contains(section)) {
        _expandedSections.remove(section);
      } else {
        _expandedSections.add(section);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _SettingsDesign.surface,
      body: _isLoading ? _buildLoadingState() : _buildContent(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _SettingsDesign.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              color: _SettingsDesign.primaryGreen,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Loading settings...',
            style: TextStyle(
              color: _SettingsDesign.textSecondary,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder:
          (context, child) => Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Custom Header
                  SliverToBoxAdapter(child: _buildHeader()),

                  // Settings Sections
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Profile Card
                        _buildProfileCard(),
                        const SizedBox(height: 24),

                        // Account Section
                        _buildSectionTitle(
                          'Account',
                          Icons.person_outline_rounded,
                          _SettingsDesign.accountColor,
                        ),
                        const SizedBox(height: 12),
                        _buildSettingsCard([
                          _buildSettingsTile(
                            icon: Icons.person_outline_rounded,
                            iconColor: _SettingsDesign.accountColor,
                            title: 'My Account',
                            subtitle: 'Profile, personal info, security',
                            onTap: () => _navigateToAccount(),
                          ),
                          _buildSettingsTile(
                            icon: Icons.link_rounded,
                            iconColor: const Color(0xFF8B5CF6),
                            title: 'Linked Accounts',
                            subtitle: 'Google, Apple, Facebook',
                            trailing: _buildBadge('2'),
                            onTap: () {},
                          ),
                          _buildSettingsTile(
                            icon: Icons.account_balance_wallet_outlined,
                            iconColor: _SettingsDesign.notificationColor,
                            title: 'Payment Methods',
                            subtitle: 'Cards, wallets',
                            onTap: () {},
                            showDivider: false,
                          ),
                        ]),

                        const SizedBox(height: 24),

                        // Security Section
                        _buildSectionTitle(
                          'Security & Privacy',
                          Icons.shield_outlined,
                          _SettingsDesign.securityColor,
                        ),
                        const SizedBox(height: 12),
                        _buildSettingsCard([
                          _buildToggleTile(
                            icon: Icons.fingerprint_rounded,
                            iconColor: _SettingsDesign.securityColor,
                            title: 'Biometric Login',
                            subtitle: 'Use fingerprint or face',
                            value: _biometricEnabled,
                            onChanged: (v) {
                              HapticFeedback.mediumImpact();
                              setState(() => _biometricEnabled = v);
                            },
                          ),
                          _buildToggleTile(
                            icon: Icons.security_rounded,
                            iconColor: const Color(0xFF6366F1),
                            title: 'Two-Factor Authentication',
                            subtitle: 'Extra security layer',
                            value: _twoFactorEnabled,
                            onChanged: (v) {
                              HapticFeedback.mediumImpact();
                              setState(() => _twoFactorEnabled = v);
                            },
                          ),
                          _buildSettingsTile(
                            icon: Icons.history_rounded,
                            iconColor: const Color(0xFF06B6D4),
                            title: 'Login Activity',
                            subtitle: 'Recent sessions',
                            onTap: () {},
                            showDivider: false,
                          ),
                        ]),

                        const SizedBox(height: 24),

                        // Notifications Section
                        _buildSectionTitle(
                          'Notifications',
                          Icons.notifications_outlined,
                          _SettingsDesign.notificationColor,
                        ),
                        const SizedBox(height: 12),
                        _buildSettingsCard([
                          _buildToggleTile(
                            icon: Icons.notifications_active_outlined,
                            iconColor: _SettingsDesign.notificationColor,
                            title: 'Push Notifications',
                            subtitle: 'Booking updates, reminders',
                            value: _pushNotifications,
                            onChanged: (v) {
                              HapticFeedback.mediumImpact();
                              setState(() => _pushNotifications = v);
                            },
                          ),
                          _buildToggleTile(
                            icon: Icons.email_outlined,
                            iconColor: const Color(0xFF3B82F6),
                            title: 'Email Notifications',
                            subtitle: 'Receipts, promotions',
                            value: _emailNotifications,
                            onChanged: (v) {
                              HapticFeedback.mediumImpact();
                              setState(() => _emailNotifications = v);
                            },
                          ),
                          _buildToggleTile(
                            icon: Icons.sms_outlined,
                            iconColor: _SettingsDesign.dataColor,
                            title: 'SMS Updates',
                            subtitle: 'Important alerts only',
                            value: _smsUpdates,
                            onChanged: (v) {
                              HapticFeedback.mediumImpact();
                              setState(() => _smsUpdates = v);
                            },
                            showDivider: false,
                          ),
                        ]),

                        const SizedBox(height: 24),

                        // Appearance Section
                        _buildSectionTitle(
                          'Appearance & Language',
                          Icons.palette_outlined,
                          _SettingsDesign.appearanceColor,
                        ),
                        const SizedBox(height: 12),
                        _buildSettingsCard([
                          _buildToggleTile(
                            icon: Icons.dark_mode_outlined,
                            iconColor: const Color(0xFF6366F1),
                            title: 'Dark Mode',
                            subtitle: 'Easier on the eyes',
                            value: _darkMode,
                            onChanged: (v) {
                              HapticFeedback.mediumImpact();
                              setState(() => _darkMode = v);
                            },
                          ),
                          _buildSettingsTile(
                            icon: Icons.language_rounded,
                            iconColor: _SettingsDesign.appearanceColor,
                            title: 'Language',
                            subtitle: _selectedLanguage,
                            onTap: () => _showLanguageSheet(),
                            showDivider: false,
                          ),
                        ]),

                        const SizedBox(height: 24),

                        // Data & Storage Section
                        _buildSectionTitle(
                          'Data & Storage',
                          Icons.storage_outlined,
                          _SettingsDesign.dataColor,
                        ),
                        const SizedBox(height: 12),
                        _buildSettingsCard([
                          _buildSettingsTile(
                            icon: Icons.cleaning_services_outlined,
                            iconColor: const Color(0xFFF59E0B),
                            title: 'Clear Cache',
                            subtitle: 'Free up space',
                            onTap: () => _showClearCacheDialog(),
                          ),
                          _buildSettingsTile(
                            icon: Icons.history_rounded,
                            iconColor: const Color(0xFF8B5CF6),
                            title: 'Clear AI History',
                            subtitle: 'Remove chat history',
                            onTap: () => _showClearAIHistoryDialog(),
                          ),
                          _buildSettingsTile(
                            icon: Icons.download_outlined,
                            iconColor: _SettingsDesign.dataColor,
                            title: 'Download My Data',
                            subtitle: 'Export your information',
                            onTap: () {},
                            showDivider: false,
                          ),
                        ]),

                        const SizedBox(height: 24),

                        // About Section
                        _buildSectionTitle(
                          'About',
                          Icons.info_outline_rounded,
                          _SettingsDesign.textSecondary,
                        ),
                        const SizedBox(height: 12),
                        _buildSettingsCard([
                          _buildSettingsTile(
                            icon: Icons.description_outlined,
                            iconColor: _SettingsDesign.textSecondary,
                            title: 'Terms of Service',
                            onTap: () {},
                          ),
                          _buildSettingsTile(
                            icon: Icons.privacy_tip_outlined,
                            iconColor: _SettingsDesign.textSecondary,
                            title: 'Privacy Policy',
                            onTap: () {},
                          ),
                          _buildSettingsTile(
                            icon: Icons.help_outline_rounded,
                            iconColor: _SettingsDesign.textSecondary,
                            title: 'Help & Support',
                            onTap: () {},
                            showDivider: false,
                          ),
                        ]),

                        const SizedBox(height: 32),

                        // Sign Out Button
                        _buildSignOutButton(),

                        const SizedBox(height: 24),

                        // App Version
                        _buildAppVersion(),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(gradient: _SettingsDesign.headerGradient),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 20),
              child: Row(
                children: [
                  // Back Button
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 20,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Settings',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balance back button
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _SettingsDesign.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: _SettingsDesign.cardShadow,
      ),
      child: Row(
        children: [
          // Avatar
          Hero(
            tag: 'profile_avatar',
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _SettingsDesign.headerGradient,
                boxShadow: [
                  BoxShadow(
                    color: _SettingsDesign.primaryGreen.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child:
                  _user?.profileImage != null && _user!.profileImage!.isNotEmpty
                      ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: _user!.profileImage!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _buildAvatarPlaceholder(),
                          errorWidget:
                              (_, __, ___) => _buildAvatarPlaceholder(),
                        ),
                      )
                      : _buildAvatarPlaceholder(),
            ),
          ),
          const SizedBox(width: 16),
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _user?.name ?? 'User',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _SettingsDesign.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_user?.isVerified == true) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: _SettingsDesign.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _user?.email ?? 'email@example.com',
                  style: const TextStyle(
                    fontSize: 14,
                    color: _SettingsDesign.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _SettingsDesign.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _user?.role.toUpperCase() ?? 'CUSTOMER',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _SettingsDesign.primaryGreen,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Edit Button
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _SettingsDesign.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: _SettingsDesign.primaryGreen,
                size: 22,
              ),
              onPressed: () => _navigateToAccount(),
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Center(
      child: Text(
        _getInitials(_user?.name),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _SettingsDesign.textSecondary,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: _SettingsDesign.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _SettingsDesign.cardShadow,
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onTap();
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _SettingsDesign.textPrimary,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 13,
                              color: _SettingsDesign.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) ...[trailing, const SizedBox(width: 8)],
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: _SettingsDesign.textMuted,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              height: 1,
              color: _SettingsDesign.divider.withOpacity(0.5),
            ),
          ),
      ],
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _SettingsDesign.textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: _SettingsDesign.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Transform.scale(
                scale: 0.85,
                child: Switch.adaptive(
                  value: value,
                  onChanged: onChanged,
                  activeColor: _SettingsDesign.primaryGreen,
                  activeTrackColor: _SettingsDesign.primaryGreen.withOpacity(
                    0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              height: 1,
              color: _SettingsDesign.divider.withOpacity(0.5),
            ),
          ),
      ],
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _SettingsDesign.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _SettingsDesign.primaryGreen,
        ),
      ),
    );
  }

  Widget _buildSignOutButton() {
    return GestureDetector(
      onTap: () => _showSignOutDialog(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _SettingsDesign.danger.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _SettingsDesign.danger.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: _SettingsDesign.danger, size: 22),
            const SizedBox(width: 10),
            Text(
              'Sign Out',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _SettingsDesign.danger,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppVersion() {
    return Column(
      children: [
        Text(
          'Housepital',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _SettingsDesign.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Version 1.0.0',
          style: TextStyle(fontSize: 13, color: _SettingsDesign.textMuted),
        ),
        const SizedBox(height: 8),
        Text(
          '© 2025 Housepital. All rights reserved.',
          style: TextStyle(fontSize: 12, color: _SettingsDesign.textMuted),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Bottom Sheets & Dialogs
  // ═══════════════════════════════════════════════════════════════════════════

  void _navigateToAccount() async {
    HapticFeedback.lightImpact();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AccountPage()),
    );
    // Refresh user data if changes were made
    if (result == true) {
      _loadUserData();
    }
  }

  void _showLanguageSheet() {
    HapticFeedback.mediumImpact();
    final languages = ['English', 'العربية', 'Français', 'Español', 'Deutsch'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  'Select Language',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _SettingsDesign.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),

                // Languages
                ...languages.map((lang) => _buildLanguageOption(lang)),

                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }

  Widget _buildLanguageOption(String language) {
    final isSelected = _selectedLanguage == language;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedLanguage = language);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? _SettingsDesign.primaryGreen.withOpacity(0.1)
                  : _SettingsDesign.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected
                    ? _SettingsDesign.primaryGreen
                    : _SettingsDesign.divider,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                language,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color:
                      isSelected
                          ? _SettingsDesign.primaryGreen
                          : _SettingsDesign.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: _SettingsDesign.primaryGreen,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  void _showClearCacheDialog() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Clear Cache',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'This will clear all cached images and data. The app might load slower temporarily.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: _SettingsDesign.textSecondary),
                ),
              ),
              TextButton(
                onPressed: () {
                  HapticFeedback.heavyImpact();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Cache cleared'),
                      backgroundColor: _SettingsDesign.primaryGreen,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Clear',
                  style: TextStyle(
                    color: _SettingsDesign.danger,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _showClearAIHistoryDialog() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Clear AI History',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'This will permanently delete all your AI chat history. This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: _SettingsDesign.textSecondary),
                ),
              ),
              TextButton(
                onPressed: () {
                  HapticFeedback.heavyImpact();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('AI history cleared'),
                      backgroundColor: _SettingsDesign.primaryGreen,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Clear',
                  style: TextStyle(
                    color: _SettingsDesign.danger,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _showSignOutDialog() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _SettingsDesign.danger.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.logout_rounded,
                      color: _SettingsDesign.danger,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Sign Out?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _SettingsDesign.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Are you sure you want to sign out of your account?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: _SettingsDesign.textSecondary,
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
                            side: BorderSide(color: _SettingsDesign.divider),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: _SettingsDesign.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            await TokenManager.deleteToken();
                            await TokenManager.deleteUserId();
                            await TokenManager.deleteUserRole();

                            if (context.mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                                (route) => false,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _SettingsDesign.danger,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Sign Out',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
