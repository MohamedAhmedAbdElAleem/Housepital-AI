import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/network/api_service.dart';
import '../../../../../core/providers/notification_provider.dart';
import '../../../../../core/utils/token_manager.dart';
import '../../../../auth/data/datasources/auth_remote_datasource.dart';
import '../../../../auth/data/datasources/cloudinary_service.dart';
import '../../../../auth/data/models/user_model.dart';
import '../../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../../auth/presentation/pages/login_page.dart';
import '../../../../notifications/presentation/pages/notifications_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../widgets/menu_grid.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_qr_card.dart';
import '../widgets/profile_shimmer.dart';
import '../widgets/quick_stats.dart';
import 'account_page.dart';
import 'family_page.dart';
import 'medical_records_page.dart';
import 'saved_addresses_page.dart';
import 'subscription_page.dart';
import 'verify_account_page.dart';
import 'wallet_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserModel? _user;
  bool _isLoading = true;
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData({bool isRefresh = false}) async {
    if (isRefresh) {
      HapticFeedback.lightImpact();
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _isPremium = (prefs.getString('subscription_plan') ?? 'basic') == 'premium';
        });
      }
    } catch (e) {
      debugPrint('❌ Prefs Error: $e');
    }
    
    try {
      final apiService = ApiService();
      final remoteDataSource = AuthRemoteDataSourceImpl(apiService: apiService);
      final repository = AuthRepositoryImpl(remoteDataSource: remoteDataSource);

      final response = await repository.getCurrentUser();

      if (mounted && response.user != null) {
        setState(() {
          _user = response.user;
          _isLoading = false;
        });
        return;
      }
    } catch (e) {
      debugPrint('❌ API Error: $e');
    }

    // Fallback: Get user data from JWT token
    try {
      final tokenData = await TokenManager.getUserFromToken();
      if (tokenData != null && mounted) {
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
        return;
      }
    } catch (e) {
      debugPrint('❌ Token Error: $e');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showQRCodeBottomSheet() {
    if (_user == null) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProfileQRCard(
        userId: _user!.id,
        userName: _user!.name,
        userEmail: _user!.email,
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

      _showLoadingDialog(message: 'Uploading...');

      final file = File(pickedFile.path);
      final apiService = ApiService();
      final cloudinaryService = CloudinaryService(apiService: apiService);

      final result = await cloudinaryService.uploadFile(
        file,
        folder: CloudinaryFolder.profiles,
      );

      if (mounted) Navigator.pop(context);

      if (result.success && result.url != null) {
        await _updateProfileImageOnServer(result.url!);
      } else {
        if (mounted) _showSnackBar(result.error ?? 'Failed to upload', isError: true);
      }
    } catch (e) {
      if (mounted) {
        if (Navigator.canPop(context)) Navigator.pop(context);
        _showSnackBar('Error: ${e.toString()}', isError: true);
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
        _showSnackBar('Profile photo updated!');
      } else {
        _showSnackBar(response['message'] ?? 'Failed to update', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}', isError: true);
    }
  }

  void _showLoadingDialog({required String message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Text(message),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : AppColors.primary500,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF16151A) : null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Sign Out',
            style: TextStyle(
              color: isDark ? const Color(0xFFF2F2F5) : null,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to sign out?',
            style: TextStyle(
              color: isDark ? const Color(0xFFA19EAB) : null,
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sign Out', style: TextStyle(color: Colors.red))),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      await TokenManager.deleteToken();
      await Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Afternoon 🌤️';
    return 'Good Evening 🌙';
  }

  void _showSupportOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.phone_outlined, color: AppColors.primary500),
              title: const Text('Call Us'),
              onTap: () => _launchURL('tel:+201234567890'),
            ),
            ListTile(
              leading: const Icon(Icons.email_outlined, color: AppColors.primary500),
              title: const Text('Email Support'),
              onTap: () => _launchURL('mailto:support@housepital.com'),
            ),
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary500),
              title: const Text('Live Chat'),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('Connecting to agent...');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showSnackBar('Could not launch $url', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const ProfileShimmer();

    final notificationProvider = context.watch<NotificationProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () => _loadUserData(isRefresh: true),
        color: AppColors.primary500,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverToBoxAdapter(
              child: ProfileHeader(
                name: _user?.name,
                email: _user?.email,
                profileImage: _user?.profileImage,
                initials: _user != null && _user!.name.isNotEmpty ? _user!.name[0] : 'U',
                greeting: _getGreeting(),
                isVerified: _user?.isVerified ?? false,
                isPremium: _isPremium,
                unreadNotifications: notificationProvider.unreadCount,
                onNotificationTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage())),
                onQRTap: _showQRCodeBottomSheet,
                onEditPhotoTap: () => _pickImage(ImageSource.gallery),
              ),
            ),
            SliverToBoxAdapter(
              child: QuickStats(
                visits: _user?.totalVisits ?? 0,
                balance: _user?.wallet ?? 0.0,
                rating: 4.9, // Hardcoded as requested to be connected later
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 20.0),
                child: MenuGrid(
                  items: [
                    MenuItemData(
                      icon: Icons.person_outline_rounded,
                      title: 'My Account',
                      subtitle: 'Personal info & security',
                      gradient: [const Color(0xFF0891B2), const Color(0xFF0E7490)],
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountPage())),
                    ),
                    MenuItemData(
                      icon: Icons.wallet_rounded,
                      title: 'Payments',
                      subtitle: 'Wallet & transactions',
                      gradient: [const Color(0xFF059669), const Color(0xFF047857)],
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletPage())),
                    ),
                    MenuItemData(
                      icon: Icons.family_restroom_rounded,
                      title: 'Family',
                      subtitle: 'Manage dependents',
                      gradient: [const Color(0xFF7C3AED), const Color(0xFF6D28D9)],
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FamilyPage())),
                    ),
                    MenuItemData(
                      icon: Icons.location_on_rounded,
                      title: 'Addresses',
                      subtitle: 'Saved locations',
                      gradient: [const Color(0xFFEA580C), const Color(0xFFC2410C)],
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedAddressesPage())),
                    ),
                    MenuItemData(
                      icon: Icons.history_edu_rounded,
                      title: 'Records',
                      subtitle: 'Medical history',
                      gradient: [const Color(0xFFEF4444), const Color(0xFFB91C1C)],
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicalRecordsPage())),
                    ),
                    MenuItemData(
                      icon: Icons.workspace_premium_rounded,
                      title: 'Premium',
                      subtitle: 'Special benefits',
                      isPremium: true,
                      gradient: [const Color(0xFFF59E0B), const Color(0xFFD97706)],
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SubscriptionPage(user: _user))).then((_) => _loadUserData()),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      icon: Icons.settings_outlined,
                      title: 'Settings',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage())),
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsTile(
                      icon: Icons.help_outline_rounded,
                      title: 'Help & Support',
                      onTap: _showSupportOptions,
                    ),
                    const SizedBox(height: 30),
                    _buildSignOutButton(),
                    const SizedBox(height: 40),
                    Text(
                      'Housepital v1.0.0',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({required IconData icon, required String title, required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1C24) : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
          border: isDark ? Border.all(color: Colors.white.withAlpha(10)) : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: Theme.of(context).colorScheme.onSurface),
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey),
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
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Colors.red, size: 20),
            SizedBox(width: 12),
            Text(
              'Sign Out',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
