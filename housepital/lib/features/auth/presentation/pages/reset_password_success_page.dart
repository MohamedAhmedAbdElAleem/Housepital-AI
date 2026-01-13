import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';

class ResetPasswordSuccessPage extends StatefulWidget {
  const ResetPasswordSuccessPage({super.key});

  @override
  State<ResetPasswordSuccessPage> createState() =>
      _ResetPasswordSuccessPageState();
}

class _ResetPasswordSuccessPageState extends State<ResetPasswordSuccessPage>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _mainController;
  late AnimationController _floatingController;
  late AnimationController _pulseController;
  late AnimationController _confettiController;
  late AnimationController _checkController;

  // Animations
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _checkAnimation;

  // Confetti particles
  final List<ConfettiParticle> _particles = [];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _generateConfetti();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  void _initAnimations() {
    // Main animation controller
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    // Floating background animation
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Pulse animation for success icon
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Confetti animation
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Checkmark drawing animation
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.easeInOut),
    );

    // Start animations
    _mainController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _checkController.forward();
    });
  }

  void _generateConfetti() {
    final random = math.Random();
    for (int i = 0; i < 30; i++) {
      _particles.add(
        ConfettiParticle(
          x: random.nextDouble(),
          y: random.nextDouble(),
          size: random.nextDouble() * 8 + 4,
          speed: random.nextDouble() * 0.5 + 0.3,
          color:
              [
                const Color(0xFFFFD700),
                const Color(0xFF87CEEB),
                const Color(0xFFFFB6C1),
                const Color(0xFF98FB98),
                Colors.white,
                const Color(0xFFDDA0DD),
              ][random.nextInt(6)],
          rotation: random.nextDouble() * math.pi * 2,
        ),
      );
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    _confettiController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          _buildAnimatedBackground(),

          // Floating shapes
          ..._buildFloatingShapes(size),

          // Confetti particles
          _buildConfettiOverlay(size),

          // Main content
          SafeArea(
            child: AnimatedBuilder(
              animation: _mainController,
              builder: (context, child) {
                return Opacity(opacity: _fadeAnimation.value, child: child);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    // Success Icon with animations
                    _buildSuccessIcon(),

                    const SizedBox(height: 40),

                    // Success Message
                    _buildSuccessMessage(),

                    const SizedBox(height: 30),

                    // Security tips card
                    _buildSecurityTips(),

                    const Spacer(flex: 2),

                    // Back to Login Button
                    _buildLoginButton(),

                    const SizedBox(height: 40),
                  ],
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

  List<Widget> _buildFloatingShapes(Size size) {
    return [
      // Large circle top right
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
      // Bottom left circle
      Positioned(
        bottom: -size.width * 0.25,
        left: -size.width * 0.15,
        child: Container(
          width: size.width * 0.6,
          height: size.width * 0.6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 2,
            ),
          ),
        ),
      ),
      // Floating icons
      _buildFloatingIcon(
        size.height * 0.1,
        size.width * 0.1,
        Icons.lock_rounded,
        20,
      ),
      _buildFloatingIcon(
        size.height * 0.15,
        size.width * 0.8,
        Icons.verified_user_rounded,
        18,
      ),
      _buildFloatingIcon(
        size.height * 0.75,
        size.width * 0.85,
        Icons.shield_rounded,
        16,
      ),
      _buildFloatingIcon(
        size.height * 0.8,
        size.width * 0.1,
        Icons.key_rounded,
        14,
      ),
    ];
  }

  Widget _buildFloatingIcon(
    double top,
    double left,
    IconData icon,
    double iconSize,
  ) {
    return Positioned(
      top: top,
      left: left,
      child: AnimatedBuilder(
        animation: _floatingController,
        builder: (context, child) {
          final offset = math.sin(_floatingController.value * 2 * math.pi) * 10;
          return Transform.translate(
            offset: Offset(0, offset),
            child: Icon(
              icon,
              size: iconSize,
              color: Colors.white.withValues(alpha: 0.15),
            ),
          );
        },
      ),
    );
  }

  Widget _buildConfettiOverlay(Size size) {
    return AnimatedBuilder(
      animation: _confettiController,
      builder: (context, child) {
        return CustomPaint(
          size: size,
          painter: ConfettiPainter(
            particles: _particles,
            progress: _confettiController.value,
          ),
        );
      },
    );
  }

  Widget _buildSuccessIcon() {
    return AnimatedBuilder(
      animation: Listenable.merge([_mainController, _pulseController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value * _pulseAnimation.value,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.4),
                  blurRadius: 50,
                  spreadRadius: 15,
                ),
                BoxShadow(
                  color: AppColors.primary500.withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer ring
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary100, width: 3),
                  ),
                ),
                // Inner gradient circle
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary400, AppColors.primary600],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary500.withValues(alpha: 0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: AnimatedBuilder(
                    animation: _checkController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: CheckmarkPainter(
                          progress: _checkAnimation.value,
                          color: Colors.white,
                          strokeWidth: 6,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuccessMessage() {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(opacity: _fadeAnimation.value, child: child),
        );
      },
      child: Column(
        children: [
          const Text(
            'Password Reset\nSuccessful! 🎉',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
              letterSpacing: 0.5,
              shadows: [
                Shadow(
                  color: Color(0x40000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your password has been changed successfully.\nYou can now login with your new password.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTips() {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 1.5),
          child: Opacity(opacity: _fadeAnimation.value, child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.tips_and_updates_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Security Tips',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _buildTipItem(
              Icons.lock_outline_rounded,
              'Keep your password private',
            ),
            const SizedBox(height: 8),
            _buildTipItem(
              Icons.sync_lock_rounded,
              'Change it every 3-6 months',
            ),
            const SizedBox(height: 8),
            _buildTipItem(
              Icons.devices_rounded,
              'Sign out from unknown devices',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.8)),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 2),
          child: Opacity(opacity: _fadeAnimation.value, child: child),
        );
      },
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary600,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                shadowColor: Colors.white.withValues(alpha: 0.3),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.login_rounded,
                      size: 18,
                      color: AppColors.primary600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Back to Login',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Animated confetti dots
          _buildAnimatedConfettiDots(),
        ],
      ),
    );
  }

  Widget _buildAnimatedConfettiDots() {
    return AnimatedBuilder(
      animation: _confettiController,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(7, (index) {
            final delay = index * 0.1;
            final progress = (_confettiController.value + delay) % 1.0;
            final scale = 0.5 + math.sin(progress * math.pi) * 0.5;
            final colors = [
              const Color(0xFFFFD700),
              Colors.white,
              const Color(0xFF87CEEB),
              const Color(0xFFFFB6C1),
              const Color(0xFF98FB98),
              Colors.white,
              const Color(0xFFDDA0DD),
            ];
            return Transform.scale(
              scale: scale,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: colors[index].withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colors[index].withValues(alpha: 0.4),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// Custom painter for animated checkmark
class CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  CheckmarkPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);

    // Checkmark path points
    final start = Offset(center.dx - 22, center.dy + 2);
    final middle = Offset(center.dx - 6, center.dy + 18);
    final end = Offset(center.dx + 24, center.dy - 14);

    final path = Path();

    if (progress <= 0.5) {
      // First part of checkmark
      final t = progress * 2;
      final currentPoint = Offset.lerp(start, middle, t)!;
      path.moveTo(start.dx, start.dy);
      path.lineTo(currentPoint.dx, currentPoint.dy);
    } else {
      // Full first part + second part
      path.moveTo(start.dx, start.dy);
      path.lineTo(middle.dx, middle.dy);

      final t = (progress - 0.5) * 2;
      final currentPoint = Offset.lerp(middle, end, t)!;
      path.lineTo(currentPoint.dx, currentPoint.dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CheckmarkPainter oldDelegate) =>
      progress != oldDelegate.progress;
}

// Confetti particle model
class ConfettiParticle {
  double x;
  double y;
  double size;
  double speed;
  Color color;
  double rotation;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.color,
    required this.rotation,
  });
}

// Custom painter for confetti
class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint =
          Paint()
            ..color = particle.color.withValues(alpha: 0.6)
            ..style = PaintingStyle.fill;

      final y = (particle.y + progress * particle.speed) % 1.0;
      final x =
          particle.x +
          math.sin(progress * math.pi * 2 + particle.rotation) * 0.02;

      canvas.save();
      canvas.translate(x * size.width, y * size.height);
      canvas.rotate(progress * math.pi * 2 * particle.speed);

      // Draw different shapes
      if (particle.size > 8) {
        // Star shape
        final path = Path();
        for (int i = 0; i < 5; i++) {
          final angle = (i * 4 * math.pi / 5) - math.pi / 2;
          final point = Offset(
            math.cos(angle) * particle.size / 2,
            math.sin(angle) * particle.size / 2,
          );
          if (i == 0) {
            path.moveTo(point.dx, point.dy);
          } else {
            path.lineTo(point.dx, point.dy);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
      } else {
        // Circle
        canvas.drawCircle(Offset.zero, particle.size / 2, paint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => true;
}
