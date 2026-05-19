import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/widgets/custom_popup.dart';
import '../../../../core/utils/token_manager.dart';
import '../../../../core/providers/notification_provider.dart';
import '../../../../core/services/biometric_service.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/models/login_request.dart';

import '../../../../generated/l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  // Form state
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;

  // Biometric state
  final _biometricService = BiometricService();
  bool _isBiometricEnabled = false;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  // Animation controllers
  late AnimationController _mainController;
  late AnimationController _floatingController;
  late AnimationController _pulseController;
  late AnimationController _shakeController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shakeAnimation;

  late final AuthRepositoryImpl _authRepository;
  @override
  void initState() {
    debugPrint('🧪 LoginPage: initState started');
    super.initState();
    _initRepository();
    _initAnimations();
    _initFocusListeners();
    _loadSavedCredentials();
    _checkBiometrics();
    debugPrint('🧪 LoginPage: initState finished');
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  void _initRepository() {
    final apiService = ApiService();
    final remoteDataSource = AuthRemoteDataSourceImpl(apiService: apiService);
    _authRepository = AuthRepositoryImpl(remoteDataSource: remoteDataSource);
  }

  void _initAnimations() {
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _slideAnimation = Tween<double>(begin: 60.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    _mainController.forward();
  }

  void _initFocusListeners() {
    _emailFocusNode.addListener(
      () => setState(() => _isEmailFocused = _emailFocusNode.hasFocus),
    );
    _passwordFocusNode.addListener(
      () => setState(() => _isPasswordFocused = _passwordFocusNode.hasFocus),
    );
  }

  Future<void> _checkBiometrics() async {
    debugPrint('🧪 LoginPage: Checking biometric status...');
    final available = await _biometricService.isBiometricAvailable();
    final enabled = await _biometricService.isEnabled();
    debugPrint(
      '🧪 LoginPage: Hardware available: $available, Enabled: $enabled',
    );

    if (mounted) {
      setState(() => _isBiometricEnabled = enabled);
      if (enabled) {
        final hasToken = await _biometricService.getStoredToken() != null;
        debugPrint('🧪 LoginPage: Secure token present: $hasToken');

        if (hasToken) {
          debugPrint('🧪 LoginPage: Auto-triggering biometric prompt in 1s...');
          Future.delayed(
            const Duration(milliseconds: 1000),
            _handleBiometricAuth,
          );
        } else {
          debugPrint(
            '🧪 LoginPage: Biometric enabled but NO token found. Resetting state.',
          );
          await _biometricService.disableBiometricLogin();
          setState(() => _isBiometricEnabled = false);
        }
      }
    }
  }

  Future<void> _handleBiometricAuth() async {
    debugPrint('🧪 LoginPage: Starting _handleBiometricAuth...');
    if (_isLoading) {
      debugPrint('🧪 LoginPage: Auth skipped because _isLoading is true');
      return;
    }

    final authenticated = await _biometricService.authenticate(
      reason: 'Login to your Housepital account',
    );
    debugPrint('🧪 LoginPage: Biometric authentication result: $authenticated');

    if (authenticated) {
      final token = await _biometricService.getStoredToken();
      debugPrint('🧪 LoginPage: Retrieved token length: ${token?.length ?? 0}');

      if (token != null) {
        setState(() => _isLoading = true);
        await TokenManager.saveToken(token);

        try {
          debugPrint('🧪 LoginPage: Verifying token with server...');
          final response = await _authRepository.getCurrentUser();
          if (mounted) {
            setState(() => _isLoading = false);
            if (response.user != null) {
              debugPrint(
                '🧪 LoginPage: Token valid. Welcome ${response.user!.name}. Navigating home...',
              );
              await TokenManager.saveUserId(response.user!.id);
              await TokenManager.saveUserRole(response.user!.role);
              context.read<NotificationProvider>().initialize();

              final route = _getHomeRouteForRole(response.user!.role);
              Navigator.pushNamedAndRemoveUntil(
                context,
                route,
                (route) => false,
              );
              return;
            }
          }
        } catch (e) {
          debugPrint('🧪 LoginPage: Token verification failed: $e');
          if (mounted) {
            setState(() => _isLoading = false);
            CustomPopup.error(
              context,
              AppLocalizations.of(context)!.sessionExpired,
            );
          }
        }
      }
    }
  }

  Future<void> _loadSavedCredentials() async {
    final rememberMe = await TokenManager.getRememberMe();
    final savedEmail = await TokenManager.getSavedEmail();
    if (mounted && rememberMe && savedEmail != null) {
      setState(() {
        _rememberMe = true;
        _emailController.text = savedEmail;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _mainController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _triggerShake() {
    _shakeController.forward().then((_) => _shakeController.reset());
  }

  Future<void> _handleLogin() async {
    final l10n = AppLocalizations.of(context)!;
    if (_emailController.text.trim().isEmpty) {
      _triggerShake();
      CustomPopup.warning(context, l10n.warningEmptyEmail);
      return;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      _triggerShake();
      CustomPopup.warning(context, l10n.warningInvalidEmail);
      return;
    }
    if (_passwordController.text.isEmpty) {
      _triggerShake();
      CustomPopup.warning(context, l10n.warningEmptyPassword);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final request = LoginRequest(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      final response = await _authRepository.login(request);

      if (mounted) {
        setState(() => _isLoading = false);
        if (response.success) {
          // Debug: print raw response and token info
          debugPrint('🧪 LoginPage: login response -> $response');
          debugPrint(
            '🧪 LoginPage: token length -> ${response.token?.length ?? 0}',
          );

          if (response.token != null) {
            await TokenManager.saveToken(response.token!);
            // If biometrics were enabled before, update the stored token
            if (_isBiometricEnabled) {
              await _biometricService.enableBiometricLogin(response.token!);
            }
          }
          if (response.user != null && response.user!.id.isNotEmpty)
            await TokenManager.saveUserId(response.user!.id);
          if (response.user != null)
            await TokenManager.saveUserRole(response.user!.role);

          await TokenManager.setRememberMe(
            _rememberMe,
            email: _rememberMe ? _emailController.text.trim() : null,
          );

          if (mounted) {
            context.read<NotificationProvider>().initialize();
            CustomPopup.success(context, response.message);
            final route =
                response.user != null
                    ? _getHomeRouteForRole(response.user!.role)
                    : AppRoutes.customerHome;
            Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
          }
        } else {
          _triggerShake();
          CustomPopup.error(context, l10n.errorInvalidCredentials);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _triggerShake();
        CustomPopup.error(context, 'Something went wrong');
      }
    }
  }

  String _getHomeRouteForRole(String role) {
    switch (role.toLowerCase()) {
      case 'customer':
        return AppRoutes.customerHome;
      case 'nurse':
        return AppRoutes.nurseHome;
      case 'doctor':
        return AppRoutes.doctorHome;
      case 'admin':
        return AppRoutes.adminDashboard;
      default:
        return AppRoutes.customerHome;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          ..._buildFloatingShapes(size),
          SafeArea(
            child: AnimatedBuilder(
              animation: _mainController,
              builder:
                  (context, child) => Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: Opacity(opacity: _fadeAnimation.value, child: child),
                  ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.05),
                      _buildHeader(),
                      const SizedBox(height: 36),
                      _buildLoginCard(),
                      const SizedBox(height: 24),
                      _buildSocialLogin(),
                      const SizedBox(height: 20),
                      _buildRegisterLink(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _floatingController,
      builder:
          (context, child) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: const [
                  Color(0xFF00D47F),
                  Color(0xFF00B870),
                  Color(0xFF009960),
                  Color(0xFF007A4D),
                ],
                transform: GradientRotation(
                  _floatingController.value * 2 * math.pi * 0.1,
                ),
              ),
            ),
          ),
    );
  }

  List<Widget> _buildFloatingShapes(Size size) {
    return [
      Positioned(
        top: -size.width * 0.3,
        right: -size.width * 0.2,
        child: AnimatedBuilder(
          animation: _floatingController,
          builder:
              (context, child) => Transform.rotate(
                angle: _floatingController.value * 2 * math.pi,
                child: Container(
                  width: size.width * 0.7,
                  height: size.width * 0.7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
        ),
      ),
      Positioned(
        bottom: -size.width * 0.4,
        left: -size.width * 0.3,
        child: AnimatedBuilder(
          animation: _floatingController,
          builder:
              (context, child) => Transform.rotate(
                angle: -_floatingController.value * math.pi,
                child: Container(
                  width: size.width * 0.8,
                  height: size.width * 0.8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                      width: 2,
                    ),
                  ),
                ),
              ),
        ),
      ),
      _buildFloatingDot(size, 0.1, 0.15, 16),
      _buildFloatingDot(size, 0.85, 0.2, 12),
      _buildFloatingDot(size, 0.15, 0.75, 10),
      _buildFloatingDot(size, 0.9, 0.65, 14),
      _buildMedicalCross(size, 0.2, 0.12, 28),
      _buildMedicalCross(size, 0.85, 0.78, 22),
    ];
  }

  Widget _buildFloatingDot(Size size, double left, double top, double dotSize) {
    return Positioned(
      left: size.width * left,
      top: size.height * top,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder:
            (context, child) => Transform.scale(
              scale: 0.8 + _pulseController.value * 0.4,
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(
                    alpha: 0.1 + _pulseController.value * 0.1,
                  ),
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildMedicalCross(
    Size size,
    double left,
    double top,
    double crossSize,
  ) {
    return Positioned(
      left: size.width * left,
      top: size.height * top,
      child: AnimatedBuilder(
        animation: _floatingController,
        builder:
            (context, child) => Transform.rotate(
              angle: _floatingController.value * math.pi * 2,
              child: Icon(
                Icons.add_rounded,
                size: crossSize,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    return AnimatedBuilder(
      animation: _mainController,
      builder:
          (context, child) =>
              Transform.scale(scale: _scaleAnimation.value, child: child),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder:
                (context, child) => Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(
                          alpha: 0.1 + _pulseController.value * 0.1,
                        ),
                        blurRadius: 30 + _pulseController.value * 20,
                        spreadRadius: 5 + _pulseController.value * 10,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/WhiteLogo.png',
                    width: 75,
                    height: 75,
                    fit: BoxFit.contain,
                  ),
                ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Housepital',
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
              shadows: [
                Shadow(
                  color: Color(0x40000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.appTagline ?? 'Healthcare at Your Doorstep',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard() {
    final l10n = AppLocalizations.of(context)!;
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final shake = math.sin(_shakeAnimation.value * math.pi * 4) * 10;
        return Transform.translate(offset: Offset(shake, 0), child: child);
      },
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
            BoxShadow(
              color: AppColors.primary500.withValues(alpha: 0.1),
              blurRadius: 60,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.waving_hand_rounded,
                        color: AppColors.primary500,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.loginTitle,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.loginSubtitle,
                      style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildAnimatedInputField(
                label: l10n.emailLabel,
                hint: l10n.emailHint,
                controller: _emailController,
                focusNode: _emailFocusNode,
                icon: Icons.email_rounded,
                isFocused: _isEmailFocused,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              _buildAnimatedPasswordField(),
              const SizedBox(height: 20),
              _buildRememberForgotRow(),
              const SizedBox(height: 28),
              _buildLoginButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    required IconData icon,
    required bool isFocused,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isFocused ? AppColors.primary600 : const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 10),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isFocused ? AppColors.primary50 : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isFocused ? AppColors.primary500 : const Color(0xFFE2E8F0),
              width: isFocused ? 2 : 1,
            ),
            boxShadow:
                isFocused
                    ? [
                      BoxShadow(
                        color: AppColors.primary500.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : [],
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 15,
                fontWeight: FontWeight.normal,
              ),
              prefixIcon: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                child: Icon(
                  icon,
                  color: isFocused ? AppColors.primary500 : Colors.grey[400],
                  size: 24,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedPasswordField() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.passwordLabel,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color:
                _isPasswordFocused
                    ? AppColors.primary600
                    : const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 10),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color:
                _isPasswordFocused
                    ? AppColors.primary50
                    : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  _isPasswordFocused
                      ? AppColors.primary500
                      : const Color(0xFFE2E8F0),
              width: _isPasswordFocused ? 2 : 1,
            ),
            boxShadow:
                _isPasswordFocused
                    ? [
                      BoxShadow(
                        color: AppColors.primary500.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : [],
          ),
          child: TextField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            obscureText: _obscurePassword,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: l10n.passwordHint,
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 15,
                fontWeight: FontWeight.normal,
              ),
              prefixIcon: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                child: Icon(
                  Icons.lock_rounded,
                  color:
                      _isPasswordFocused
                          ? AppColors.primary500
                          : Colors.grey[400],
                  size: 24,
                ),
              ),
              suffixIcon: GestureDetector(
                onTap:
                    () => setState(() => _obscurePassword = !_obscurePassword),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      key: ValueKey(_obscurePassword),
                      color:
                          _isPasswordFocused
                              ? AppColors.primary500
                              : Colors.grey[400],
                      size: 24,
                    ),
                  ),
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRememberForgotRow() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => setState(() => _rememberMe = !_rememberMe),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color:
                      _rememberMe ? AppColors.primary500 : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color:
                        _rememberMe ? AppColors.primary500 : Colors.grey[400]!,
                    width: 2,
                  ),
                ),
                child:
                    _rememberMe
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
              ),
              const SizedBox(width: 10),
              Text(
                l10n.rememberMe,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed:
              () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
          child: Text(
            l10n.forgotPassword,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.primary500,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 58,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary500,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: AppColors.primary500.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child:
                    _isLoading
                        ? const SizedBox(
                          key: ValueKey('loading'),
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                        : Row(
                          key: const ValueKey('button'),
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.loginButton,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.arrow_forward_rounded, size: 22),
                          ],
                        ),
              ),
            ),
          ),
        ),
        if (_isBiometricEnabled) ...[
          const SizedBox(width: 12),
          SizedBox(
            height: 58,
            width: 58,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleBiometricAuth,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary50,
                foregroundColor: AppColors.primary500,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: AppColors.primary500.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: const Icon(Icons.fingerprint_rounded, size: 32),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSocialLogin() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.orLoginWith,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(
              icon: Icons.g_mobiledata_rounded,
              label: l10n.google,
              onTap: () {},
            ),
            const SizedBox(width: 16),
            _buildSocialButton(
              icon: Icons.apple_rounded,
              label: l10n.apple,
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 26, color: const Color(0xFF374151)),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.dontHaveAccount,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.only(left: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              l10n.registerHere,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white,
                decorationThickness: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
