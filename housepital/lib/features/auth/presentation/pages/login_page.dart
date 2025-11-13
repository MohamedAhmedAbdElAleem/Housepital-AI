import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;
  bool _rememberMe = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // الموجة الخضراء البسيطة
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.65,
            child: CustomPaint(painter: SplashWavePainter()),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),

                    // اللوجو
                    Image.asset(
                      'assets/images/WhiteLogo.png',
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                    ),

                    // اسم التطبيق
                    const Text(
                      'Housepital',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // النص الوصفي
                    const Text(
                      'AI-Powered Home Nursing',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // صندوق تسجيل الدخول الأبيض
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // حقل البريد الإلكتروني أو رقم الهاتف
                          const Text(
                            'Email or phone number',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              hintText: 'Enter Text Here',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: AppColors.primary500,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // حقل كلمة المرور
                          const Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: 'Enter Your password',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: AppColors.primary500,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.grey.shade600,
                                  size: 22,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // تذكرني ونسيت كلمة المرور
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      onChanged: (value) {
                                        setState(() {
                                          _rememberMe = value ?? false;
                                        });
                                      },
                                      activeColor: AppColors.primary500,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      side: BorderSide(
                                        color: Colors.grey.shade400,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Remember Me',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {
                                  // TODO: Navigate to forgot password
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Forget Password?',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.primary500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // زر تسجيل الدخول
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                // TODO: Implement login logic
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary500,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Log In',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // إنشاء حساب جديد
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't Have Account ?",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(
                                    context,
                                  ).pushNamed(AppRoutes.register);
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.only(left: 4),
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Create one Now !',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.primary500,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// رسم الموجة الخضراء (نفس Onboarding)
class SplashWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // الشكل الأساسي مع Gradient
    final path = Path();

    // البداية من أعلى اليسار
    path.moveTo(0, 0);

    // خط لأعلى اليمين
    path.lineTo(size.width, 0);

    // خط لأسفل اليمين مع منحنى
    path.lineTo(size.width, size.height * 0.7);

    // موجة احترافية على الجانب الأيمن
    path.cubicTo(
      size.width * 0.95,
      size.height * 0.75,
      size.width * 0.85,
      size.height * 0.82,
      size.width * 0.7,
      size.height * 0.86,
    );

    // موجة وسطى
    path.cubicTo(
      size.width * 0.55,
      size.height * 0.90,
      size.width * 0.45,
      size.height * 0.91,
      size.width * 0.3,
      size.height * 0.88,
    );

    // موجة على اليسار
    path.cubicTo(
      size.width * 0.2,
      size.height * 0.86,
      size.width * 0.1,
      size.height * 0.78,
      0,
      size.height * 0.65,
    );

    // إغلاق المسار
    path.close();

    // رسم الشكل الأساسي مع Gradient
    final paint =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF2ECC71), const Color(0xFF27AE60)],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
          ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);

    // رسم border أسود على نهاية الموجة
    final borderPath = Path();
    borderPath.moveTo(size.width, size.height * 0.7);
    borderPath.cubicTo(
      size.width * 0.95,
      size.height * 0.75,
      size.width * 0.85,
      size.height * 0.82,
      size.width * 0.7,
      size.height * 0.86,
    );
    borderPath.cubicTo(
      size.width * 0.55,
      size.height * 0.90,
      size.width * 0.45,
      size.height * 0.91,
      size.width * 0.3,
      size.height * 0.88,
    );
    borderPath.cubicTo(
      size.width * 0.2,
      size.height * 0.86,
      size.width * 0.1,
      size.height * 0.78,
      0,
      size.height * 0.65,
    );

    final borderPaint =
        Paint()
          ..color = Colors.black.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5;

    canvas.drawPath(borderPath, borderPaint);

    // إضافة طبقة شفافة للعمق
    final overlayPath = Path();
    overlayPath.moveTo(0, size.height * 0.1);

    overlayPath.cubicTo(
      size.width * 0.3,
      size.height * 0.15,
      size.width * 0.7,
      size.height * 0.05,
      size.width,
      size.height * 0.12,
    );

    overlayPath.lineTo(size.width, 0);
    overlayPath.lineTo(0, 0);
    overlayPath.close();

    final overlayPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.15)
          ..style = PaintingStyle.fill;

    canvas.drawPath(overlayPath, overlayPaint);

    // إضافة دوائر زخرفية
    final circlePaint =
        Paint()
          ..color = Colors.white.withOpacity(0.1)
          ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.15),
      30,
      circlePaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.25),
      20,
      circlePaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.75, size.height * 0.55),
      25,
      circlePaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// رسم الموجة في الخلفية
class BackgroundWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    final path = Path();

    for (int i = 0; i < 5; i++) {
      path.reset();
      final offset = i * 15.0;

      path.moveTo(offset, size.height * 0.3);
      path.quadraticBezierTo(
        size.width * 0.15 + offset,
        size.height * 0.2,
        size.width * 0.3 + offset,
        size.height * 0.3,
      );
      path.quadraticBezierTo(
        size.width * 0.45 + offset,
        size.height * 0.4,
        size.width * 0.6 + offset,
        size.height * 0.3,
      );

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
