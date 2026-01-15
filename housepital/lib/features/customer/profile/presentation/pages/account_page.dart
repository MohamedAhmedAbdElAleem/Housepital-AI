import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/network/api_service.dart';
import '../../../../auth/data/models/user_model.dart';
import '../../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../../auth/data/datasources/auth_remote_datasource.dart';
import '../../../../auth/data/datasources/cloudinary_service.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Modern Design System - Clean & Minimal
// ═══════════════════════════════════════════════════════════════════════════════
class _Design {
  // Primary Palette
  static const Color primary = Color(0xFF2ECC71);
  static const Color primaryLight = Color(0xFF58D68D);

  // Accent Colors
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color danger = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);

  // Neutrals
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color border = Color(0xFFE2E8F0);

  // Text
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);

  // Gradient
  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF2ECC71), Color(0xFF27AE60), Color(0xFF1E8449)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}

// ═══════════════════════════════════════════════════════════════════════════════
// Account Page
// ═══════════════════════════════════════════════════════════════════════════════
class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage>
    with SingleTickerProviderStateMixin {
  // Data
  UserModel? _user;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingImage = false;

  // Animation
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _mobileController;
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  // Focus
  final _nameFocus = FocusNode();
  final _mobileFocus = FocusNode();

  // Form
  final _formKey = GlobalKey<FormState>();

  // State
  bool _hasChanges = false;
  bool _showPasswordSection = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _initAnimation();
    _loadUserData();
  }

  void _initControllers() {
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _mobileController = TextEditingController();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    _nameController.addListener(_checkChanges);
    _mobileController.addListener(_checkChanges);
  }

  void _initAnimation() {
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocus.dispose();
    _mobileFocus.dispose();
    super.dispose();
  }

  void _checkChanges() {
    if (_user == null) return;
    final hasChanges =
        _nameController.text.trim() != (_user?.name ?? '') ||
        _mobileController.text.trim() != (_user?.mobile ?? '');
    if (hasChanges != _hasChanges) {
      setState(() => _hasChanges = hasChanges);
    }
  }

  Future<void> _loadUserData() async {
    try {
      final apiService = ApiService();
      final authDataSource = AuthRemoteDataSourceImpl(apiService: apiService);
      final authRepo = AuthRepositoryImpl(remoteDataSource: authDataSource);
      final response = await authRepo.getCurrentUser();
      final user = response.user;

      if (mounted) {
        setState(() {
          _user = user;
          _nameController.text = user?.name ?? '';
          _emailController.text = user?.email ?? '';
          _mobileController.text = user?.mobile ?? '';
          _isLoading = false;
        });
        _animController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Failed to load profile');
      }
    }
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Build Methods
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Design.background,
      body: _isLoading ? _buildLoading() : _buildContent(),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _Design.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: _Design.primary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Loading your profile...',
            style: TextStyle(color: _Design.textSecondary, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),
                _buildProfileCard(),
                const SizedBox(height: 24),
                _buildInfoSection(),
                const SizedBox(height: 24),
                _buildSecuritySection(),
                const SizedBox(height: 24),
                _buildAccountInfo(),
                if (_hasChanges) ...[
                  const SizedBox(height: 32),
                  _buildSaveButton(),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // App Bar
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: _Design.primary,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        onPressed: () {
          if (_hasChanges) {
            _showDiscardDialog();
          } else {
            Navigator.pop(context);
          }
        },
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: const Text(
          'My Account',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: 0.3,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(gradient: _Design.headerGradient),
          child: Stack(
            children: [
              // Decorative elements
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -50,
                left: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Profile Card - Avatar & Verification Status
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildProfileCard() {
    return Container(
      decoration: BoxDecoration(
        color: _Design.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: _Design.softShadow,
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          _buildAvatar(),
          const SizedBox(height: 16),
          Text(
            _user?.name ?? 'User',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _Design.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _user?.email ?? '',
            style: const TextStyle(fontSize: 14, color: _Design.textSecondary),
          ),
          const SizedBox(height: 20),
          _buildVerificationBadge(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final hasImage =
        _user?.profileImage != null && _user!.profileImage!.isNotEmpty;

    return Stack(
      children: [
        // Avatar Container
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                _Design.primary.withOpacity(0.2),
                _Design.primaryLight.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: _Design.primary.withOpacity(0.3),
              width: 3,
            ),
          ),
          child: ClipOval(
            child:
                _isUploadingImage
                    ? Container(
                      color: _Design.surfaceVariant,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: _Design.primary,
                          strokeWidth: 2.5,
                        ),
                      ),
                    )
                    : hasImage
                    ? CachedNetworkImage(
                      imageUrl: _user!.profileImage!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _buildAvatarPlaceholder(),
                      errorWidget: (_, __, ___) => _buildAvatarPlaceholder(),
                    )
                    : _buildAvatarPlaceholder(),
          ),
        ),

        // Camera Button
        Positioned(
          bottom: 4,
          right: 4,
          child: GestureDetector(
            onTap: _showImagePickerSheet,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _Design.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: _Design.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      color: _Design.primary.withOpacity(0.1),
      child: Center(
        child: Text(
          _getInitials(_user?.name),
          style: const TextStyle(
            color: _Design.primary,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationBadge() {
    final isVerified = _user?.isVerified ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isVerified ? _Design.successLight : _Design.warningLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              isVerified
                  ? _Design.success.withOpacity(0.3)
                  : _Design.warning.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isVerified ? Icons.verified_rounded : Icons.warning_amber_rounded,
            color: isVerified ? _Design.success : _Design.warning,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            isVerified ? 'Verified Account' : 'Verification Pending',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isVerified ? _Design.success : _Design.warning,
            ),
          ),
          if (!isVerified) ...[
            const Spacer(),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                backgroundColor: _Design.warning.withOpacity(0.15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Verify Now',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _Design.warning,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Info Section - Always Editable Fields
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildInfoSection() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            'Personal Information',
            Icons.person_outline_rounded,
          ),
          const SizedBox(height: 16),
          _buildEditableCard([
            _buildTextField(
              controller: _nameController,
              focusNode: _nameFocus,
              label: 'Full Name',
              icon: Icons.badge_outlined,
              hint: 'Enter your full name',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name is required';
                }
                if (value.trim().length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
            ),
            _buildDivider(),
            _buildTextField(
              controller: _emailController,
              label: 'Email Address',
              icon: Icons.email_outlined,
              readOnly: true,
              suffixWidget: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _Design.surfaceVariant,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Cannot change',
                  style: TextStyle(fontSize: 11, color: _Design.textMuted),
                ),
              ),
            ),
            _buildDivider(),
            _buildTextField(
              controller: _mobileController,
              focusNode: _mobileFocus,
              label: 'Mobile Number',
              icon: Icons.phone_outlined,
              hint: 'Enter your mobile number',
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _Design.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: _Design.primary),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: _Design.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildEditableCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: _Design.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: _Design.softShadow,
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    FocusNode? focusNode,
    String? hint,
    bool readOnly = false,
    Widget? suffixWidget,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _Design.textSecondary,
                ),
              ),
              if (suffixWidget != null) ...[const Spacer(), suffixWidget],
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            readOnly: readOnly,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            validator: validator,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: readOnly ? _Design.textMuted : _Design.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: _Design.textMuted,
                fontSize: 14,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 14, right: 10),
                child: Icon(
                  icon,
                  color: readOnly ? _Design.textMuted : _Design.primary,
                  size: 22,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 50),
              filled: true,
              fillColor: readOnly ? _Design.surfaceVariant : _Design.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: _Design.border.withOpacity(0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _Design.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _Design.danger),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _Design.danger, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: _Design.border.withOpacity(0.5)),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Security Section - Password Change
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildSecuritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Security', Icons.shield_outlined),
        const SizedBox(height: 16),
        _buildEditableCard([
          // Password Display Row
          _buildSecurityItem(
            icon: Icons.lock_outline_rounded,
            title: 'Password',
            subtitle: '••••••••••',
            trailing: TextButton.icon(
              onPressed: () {
                HapticFeedback.selectionClick();
                setState(() => _showPasswordSection = !_showPasswordSection);
              },
              icon: Icon(
                _showPasswordSection ? Icons.close : Icons.edit_outlined,
                size: 18,
                color: _Design.info,
              ),
              label: Text(
                _showPasswordSection ? 'Cancel' : 'Change',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _Design.info,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                backgroundColor: _Design.infoLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          // Password Change Form
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildPasswordChangeForm(),
            crossFadeState:
                _showPasswordSection
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ]),
      ],
    );
  }

  Widget _buildSecurityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _Design.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: _Design.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _Design.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: _Design.textSecondary,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildPasswordChangeForm() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _Design.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _Design.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create a strong password',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _Design.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'At least 6 characters with letters and numbers',
            style: TextStyle(fontSize: 12, color: _Design.textSecondary),
          ),
          const SizedBox(height: 16),

          // Current Password
          _buildPasswordField(
            controller: _currentPasswordController,
            label: 'Current Password',
            obscure: _obscureCurrentPassword,
            onToggle:
                () => setState(
                  () => _obscureCurrentPassword = !_obscureCurrentPassword,
                ),
          ),
          const SizedBox(height: 12),

          // New Password
          _buildPasswordField(
            controller: _newPasswordController,
            label: 'New Password',
            obscure: _obscureNewPassword,
            onToggle:
                () =>
                    setState(() => _obscureNewPassword = !_obscureNewPassword),
          ),
          const SizedBox(height: 12),

          // Confirm Password
          _buildPasswordField(
            controller: _confirmPasswordController,
            label: 'Confirm New Password',
            obscure: _obscureConfirmPassword,
            onToggle:
                () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
                ),
          ),
          const SizedBox(height: 20),

          // Update Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _changePassword,
              icon: const Icon(Icons.lock_reset_rounded, size: 20),
              label: const Text(
                'Update Password',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _Design.info,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(fontSize: 15, color: _Design.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14, color: _Design.textSecondary),
        prefixIcon: const Icon(
          Icons.lock_outline,
          color: _Design.info,
          size: 20,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: _Design.textMuted,
            size: 20,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: _Design.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _Design.border.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _Design.info, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Account Info - Read Only Details
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildAccountInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Account Details', Icons.info_outline_rounded),
        const SizedBox(height: 16),
        _buildEditableCard([
          _buildInfoRow(
            icon: Icons.fingerprint_rounded,
            label: 'User ID',
            value: _user?.id.substring(0, 12) ?? 'N/A',
            valueStyle: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              color: _Design.textSecondary,
            ),
          ),
          _buildDivider(),
          _buildInfoRow(
            icon: Icons.account_circle_outlined,
            label: 'Account Type',
            value: (_user?.role ?? 'customer').toUpperCase(),
            valueColor: _Design.info,
          ),
          _buildDivider(),
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Member Since',
            value: _formatDate(_user?.createdAt),
          ),
          _buildDivider(),
          _buildInfoRow(
            icon: Icons.update_rounded,
            label: 'Last Updated',
            value: _formatDate(_user?.updatedAt),
          ),
        ]),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    TextStyle? valueStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _Design.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _Design.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _Design.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style:
                      valueStyle ??
                      TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: valueColor ?? _Design.textPrimary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Save Button - Floating Action
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildSaveButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: _Design.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          elevation: 4,
          shadowColor: _Design.primary.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child:
            _isSaving
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
                : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 22),
                    SizedBox(width: 10),
                    Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Image Picker
  // ═══════════════════════════════════════════════════════════════════════════
  void _showImagePickerSheet() {
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
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                const Text(
                  'Update Profile Photo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _Design.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),

                // Options
                Row(
                  children: [
                    Expanded(
                      child: _buildImageOption(
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
                      child: _buildImageOption(
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

                // Remove Option
                if (_user?.profileImage != null &&
                    _user!.profileImage!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _removeProfileImage();
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        color: _Design.danger,
                      ),
                      label: const Text(
                        'Remove Photo',
                        style: TextStyle(color: _Design.danger),
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

  Widget _buildImageOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: _Design.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _Design.primary.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: _Design.primary),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _Design.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // API Actions
  // ═══════════════════════════════════════════════════════════════════════════
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

      setState(() => _isUploadingImage = true);

      final file = File(pickedFile.path);
      final apiService = ApiService();
      final cloudinaryService = CloudinaryService(apiService: apiService);

      final result = await cloudinaryService.uploadFile(
        file,
        folder: CloudinaryFolder.profiles,
      );

      if (result.success && result.url != null) {
        await _updateProfileImage(result.url!);
      } else {
        _showError(result.error ?? 'Failed to upload image');
      }
    } catch (e) {
      _showError('Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _updateProfileImage(String imageUrl) async {
    try {
      final apiService = ApiService();
      final response = await apiService.put(
        '/api/user/update-profile-image',
        body: {'profilePictureUrl': imageUrl},
      );

      if (response['success'] == true) {
        HapticFeedback.heavyImpact();
        setState(() => _user = _user?.copyWith(profileImage: imageUrl));
        _showSuccess('Profile photo updated!');
      } else {
        _showError(response['message'] ?? 'Failed to update');
      }
    } catch (e) {
      _showError('Error: ${e.toString()}');
    }
  }

  Future<void> _removeProfileImage() async {
    setState(() => _isUploadingImage = true);

    try {
      final apiService = ApiService();
      final response = await apiService.put(
        '/api/user/update-profile-image',
        body: {'profilePictureUrl': ''},
      );

      if (response['success'] == true) {
        HapticFeedback.heavyImpact();
        setState(() => _user = _user?.copyWith(profileImage: null));
        _showSuccess('Profile photo removed');
      } else {
        _showError(response['message'] ?? 'Failed to remove');
      }
    } catch (e) {
      _showError('Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);

    try {
      final apiService = ApiService();
      final response = await apiService.put(
        '/api/user/update-profile',
        body: {
          'name': _nameController.text.trim(),
          'mobile': _mobileController.text.trim(),
        },
      );

      if (mounted) {
        setState(() => _isSaving = false);

        if (response['success'] == true) {
          HapticFeedback.heavyImpact();
          setState(() {
            _user = _user?.copyWith(
              name: _nameController.text.trim(),
              mobile: _mobileController.text.trim(),
            );
            _hasChanges = false;
          });
          _showSuccess('Profile updated successfully!');
        } else {
          _showError(response['message'] ?? 'Failed to update');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        _showError('Error: ${e.toString()}');
      }
    }
  }

  Future<void> _changePassword() async {
    // Validation
    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showError('Please fill all password fields');
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match');
      return;
    }

    // Minimum 6 characters
    if (_newPasswordController.text.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }

    HapticFeedback.mediumImpact();

    try {
      final apiService = ApiService();
      final response = await apiService.put(
        '/api/user/change-password',
        body: {
          'currentPassword': _currentPasswordController.text,
          'newPassword': _newPasswordController.text,
        },
      );

      if (response['success'] == true) {
        HapticFeedback.heavyImpact();
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        setState(() => _showPasswordSection = false);
        _showSuccess('Password changed successfully!');
      } else {
        _showError(response['message'] ?? 'Failed to change password');
      }
    } catch (e) {
      _showError('Error: ${e.toString()}');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Dialogs & Snackbars
  // ═══════════════════════════════════════════════════════════════════════════
  void _showDiscardDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Discard Changes?'),
            content: const Text(
              'You have unsaved changes. Are you sure you want to go back?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _Design.danger,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Discard'),
              ),
            ],
          ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: _Design.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: _Design.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
