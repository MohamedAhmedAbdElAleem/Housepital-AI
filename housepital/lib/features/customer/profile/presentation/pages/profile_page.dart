import 'package:flutter/material.dart';
import '../../../home/presentation/widgets/custom_bottom_nav_bar.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../../auth/data/datasources/auth_remote_datasource.dart';
import '../../../../../core/network/api_service.dart';
import '../../../../auth/data/models/user_model.dart';
import '../../../../../core/utils/token_manager.dart';
import '../../../../auth/presentation/pages/login_page.dart';
import '../../../booking/presentation/pages/bookings_page.dart';
import '../../../../../core/constants/app_colors.dart';
import 'family_page.dart';
import 'saved_addresses_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 4;
  UserModel? _user;
  bool _isLoading = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _loadUserData();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      debugPrint('📤 Loading user data from API...');
      final apiService = ApiService();
      final remoteDataSource = AuthRemoteDataSourceImpl(apiService: apiService);
      final repository = AuthRepositoryImpl(remoteDataSource: remoteDataSource);

      final response = await repository.getCurrentUser();

      debugPrint(
        '📥 Response: success=${response.success}, user=${response.user}',
      );

      if (mounted && response.user != null) {
        setState(() {
          _user = response.user;
          _isLoading = false;
        });
        _animController.forward();
        debugPrint(
          '🎯 User loaded from API: name=${_user?.name}, email=${_user?.email}',
        );
        return;
      }
    } catch (e) {
      debugPrint('❌ API Error: $e');
    }

    // Fallback: Get user data from JWT token
    try {
      debugPrint('🔄 Fallback: Loading user from JWT token...');
      final tokenData = await TokenManager.getUserFromToken();

      if (tokenData != null && mounted) {
        debugPrint('📦 Token data: $tokenData');
        setState(() {
          _user = UserModel(
            id: tokenData['id'] ?? '',
            name: tokenData['name'] ?? 'User',
            email: tokenData['email'] ?? '',
            mobile: '',
            role: tokenData['role'] ?? 'customer',
            isVerified: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          _isLoading = false;
        });
        _animController.forward();
        debugPrint(
          '🎯 User loaded from token: name=${_user?.name}, email=${_user?.email}',
        );
        return;
      }
    } catch (e) {
      debugPrint('❌ Token Error: $e');
    }

    // If all fails
    if (mounted) {
      setState(() => _isLoading = false);
      _animController.forward();
    }
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Sign Out'),
            content: const Text('Are you sure you want to sign out?'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Sign Out'),
              ),
            ],
          ),
    );

    if (confirmed == true && mounted) {
      await TokenManager.deleteToken();
      await TokenManager.deleteUserId();
      await TokenManager.deleteUserRole();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary500),
              const SizedBox(height: 16),
              Text(
                'Loading profile...',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(child: _buildHeader()),

            // Quick Stats
            SliverToBoxAdapter(child: _buildQuickStats()),

            // Menu Items
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Verification Warning
                  if (_user?.isVerified == false) ...[
                    _buildVerificationWarning(),
                    const SizedBox(height: 16),
                  ],

                  // Account Section
                  _buildSectionTitle('Account'),
                  const SizedBox(height: 12),
                  _buildMenuCard([
                    _buildMenuItem(
                      icon: Icons.person_outline,
                      title: 'Edit Profile',
                      subtitle: 'Update your personal information',
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.family_restroom,
                      title: 'My Family',
                      subtitle: 'Manage family members',
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FamilyPage(),
                            ),
                          ),
                    ),
                    _buildMenuItem(
                      icon: Icons.location_on_outlined,
                      title: 'Saved Addresses',
                      subtitle: 'Home, work, and more',
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SavedAddressesPage(),
                            ),
                          ),
                      showDivider: false,
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Services Section
                  _buildSectionTitle('Services'),
                  const SizedBox(height: 12),
                  _buildMenuCard([
                    _buildMenuItem(
                      icon: Icons.workspace_premium,
                      title: 'My Subscription',
                      subtitle: 'Premium member benefits',
                      iconColor: Colors.amber[700]!,
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Payments & Wallet',
                      subtitle: 'Manage payment methods',
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.folder_outlined,
                      title: 'Medical Records',
                      subtitle: 'View your health history',
                      onTap: () {},
                      showDivider: false,
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Support Section
                  _buildSectionTitle('Support'),
                  const SizedBox(height: 12),
                  _buildMenuCard([
                    _buildMenuItem(
                      icon: Icons.settings_outlined,
                      title: 'Settings',
                      subtitle: 'App preferences',
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsPage(),
                            ),
                          ),
                    ),
                    _buildMenuItem(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      subtitle: 'Get help, contact us',
                      onTap: () {},
                      showDivider: false,
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Sign Out
                  _buildSignOutButton(),

                  const SizedBox(height: 20),

                  // Version
                  Center(
                    child: Text(
                      'Housepital v1.0.0',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 0) {
            Navigator.pop(context);
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const BookingsPage()),
            );
          }
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary500,
            AppColors.primary500.withOpacity(0.85),
            const Color(0xFF0D9F6E),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            children: [
              // Top Row with Settings
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Avatar
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Text(
                    _getInitials(_user?.name),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Name
              Text(
                _user?.name ?? 'User',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 6),

              // Email
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.email_outlined,
                    color: Colors.white70,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _user?.email ?? 'email@example.com',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),

              if (_user?.mobile != null && _user!.mobile.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.phone_outlined,
                      color: Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '+20 ${_user!.mobile}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 16),

              // Verified Badge
              if (_user?.isVerified == true)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified, color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Verified Account',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Transform.translate(
      offset: const Offset(0, -16),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildStatItem(
              icon: Icons.medical_services_outlined,
              value: '${_user?.totalVisits ?? 0}',
              label: 'Visits',
              color: AppColors.primary500,
            ),
            _buildStatDivider(),
            _buildStatItem(
              icon: Icons.account_balance_wallet_outlined,
              value: '${_user?.wallet.toInt() ?? 0} EGP',
              label: 'Wallet',
              color: Colors.blue,
            ),
            _buildStatDivider(),
            _buildStatItem(
              icon: Icons.favorite_outline,
              value: '${_user?.savedServices ?? 0}',
              label: 'Saved',
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(height: 50, width: 1, color: const Color(0xFFE2E8F0));
  }

  Widget _buildVerificationWarning() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withOpacity(0.1),
            Colors.orange.withOpacity(0.05),
          ],
        ),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Verify Your Account',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Complete verification to access all features',
                  style: TextStyle(fontSize: 13, color: Colors.orange[700]),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.orange[400]),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF374151),
        ),
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    bool showDivider = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
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
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                      ),
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
            if (showDivider)
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 52),
                child: Divider(height: 1, color: Colors.grey[200]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignOutButton() {
    return InkWell(
      onTap: _signOut,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Colors.red[400], size: 22),
            const SizedBox(width: 10),
            Text(
              'Sign Out',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
