import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';

class VerificationSuccessPage extends StatefulWidget {
  const VerificationSuccessPage({super.key});

  @override
  State<VerificationSuccessPage> createState() =>
      _VerificationSuccessPageState();
}

class _VerificationSuccessPageState extends State<VerificationSuccessPage>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _mainController;
  late AnimationController _floatingController;
  late AnimationController _pulseController;
  late AnimationController _badgeRotationController;
  late AnimationController _celebrationController;
  late AnimationController _shieldController;

  // Animations
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shieldAnimation;

  // Celebration particles
  final List<CelebrationParticle> _particles = [];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _generateParticles();

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
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 60.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Floating background animation
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Badge rotation
    _badgeRotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Celebration particles
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Shield animation
    _shieldController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _shieldAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shieldController, curve: Curves.easeOutBack),
    );

    // Start animations
    _mainController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _shieldController.forward();
    });
  }

  void _generateParticles() {
    final random = math.Random();
    for (int i = 0; i < 25; i++) {
      _particles.add(
        CelebrationParticle(
          x: random.nextDouble(),
          y: random.nextDouble(),
          size: random.nextDouble() * 10 + 4,
          speed: random.nextDouble() * 0.4 + 0.2,
          color:
              [
                const Color(0xFFFFD700),
                const Color(0xFF00D47F),
                const Color(0xFF87CEEB),
                Colors.white,
                const Color(0xFF98FB98),
              ][random.nextInt(5)],
          rotation: random.nextDouble() * math.pi * 2,
          shape: random.nextInt(3), // 0: circle, 1: star, 2: diamond
        ),
      );
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    _badgeRotationController.dispose();
    _celebrationController.dispose();
    _shieldController.dispose();
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

          // Celebration particles
          _buildCelebrationOverlay(size),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    SizedBox(height: size.height * 0.06),

                    // Header with badge
                    _buildHeader(),

                    const SizedBox(height: 30),

                    // Main card
                    _buildMainCard(),

                    const SizedBox(height: 24),

                    // Benefits section
                    _buildBenefitsSection(),

                    const SizedBox(height: 30),

                    // Continue button
                    _buildContinueButton(),

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
      // Bottom circle
      Positioned(
        bottom: -size.width * 0.2,
        left: -size.width * 0.15,
        child: Container(
          width: size.width * 0.5,
          height: size.width * 0.5,
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
        size.height * 0.08,
        size.width * 0.1,
        Icons.verified_user_rounded,
        22,
      ),
      _buildFloatingIcon(
        size.height * 0.12,
        size.width * 0.82,
        Icons.badge_rounded,
        18,
      ),
      _buildFloatingIcon(
        size.height * 0.85,
        size.width * 0.85,
        Icons.security_rounded,
        16,
      ),
      _buildFloatingIcon(
        size.height * 0.88,
        size.width * 0.08,
        Icons.shield_rounded,
        20,
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
          final offset = math.sin(_floatingController.value * 2 * math.pi) * 12;
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

  Widget _buildCelebrationOverlay(Size size) {
    return AnimatedBuilder(
      animation: _celebrationController,
      builder: (context, child) {
        return CustomPaint(
          size: size,
          painter: CelebrationPainter(
            particles: _particles,
            progress: _celebrationController.value,
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: Listenable.merge([_mainController, _pulseController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Column(
            children: [
              // Animated Badge
              Transform.scale(
                scale: _pulseAnimation.value,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer glow
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.3),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    // Badge
                    AnimatedBuilder(
                      animation: _badgeRotationController,
                      builder: (context, child) {
                        return CustomPaint(
                          size: const Size(140, 140),
                          painter: AnimatedBadgePainter(
                            rotation:
                                _badgeRotationController.value *
                                2 *
                                math.pi *
                                0.05,
                          ),
                        );
                      },
                    ),
                    // Shield icon
                    AnimatedBuilder(
                      animation: _shieldController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _shieldAnimation.value,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary500.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.verified_rounded,
                              size: 50,
                              color: AppColors.primary500,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Title
              const Text(
                'Verification\nSuccessful! 🎉',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.15,
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
              const SizedBox(height: 12),
              Text(
                'Your identity has been verified successfully',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainCard() {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(opacity: _fadeAnimation.value, child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 40,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          children: [
            // Status row
            _buildStatusItem(
              icon: Icons.person_rounded,
              title: 'Identity Verified',
              subtitle: 'Your ID has been confirmed',
              color: AppColors.success500,
              isCompleted: true,
            ),
            const SizedBox(height: 16),
            _buildStatusItem(
              icon: Icons.badge_rounded,
              title: 'Documents Approved',
              subtitle: 'All documents are valid',
              color: AppColors.success500,
              isCompleted: true,
            ),
            const SizedBox(height: 16),
            _buildStatusItem(
              icon: Icons.verified_user_rounded,
              title: 'Account Secured',
              subtitle: 'Your account is protected',
              color: AppColors.success500,
              isCompleted: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isCompleted,
  }) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, color: color, size: 26),
              if (isCompleted)
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: color,
                      size: 16,
                    ),
                  ),
                ),
            ],
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
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_rounded, color: color, size: 14),
              const SizedBox(width: 4),
              Text(
                'Done',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitsSection() {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 1.3),
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    Icons.star_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'What You Can Do Now',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildBenefitItem(
              Icons.medical_services_rounded,
              'Book medical services',
            ),
            const SizedBox(height: 10),
            _buildBenefitItem(Icons.home_rounded, 'Request home visits'),
            const SizedBox(height: 10),
            _buildBenefitItem(
              Icons.chat_rounded,
              'Chat with healthcare providers',
            ),
            const SizedBox(height: 10),
            _buildBenefitItem(
              Icons.history_rounded,
              'Access your medical history',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white.withValues(alpha: 0.9)),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 1.5),
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
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Continue to Login',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: AppColors.primary600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Animated celebration dots
          _buildCelebrationDots(),
        ],
      ),
    );
  }

  Widget _buildCelebrationDots() {
    return AnimatedBuilder(
      animation: _celebrationController,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(7, (index) {
            final delay = index * 0.12;
            final progress = (_celebrationController.value + delay) % 1.0;
            final scale = 0.5 + math.sin(progress * math.pi) * 0.5;
            final colors = [
              const Color(0xFFFFD700),
              Colors.white,
              const Color(0xFF00D47F),
              const Color(0xFF87CEEB),
              Colors.white,
              const Color(0xFF98FB98),
              const Color(0xFFFFD700),
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

// Animated Badge Painter
class AnimatedBadgePainter extends CustomPainter {
  final double rotation;

  AnimatedBadgePainter({required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.2;

    // Shadow
    final shadowPaint =
        Paint()
          ..color = AppColors.primary500.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(center, radius + 5, shadowPaint);

    // Badge with gradient
    final gradient = SweepGradient(
      colors: [
        AppColors.primary400,
        AppColors.primary500,
        AppColors.primary600,
        AppColors.primary500,
        AppColors.primary400,
      ],
      transform: GradientRotation(rotation),
    );

    final paint =
        Paint()
          ..shader = gradient.createShader(
            Rect.fromCircle(center: center, radius: radius),
          )
          ..style = PaintingStyle.fill;

    // Draw star badge shape
    final path = Path();
    const points = 12;

    for (int i = 0; i < points; i++) {
      final angle = (i * 2 * math.pi / points) - math.pi / 2 + rotation;
      final isOuter = i % 2 == 0;
      final r = isOuter ? radius : radius * 0.82;

      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);

    // Inner circle
    final innerPaint =
        Paint()
          ..color = const Color(0xFF25A85C)
          ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.65, innerPaint);

    // Highlight
    final highlightPaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.2)
          ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(center.dx - radius * 0.2, center.dy - radius * 0.2),
      radius * 0.15,
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(AnimatedBadgePainter oldDelegate) =>
      rotation != oldDelegate.rotation;
}

// Celebration Particle
class CelebrationParticle {
  double x;
  double y;
  double size;
  double speed;
  Color color;
  double rotation;
  int shape;

  CelebrationParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.color,
    required this.rotation,
    required this.shape,
  });
}

// Celebration Painter
class CelebrationPainter extends CustomPainter {
  final List<CelebrationParticle> particles;
  final double progress;

  CelebrationPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint =
          Paint()
            ..color = particle.color.withValues(alpha: 0.5)
            ..style = PaintingStyle.fill;

      final y = (particle.y + progress * particle.speed) % 1.0;
      final x =
          particle.x +
          math.sin(progress * math.pi * 2 + particle.rotation) * 0.03;

      canvas.save();
      canvas.translate(x * size.width, y * size.height);
      canvas.rotate(progress * math.pi * 2 * particle.speed);

      switch (particle.shape) {
        case 0: // Circle
          canvas.drawCircle(Offset.zero, particle.size / 2, paint);
          break;
        case 1: // Star
          _drawStar(canvas, particle.size, paint);
          break;
        case 2: // Diamond
          _drawDiamond(canvas, particle.size, paint);
          break;
      }

      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 4 * math.pi / 5) - math.pi / 2;
      final point = Offset(
        math.cos(angle) * size / 2,
        math.sin(angle) * size / 2,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawDiamond(Canvas canvas, double size, Paint paint) {
    final path = Path();
    path.moveTo(0, -size / 2);
    path.lineTo(size / 2, 0);
    path.lineTo(0, size / 2);
    path.lineTo(-size / 2, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CelebrationPainter oldDelegate) => true;
}
