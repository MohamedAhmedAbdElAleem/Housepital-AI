import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/utils/token_manager.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  // Main animation controller
  late AnimationController _mainController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  // Pulse animation for logo glow
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Background shapes animation
  late AnimationController _backgroundController;

  // Loading dots animation
  late AnimationController _loadingController;

  @override
  void initState() {
    super.initState();

    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _initAnimations();
    _startAnimations();
    _navigateToNext();
  }

  void _initAnimations() {
    // Main animation controller (2 seconds)
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    // Pulse animation (continuous)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Background animation (slow rotation)
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    // Loading dots animation
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
  }

  void _startAnimations() {
    _mainController.forward();
    _pulseController.repeat(reverse: true);
    _backgroundController.repeat();
    _loadingController.repeat();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 3500));

    if (!mounted) return;

    // Check if user has a valid token (already logged in)
    final hasToken = await TokenManager.hasToken();
    if (hasToken) {
      final role = await TokenManager.getUserRole();
      String nextRoute = AppRoutes.customerHome;

      if (role != null) {
        switch (role.toLowerCase()) {
          case 'customer':
            nextRoute = AppRoutes.customerHome;
            break;
          case 'nurse':
            nextRoute = AppRoutes.nurseHome;
            break;
          case 'doctor':
            nextRoute = AppRoutes.doctorHome;
            break;
          case 'admin':
            nextRoute = AppRoutes.adminDashboard;
            break;
        }
      }

      if (mounted) {
        Navigator.of(context).pushReplacementNamed(nextRoute);
      }
      return;
    }

    final isFirstLaunch = await TokenManager.isFirstLaunch();
    if (!mounted) return;

    if (isFirstLaunch) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _backgroundController.dispose();
    _loadingController.dispose();
    super.dispose();
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
          AnimatedBuilder(
            animation: _backgroundController,
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
                    stops: const [0.0, 0.3, 0.7, 1.0],
                    transform: GradientRotation(
                      _backgroundController.value * 2 * math.pi * 0.1,
                    ),
                  ),
                ),
              );
            },
          ),

          // ═══════════════════════════════════════════════════════════
          // ✨ FLOATING SHAPES (Background decoration)
          // ═══════════════════════════════════════════════════════════
          ..._buildFloatingShapes(size),

          // ═══════════════════════════════════════════════════════════
          // 🏥 MAIN CONTENT
          // ═══════════════════════════════════════════════════════════
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Logo with glow effect
                  _buildAnimatedLogo(),

                  const SizedBox(height: 32),

                  // App Name & Tagline
                  _buildAppTitle(),

                  const Spacer(flex: 2),

                  // Loading indicator
                  _buildLoadingIndicator(),

                  const SizedBox(height: 40),

                  // Version info
                  _buildVersionInfo(),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 🔷 FLOATING SHAPES
  // ═══════════════════════════════════════════════════════════════════
  List<Widget> _buildFloatingShapes(Size size) {
    return [
      // Top-right circle
      Positioned(
        top: -size.width * 0.3,
        right: -size.width * 0.2,
        child: AnimatedBuilder(
          animation: _backgroundController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _backgroundController.value * 2 * math.pi,
              child: Container(
                width: size.width * 0.7,
                height: size.width * 0.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
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
          animation: _backgroundController,
          builder: (context, child) {
            return Transform.rotate(
              angle: -_backgroundController.value * 2 * math.pi * 0.5,
              child: Container(
                width: size.width * 0.8,
                height: size.width * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 2,
                  ),
                ),
              ),
            );
          },
        ),
      ),

      // Small floating circles
      Positioned(
        top: size.height * 0.15,
        left: size.width * 0.1,
        child: _buildFloatingDot(20, 0.15),
      ),
      Positioned(
        top: size.height * 0.25,
        right: size.width * 0.15,
        child: _buildFloatingDot(15, 0.1),
      ),
      Positioned(
        bottom: size.height * 0.25,
        left: size.width * 0.2,
        child: _buildFloatingDot(12, 0.08),
      ),
      Positioned(
        bottom: size.height * 0.35,
        right: size.width * 0.1,
        child: _buildFloatingDot(18, 0.12),
      ),

      // Medical cross shapes
      Positioned(
        top: size.height * 0.12,
        right: size.width * 0.25,
        child: _buildMedicalCross(30, 0.08),
      ),
      Positioned(
        bottom: size.height * 0.18,
        left: size.width * 0.08,
        child: _buildMedicalCross(24, 0.06),
      ),
    ];
  }

  Widget _buildFloatingDot(double size, double opacity) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_pulseAnimation.value - 1) * 2,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(opacity),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMedicalCross(double size, double opacity) {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _backgroundController.value * math.pi,
          child: Icon(
            Icons.add_rounded,
            size: size,
            color: Colors.white.withOpacity(opacity),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 🏥 ANIMATED LOGO
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        // Outer glow
                        BoxShadow(
                          color: Colors.white.withOpacity(
                            0.3 * _pulseAnimation.value,
                          ),
                          blurRadius: 40 * _pulseAnimation.value,
                          spreadRadius: 10 * _pulseAnimation.value,
                        ),
                        // Inner shadow
                        BoxShadow(
                          color: AppColors.primary700.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/Logo.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 📝 APP TITLE & TAGLINE
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildAppTitle() {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 0.5),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Column(
              children: [
                // App Name with shadow
                const Text(
                  'Housepital',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        color: Color(0x40000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Tagline with container
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: Colors.white.withOpacity(0.9),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'AI-Powered Home Healthcare',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.95),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // ⏳ LOADING INDICATOR (Animated dots)
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildLoadingIndicator() {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Column(
            children: [
              // Animated dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return AnimatedBuilder(
                    animation: _loadingController,
                    builder: (context, child) {
                      final delay = index * 0.2;
                      final animValue =
                          ((_loadingController.value + delay) % 1.0);
                      final scale =
                          animValue < 0.5 ? 1.0 + animValue : 2.0 - animValue;

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        child: Transform.scale(
                          scale: scale * 0.6,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(
                                0.5 + animValue * 0.5,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),

              const SizedBox(height: 16),

              // Loading text
              Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 📱 VERSION INFO
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildVersionInfo() {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value * 0.6,
          child: Text(
            'Version 1.0.0',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.5),
              fontWeight: FontWeight.w400,
            ),
          ),
        );
      },
    );
  }
}
