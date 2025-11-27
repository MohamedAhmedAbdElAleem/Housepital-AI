import 'package:flutter/material.dart';
import '../widgets/location_header.dart';
import '../widgets/greeting_search_card.dart';
import '../widgets/ai_assistant_card.dart';
import '../widgets/premium_card.dart';
import '../widgets/my_health_section.dart';
import '../widgets/service_tabs.dart';
import '../widgets/popular_services_grid.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../booking/presentation/pages/bookings_page.dart';
import '../../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../../auth/data/datasources/auth_remote_datasource.dart';
import '../../../../../core/network/api_service.dart';
import '../../../../../core/utils/token_manager.dart';
import '../../../../auth/data/models/user_model.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  int _currentIndex = 0;
  String _selectedTab = 'Home Nursing';
  UserModel? _user;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkUserId(); // Debug check
  }

  Future<void> _checkUserId() async {
    final userId = await TokenManager.getUserId();
    debugPrint('🔍 Home Page: Stored User ID: $userId');
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
          _isLoadingUser = false;
        });

        // Debug output
        debugPrint('🏠 Home: User data loaded');
        debugPrint('   Name: ${_user?.name}');
        debugPrint('   Email: ${_user?.email}');
        debugPrint('   ID: ${_user?.id}');
        debugPrint('   Verified: ${_user?.isVerified}');
        debugPrint('   Should show warning: ${_user?.isVerified == false}');

        // WORKAROUND: Save user ID if it's not already saved
        debugPrint('🔧 Checking if user ID needs to be saved...');
        final storedUserId = await TokenManager.getUserId();
        debugPrint('🔧 Stored User ID from SharedPrefs: $storedUserId');
        debugPrint('🔧 Current User ID from API: ${_user?.id}');

        if (_user?.id != null && _user!.id.isNotEmpty) {
          if (storedUserId == null || storedUserId.isEmpty) {
            debugPrint('⚠️ User ID not found in storage, saving now...');
            await TokenManager.saveUserId(_user!.id);
            debugPrint('✅ User ID saved successfully: ${_user!.id}');

            // Verify it was saved
            final verifyId = await TokenManager.getUserId();
            debugPrint('🔍 Verification - User ID now in storage: $verifyId');
          } else {
            debugPrint('✅ User ID already exists in storage: $storedUserId');
          }
        } else {
          debugPrint('❌ No user ID available from API response');
        }
      }
    } catch (e) {
      debugPrint('❌ Home: Error loading user data: $e');
      if (mounted) {
        setState(() {
          _isLoadingUser = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      // -------------------------------
      // ⭐ All content inside one ScrollView
      // -------------------------------
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -------------------------------
            // 🌿 Green Header Section
            // -------------------------------
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF17C47F), Color(0xFF14B374)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    children: [
                      const LocationHeader(),
                      const SizedBox(height: 20),
                      GreetingSearchCard(userName: _user?.name),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // -------------------------------
            // ⚠️ Verification Warning
            // -------------------------------
            if (!_isLoadingUser && _user?.isVerified == false)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
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
              ),
            if (!_isLoadingUser && _user?.isVerified == false)
              const SizedBox(height: 16),

            // -------------------------------
            // 🤖 AI Assistant Card
            // -------------------------------
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: AIAssistantCard(),
            ),

            const SizedBox(height: 16),

            // -------------------------------
            // ⭐ Premium Plan Card
            // -------------------------------
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: PremiumCard(),
            ),

            const SizedBox(height: 24),

            // -------------------------------
            // ❤️ My Health
            // -------------------------------
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: MyHealthSection(),
            ),

            const SizedBox(height: 24),

            // -------------------------------
            // 🔄 Service Tabs (Home Nursing / Clinics)
            // -------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ServiceTabs(
                selectedTab: _selectedTab,
                onTabChanged: (tab) {
                  setState(() {
                    _selectedTab = tab;
                  });
                },
              ),
            ),

            const SizedBox(height: 20),

            // -------------------------------
            // 🏥 Popular Services Grid
            // -------------------------------
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: PopularServicesGrid(),
            ),

            const SizedBox(height: 100), // space for bottom nav bar
          ],
        ),
      ),

      // -------------------------------
      // 📱 Bottom Navigation Bar
      // -------------------------------
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          // Navigate to Bookings page (index 1)
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BookingsPage()),
            ).then((_) {
              // Reset to Home tab when returning
              setState(() {
                _currentIndex = 0;
              });
            });
          }

          // Navigate to Profile page when Profile tab is tapped
          if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            ).then((_) {
              // Reset to Home tab when returning from Profile
              setState(() {
                _currentIndex = 0;
              });
            });
          }
        },
      ),
    );
  }
}
