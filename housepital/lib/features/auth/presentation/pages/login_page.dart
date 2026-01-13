import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/widgets/custom_popup.dart';
import '../../../../core/utils/token_manager.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/models/login_request.dart';

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
    super.initState();
    _initRepository();
    _initAnimations();
    _initFocusListeners();
    _loadSavedCredentials();

    // Set status bar
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
    // Main entrance animation
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

    // Floating animation for background
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Pulse animation for logo
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Shake animation for error
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
    _emailFocusNode.addListener(() {
      setState(() => _isEmailFocused = _emailFocusNode.hasFocus);
    });
    _passwordFocusNode.addListener(() {
      setState(() => _isPasswordFocused = _passwordFocusNode.hasFocus);
    });
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
    // Validation with shake effect
    if (_emailController.text.trim().isEmpty) {
      _triggerShake();
      CustomPopup.warning(context, 'Please enter your email');
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      _triggerShake();
      CustomPopup.warning(context, 'Please enter a valid email');
      return;
    }

    if (_passwordController.text.isEmpty) {
      _triggerShake();
      CustomPopup.warning(context, 'Please enter your password');
      return;
    }

    if (_passwordController.text.length < 6) {
      _triggerShake();
      CustomPopup.warning(context, 'Password must be at least 6 characters');
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
          if (response.token != null) {
            await TokenManager.saveToken(response.token!);
          }
          if (response.user != null && response.user!.id.isNotEmpty) {
            await TokenManager.saveUserId(response.user!.id);
          }
          if (response.user != null) {
            await TokenManager.saveUserRole(response.user!.role);
          }

          await TokenManager.setRememberMe(
            _rememberMe,
            email: _rememberMe ? _emailController.text.trim() : null,
          );

          if (mounted) {
            CustomPopup.success(context, response.message);
            final route =
                response.user != null
                    ? _getHomeRouteForRole(response.user!.role)
                    : AppRoutes.customerHome;
            Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
          }
        } else {
          _triggerShake();
          CustomPopup.error(context, 'Invalid email or password');
        }
      }
    } on UnauthorizedException {
      if (mounted) {
        setState(() => _isLoading = false);
        _triggerShake();
        CustomPopup.error(context, 'Invalid email or password');
      }
    } on NetworkException {
      if (mounted) {
        setState(() => _isLoading = false);
        _triggerShake();
        CustomPopup.error(context, 'No internet connection');
      }
    } on ServerException {
      if (mounted) {
        setState(() => _isLoading = false);
        _triggerShake();
        CustomPopup.error(context, 'Server error. Please try again');
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ═══════════════════════════════════════════════════════════
          // 🎨 ANIMATED GRADIENT BACKGROUND
          // ═══════════════════════════════════════════════════════════
          _buildAnimatedBackground(),

          // ═══════════════════════════════════════════════════════════
          // ✨ FLOATING SHAPES
          // ═══════════════════════════════════════════════════════════
          ..._buildFloatingShapes(size),

          // ═══════════════════════════════════════════════════════════
          // 📝 MAIN CONTENT
          // ═══════════════════════════════════════════════════════════
          SafeArea(
            child: AnimatedBuilder(
              animation: _mainController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: Opacity(opacity: _fadeAnimation.value, child: child),
                );
              },
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

  // ═══════════════════════════════════════════════════════════════════════
  // 🎨 ANIMATED BACKGROUND
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        return Container(
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
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ✨ FLOATING SHAPES
  // ═══════════════════════════════════════════════════════════════════════
  List<Widget> _buildFloatingShapes(Size size) {
    return [
      // Large circle top-right
      Positioned(
        top: -size.width * 0.3,
        right: -size.width * 0.2,
        child: AnimatedBuilder(
          animation: _floatingController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _floatingController.value * 2 * math.pi,
              child: Container(
                width: size.width * 0.7,
                height: size.width * 0.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            );
          },
        ),
      ),
      // Bottom-left circle
      Positioned(
        bottom: -size.width * 0.4,
        left: -size.width * 0.3,
        child: AnimatedBuilder(
          animation: _floatingController,
          builder: (context, child) {
            return Transform.rotate(
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
            );
          },
        ),
      ),
      // Small floating dots
      _buildFloatingDot(size, 0.1, 0.15, 16),
      _buildFloatingDot(size, 0.85, 0.2, 12),
      _buildFloatingDot(size, 0.15, 0.75, 10),
      _buildFloatingDot(size, 0.9, 0.65, 14),
      // Medical crosses
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
        builder: (context, child) {
          return Transform.scale(
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
          );
        },
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
        builder: (context, child) {
          return Transform.rotate(
            angle: _floatingController.value * math.pi * 2,
            child: Icon(
              Icons.add_rounded,
              size: crossSize,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🏥 HEADER WITH LOGO
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: Column(
        children: [
          // Logo with glow effect
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
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
              );
            },
          ),

          const SizedBox(height: 20),

          // App Name with shadow
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

          // Tagline
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
                const Text(
                  'Healthcare at Your Doorstep',
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

  // ═══════════════════════════════════════════════════════════════════════
  // 📋 LOGIN CARD
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildLoginCard() {
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
              // Welcome Text
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
                    const Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to continue your healthcare journey',
                      style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Email Field
              _buildAnimatedInputField(
                label: 'Email Address',
                hint: 'Enter your email',
                controller: _emailController,
                focusNode: _emailFocusNode,
                icon: Icons.email_rounded,
                isFocused: _isEmailFocused,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 20),

              // Password Field
              _buildAnimatedPasswordField(),

              const SizedBox(height: 20),

              // Remember Me & Forgot Password
              _buildRememberForgotRow(),

              const SizedBox(height: 28),

              // Login Button
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
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
              hintText: 'Enter your password',
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Remember Me
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
                'Remember me',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        // Forgot Password
        TextButton(
          onPressed:
              () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
          child: Text(
            'Forgot Password?',
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
    return SizedBox(
      width: double.infinity,
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
                    children: const [
                      Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward_rounded, size: 22),
                    ],
                  ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🔗 SOCIAL LOGIN
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildSocialLogin() {
    return Column(
      children: [
        // Divider
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
                'Or continue with',
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

        // Social Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(
              icon: Icons.g_mobiledata_rounded,
              label: 'Google',
              onTap: () {
                // TODO: Implement Google Sign In
              },
            ),
            const SizedBox(width: 16),
            _buildSocialButton(
              icon: Icons.apple_rounded,
              label: 'Apple',
              onTap: () {
                // TODO: Implement Apple Sign In
              },
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

  // ═══════════════════════════════════════════════════════════════════════
  // 📝 REGISTER LINK
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildRegisterLink() {
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
            "Don't have an account?",
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
            child: const Text(
              'Sign Up',
              style: TextStyle(
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
