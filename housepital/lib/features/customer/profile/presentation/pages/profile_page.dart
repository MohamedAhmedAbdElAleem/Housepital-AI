import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../../home/presentation/widgets/custom_bottom_nav_bar.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../../auth/data/datasources/auth_remote_datasource.dart';
import '../../../../auth/data/datasources/cloudinary_service.dart';
import '../../../../../core/network/api_service.dart';
import '../../../../auth/data/models/user_model.dart';
import '../../../../../core/utils/token_manager.dart';
import '../../../../auth/presentation/pages/login_page.dart';
import '../../../booking/presentation/pages/bookings_page.dart';
import 'family_page.dart';
import 'saved_addresses_page.dart';
import 'account_page.dart';
import 'wallet_page.dart';
import 'subscription_page.dart';
import 'medical_records_page.dart';
import 'verify_account_page.dart';

// Design System Constants
class _ProfileDesign {
  static const Color primaryGreen = Color(0xFF00C853);
  static const Color surface = Color(0xFFF8FAFC);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color divider = Color(0xFFE2E8F0);

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static LinearGradient get headerGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00C853), Color(0xFF00B248), Color(0xFF009624)],
  );
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  int _currentIndex = 4;
  UserModel? _user;
  bool _isLoading = true;

  late AnimationController _animController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadUserData();
  }

  void _setupAnimations() {
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData({bool isRefresh = false}) async {
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
        if (!isRefresh) _animController.forward();
        HapticFeedback.lightImpact();
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
        if (!isRefresh) _animController.forward();
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
      setState(() {
        _isLoading = false;
      });
      if (!isRefresh) _animController.forward();
    }
  }

  Future<void> _showImagePickerSheet() async {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                const Text(
                  'Update Profile Photo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _ProfileDesign.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildImagePickerOption(
                        icon: Icons.camera_alt_rounded,
                        label: 'Camera',
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.camera);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildImagePickerOption(
                        icon: Icons.photo_library_rounded,
                        label: 'Gallery',
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.gallery);
                        },
                      ),
                    ),
                  ],
                ),
                if (_user?.profileImage != null) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _removeProfileImage();
                      },
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: const Text(
                        'Remove Photo',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }

  Widget _buildImagePickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: _ProfileDesign.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _ProfileDesign.primaryGreen.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: _ProfileDesign.primaryGreen),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _ProfileDesign.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      _showUploadingDialog();

      final file = File(pickedFile.path);
      final apiService = ApiService();
      final cloudinaryService = CloudinaryService(apiService: apiService);

      final result = await cloudinaryService.uploadFile(
        file,
        folder: CloudinaryFolder.profiles,
      );

      if (mounted) Navigator.pop(context); // Close uploading dialog

      if (result.success && result.url != null) {
        await _updateProfileImageOnServer(result.url!);
      } else {
        if (mounted) {
          _showErrorSnackBar(result.error ?? 'Failed to upload image');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showErrorSnackBar('Error: ${e.toString()}');
      }
    }
  }

  Future<void> _updateProfileImageOnServer(String imageUrl) async {
    try {
      final apiService = ApiService();
      final response = await apiService.put(
        '/api/user/update-profile-image',
        body: {'profilePictureUrl': imageUrl},
      );

      if (response['success'] == true) {
        HapticFeedback.heavyImpact();
        setState(() {
          _user = _user?.copyWith(profileImage: imageUrl);
        });
        _showSuccessSnackBar('Profile photo updated!');
      } else {
        _showErrorSnackBar(response['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }

  Future<void> _removeProfileImage() async {
    try {
      _showUploadingDialog(message: 'Removing photo...');

      final apiService = ApiService();
      final response = await apiService.put(
        '/api/user/update-profile-image',
        body: {'profilePictureUrl': ''},
      );

      if (mounted) Navigator.pop(context);

      if (response['success'] == true) {
        HapticFeedback.heavyImpact();
        setState(() {
          _user = _user?.copyWith(profileImage: null);
        });
        _showSuccessSnackBar('Profile photo removed');
      } else {
        _showErrorSnackBar(response['message'] ?? 'Failed to remove photo');
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }

  void _showUploadingDialog({String message = 'Uploading...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    color: _ProfileDesign.primaryGreen,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: _ProfileDesign.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _signOut() async {
    HapticFeedback.mediumImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _buildSignOutDialog(),
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

  Widget _buildSignOutDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                color: _ProfileDesign.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Are you sure you want to sign out of your account?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
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
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: _ProfileDesign.surface,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder:
                    (context, child) => Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _ProfileDesign.primaryGreen.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: CircularProgressIndicator(
                          color: _ProfileDesign.primaryGreen,
                          strokeWidth: 3,
                        ),
                      ),
                    ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Loading your profile...',
                style: TextStyle(
                  color: _ProfileDesign.textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _ProfileDesign.surface,
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder:
            (context, child) => Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: RefreshIndicator(
                  onRefresh: () => _loadUserData(isRefresh: true),
                  color: _ProfileDesign.primaryGreen,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      // Header
                      SliverToBoxAdapter(child: _buildHeader()),

                      // Quick Stats
                      SliverToBoxAdapter(child: _buildQuickStats()),

                      // Menu Items
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            // Verification Warning
                            if (_user?.isVerified == false) ...[
                              _buildVerificationWarning(),
                              const SizedBox(height: 20),
                            ],

                            // Account Section
                            _buildSectionTitle('Account', Icons.person_outline),
                            const SizedBox(height: 12),
                            _buildMenuCard([
                              _buildMenuItem(
                                icon: Icons.account_circle_outlined,
                                title: 'My Account',
                                subtitle: 'Profile, personal info, security',
                                gradient: [
                                  const Color(0xFF3B82F6),
                                  const Color(0xFF2563EB),
                                ],
                                onTap: () async {
                                  HapticFeedback.lightImpact();
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const AccountPage(),
                                    ),
                                  );
                                  if (result == true) {
                                    _loadUserData(isRefresh: true);
                                  }
                                },
                              ),
                              _buildMenuItem(
                                icon: Icons.family_restroom_rounded,
                                title: 'My Family',
                                subtitle: 'Manage family members',
                                gradient: [
                                  const Color(0xFF8B5CF6),
                                  const Color(0xFF7C3AED),
                                ],
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const FamilyPage(),
                                    ),
                                  );
                                },
                              ),
                              _buildMenuItem(
                                icon: Icons.location_on_rounded,
                                title: 'Saved Addresses',
                                subtitle: 'Home, work, and more',
                                gradient: [
                                  const Color(0xFFF59E0B),
                                  const Color(0xFFD97706),
                                ],
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              const SavedAddressesPage(),
                                    ),
                                  );
                                },
                                showDivider: false,
                              ),
                            ]),

                            const SizedBox(height: 24),

                            // Services Section
                            _buildSectionTitle(
                              'Services',
                              Icons.medical_services_outlined,
                            ),
                            const SizedBox(height: 12),
                            _buildMenuCard([
                              _buildMenuItem(
                                icon: Icons.workspace_premium_rounded,
                                title: 'My Subscription',
                                subtitle: 'Premium member benefits',
                                gradient: [
                                  const Color(0xFFF59E0B),
                                  const Color(0xFFEAB308),
                                ],
                                isPremium: true,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              SubscriptionPage(user: _user),
                                    ),
                                  );
                                },
                              ),
                              _buildMenuItem(
                                icon: Icons.account_balance_wallet_rounded,
                                title: 'Payments & Wallet',
                                subtitle: 'Manage payment methods',
                                gradient: [
                                  const Color(0xFF10B981),
                                  const Color(0xFF059669),
                                ],
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => WalletPage(user: _user),
                                    ),
                                  );
                                },
                              ),
                              _buildMenuItem(
                                icon: Icons.folder_shared_rounded,
                                title: 'Medical Records',
                                subtitle: 'View your health history',
                                gradient: [
                                  const Color(0xFFEF4444),
                                  const Color(0xFFDC2626),
                                ],
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              const MedicalRecordsPage(),
                                    ),
                                  );
                                },
                                showDivider: false,
                              ),
                            ]),

                            const SizedBox(height: 24),

                            // Support Section
                            _buildSectionTitle(
                              'Support',
                              Icons.support_agent_rounded,
                            ),
                            const SizedBox(height: 12),
                            _buildMenuCard([
                              _buildMenuItem(
                                icon: Icons.settings_rounded,
                                title: 'Settings',
                                subtitle: 'App preferences',
                                gradient: [
                                  const Color(0xFF6B7280),
                                  const Color(0xFF4B5563),
                                ],
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const SettingsPage(),
                                    ),
                                  );
                                },
                              ),
                              _buildMenuItem(
                                icon: Icons.help_center_rounded,
                                title: 'Help & Support',
                                subtitle: 'Get help, contact us',
                                gradient: [
                                  const Color(0xFF06B6D4),
                                  const Color(0xFF0891B2),
                                ],
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  _showHelpBottomSheet();
                                },
                                showDivider: false,
                              ),
                            ]),

                            const SizedBox(height: 28),

                            // Sign Out
                            _buildSignOutButton(),

                            const SizedBox(height: 24),

                            // Version & App Info
                            _buildAppInfo(),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          HapticFeedback.lightImpact();
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

  void _showHelpBottomSheet() {
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
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'How can we help?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _ProfileDesign.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                _buildHelpOption(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'Live Chat',
                  subtitle: 'Chat with our support team',
                  onTap: () => Navigator.pop(context),
                ),
                _buildHelpOption(
                  icon: Icons.phone_outlined,
                  title: 'Call Us',
                  subtitle: '+20 123 456 7890',
                  onTap: () => Navigator.pop(context),
                ),
                _buildHelpOption(
                  icon: Icons.email_outlined,
                  title: 'Email Support',
                  subtitle: 'support@housepital.com',
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }

  Widget _buildHelpOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _ProfileDesign.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: _ProfileDesign.primaryGreen, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[600], fontSize: 13),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: _ProfileDesign.headerGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
        boxShadow: [
          BoxShadow(
            color: _ProfileDesign.primaryGreen.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 56),
          child: Column(
            children: [
              // Top Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'My Profile',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildHeaderButton(
                        icon: Icons.notifications_outlined,
                        onTap: () {
                          HapticFeedback.lightImpact();
                        },
                        hasNotification: true,
                      ),
                      const SizedBox(width: 8),
                      _buildHeaderButton(
                        icon: Icons.qr_code_rounded,
                        onTap: () {
                          HapticFeedback.lightImpact();
                        },
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Avatar with Status Indicator
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 52,
                      backgroundColor: Colors.white,
                      child:
                          _user?.profileImage != null &&
                                  _user!.profileImage!.isNotEmpty
                              ? ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: _user!.profileImage!,
                                  width: 104,
                                  height: 104,
                                  fit: BoxFit.cover,
                                  placeholder:
                                      (context, url) => Container(
                                        width: 104,
                                        height: 104,
                                        color: Colors.grey[100],
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: _ProfileDesign.primaryGreen,
                                          ),
                                        ),
                                      ),
                                  errorWidget:
                                      (context, url, error) => Text(
                                        _getInitials(_user?.name),
                                        style: TextStyle(
                                          fontSize: 38,
                                          fontWeight: FontWeight.bold,
                                          color: _ProfileDesign.primaryGreen,
                                        ),
                                      ),
                                ),
                              )
                              : Text(
                                _getInitials(_user?.name),
                                style: TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.bold,
                                  color: _ProfileDesign.primaryGreen,
                                ),
                              ),
                    ),
                  ),
                  // Edit Avatar Button
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: () {
                        _showImagePickerSheet();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.camera_alt_rounded,
                          color: _ProfileDesign.primaryGreen,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  // Online Status
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Name
              Text(
                _user?.name ?? 'User',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),

              const SizedBox(height: 8),

              // Contact Info
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.email_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _user?.email ?? 'email@example.com',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              if (_user?.mobile != null && _user!.mobile.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.phone_rounded,
                      color: Colors.white.withOpacity(0.8),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '+20 ${_user!.mobile}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 14),

              // Verified Badge
              if (_user?.isVerified == true)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.25),
                        Colors.white.withOpacity(0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: _ProfileDesign.primaryGreen,
                          size: 12,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Verified Account',
                        style: TextStyle(
                          fontSize: 12,
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

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
    bool hasNotification = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          if (hasNotification)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildStatItem(
              icon: Icons.calendar_month_rounded,
              value: '${_user?.totalVisits ?? 0}',
              label: 'Visits',
              color: _ProfileDesign.primaryGreen,
            ),
            _buildStatDivider(),
            _buildStatItem(
              icon: Icons.account_balance_wallet_rounded,
              value: '${_user?.wallet.toInt() ?? 0}',
              label: 'EGP Balance',
              color: const Color(0xFF3B82F6),
            ),
            _buildStatDivider(),
            _buildStatItem(
              icon: Icons.star_rounded,
              value: '4.9',
              label: 'Rating',
              color: const Color(0xFFF59E0B),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withOpacity(0.15), color.withOpacity(0.08)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: _ProfileDesign.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 55,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            _ProfileDesign.divider,
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationWarning() {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.mediumImpact();
        debugPrint('🔍 Verify button tapped');

        if (_user?.email == null || _user!.email.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 10),
                  Text('Email not found. Please update your profile.'),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          return;
        }

        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyAccountPage(email: _user!.email),
          ),
        );

        if (result == true) {
          debugPrint('✅ Verification successful, reloading user data');
          _loadUserData(isRefresh: true);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.orange.withOpacity(0.12),
              Colors.amber.withOpacity(0.08),
            ],
          ),
          border: Border.all(color: Colors.orange.withOpacity(0.3), width: 1.5),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.withOpacity(0.2),
                    Colors.amber.withOpacity(0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.shield_outlined,
                color: Colors.orange,
                size: 26,
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEA580C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to verify and unlock all features',
                    style: TextStyle(fontSize: 13, color: Colors.orange[700]),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _ProfileDesign.textSecondary),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _ProfileDesign.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: _ProfileDesign.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required List<Color> gradient,
    bool showDivider = true,
    bool isPremium = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: gradient,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: gradient[0].withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: _ProfileDesign.textPrimary,
                              ),
                            ),
                            if (isPremium) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.amber[600]!,
                                      Colors.orange[400]!,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'PRO',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            color: _ProfileDesign.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              if (showDivider)
                Padding(
                  padding: const EdgeInsets.only(top: 16, left: 58),
                  child: Divider(height: 1, color: Colors.grey[100]),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignOutButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _signOut,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.red.withOpacity(0.08),
                Colors.red.withOpacity(0.04),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.red.withOpacity(0.2), width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Sign Out',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppInfo() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _ProfileDesign.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.favorite_rounded,
                color: _ProfileDesign.primaryGreen,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Made with love for your health',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Housepital v1.0.0',
          style: TextStyle(color: Colors.grey[400], fontSize: 11),
        ),
      ],
    );
  }
}
