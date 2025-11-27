import 'package:flutter/material.dart';
import '../../../home/presentation/widgets/custom_bottom_nav_bar.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../../auth/data/datasources/auth_remote_datasource.dart';
import '../../../../../core/network/api_service.dart';
import '../../../../auth/data/models/user_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 4; // Profile tab is selected
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
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
        
        // Debug output
        debugPrint('🎯 User data loaded:');
        debugPrint('   Name: ${_user?.name}');
        debugPrint('   Email: ${_user?.email}');
        debugPrint('   Verified: ${_user?.isVerified}');
      }
    } catch (e) {
      debugPrint('❌ Error loading user data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF2ECC71),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Top Profile Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                child: Column(
                  children: [
                    // Avatar with badge
                    Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 4,
                            ),
                          ),
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.grey[600],
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFF3B82F6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.verified,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // User name
                    Text(
                      _user?.name ?? 'User',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Email
                    Text(
                      _user?.email ?? 'email@example.com',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Premium badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.workspace_premium,
                            size: 16,
                            color: Colors.amber[700],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'PREMIUM MEMBER',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Stats Card
          Transform.translate(
            offset: const Offset(0, -20),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '12',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2ECC71),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Visits',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 40,
                    width: 1,
                    color: const Color(0xFFE2E8F0),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '310 EGP',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2ECC71),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Wallet',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Profile Menu List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              children: [
                // Verification Warning
                if (_user?.isVerified == false) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      border: Border.all(color: const Color(0xFFEF4444)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.warning_rounded,
                            color: Color(0xFFEF4444),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Account Not Verified',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFEF4444),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Please verify your account to access all features',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.red[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: const Color(0xFFEF4444),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                _buildMenuItem(
                  icon: Icons.family_restroom,
                  title: 'My Family',
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                _buildMenuItem(
                  icon: Icons.location_on,
                  title: 'Saved Addresses',
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                _buildMenuItem(
                  icon: Icons.workspace_premium,
                  title: 'My Subscription',
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                _buildMenuItem(
                  icon: Icons.account_balance_wallet,
                  title: 'Payments',
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                _buildMenuItem(
                  icon: Icons.folder_open,
                  title: 'Medical Records',
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                _buildMenuItem(
                  icon: Icons.settings,
                  title: 'Settings',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildMenuItem(
                  icon: Icons.chat_bubble_outline,
                  title: 'Help & Support',
                  onTap: () {},
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          
          // Navigate back to home if Home tab is tapped
          if (index == 0) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
                color: const Color(0xFF2ECC71).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF2ECC71),
                size: 24,
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
}
