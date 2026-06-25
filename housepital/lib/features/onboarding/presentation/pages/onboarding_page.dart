import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/utils/token_manager.dart';
import '../../../../generated/l10n/app_localizations.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<OnboardingData> _getPages(BuildContext context) {
    return [
      OnboardingData(
        image: 'assets/images/IntroOne.png',
        title: AppLocalizations.of(context)!.onboarding1Title,
        description: AppLocalizations.of(context)!.onboarding1Desc,
      ),
      OnboardingData(
        image: 'assets/images/IntroTwo.png',
        title: AppLocalizations.of(context)!.onboarding2Title,
        description: AppLocalizations.of(context)!.onboarding2Desc,
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPressed(int pagesLength) {
    if (_currentPage < pagesLength - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToLogin();
    }
  }

  Future<void> _navigateToLogin() async {
    // Mark onboarding as seen so it won't show again
    await TokenManager.setOnboardingSeen();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = _getPages(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // PageView للصفحات
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(pages[index], index);
                },
              ),
            ),

            // الجزء السفلي الثابت
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  // مؤشرات التقدم (النقاط)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      pages.length,
                      (index) => _buildDot(index),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // زر Next
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => _onNextPressed(pages.length),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary500,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _currentPage == pages.length - 1
                            ? AppLocalizations.of(context)!.getStarted
                            : AppLocalizations.of(context)!.next,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // زر Skip Intro
                  TextButton(
                    onPressed: _navigateToLogin,
                    child: Text(
                      AppLocalizations.of(context)!.skipIntro,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingData data, int index) {
    final double imageHeight = index == 0 ? 460 : 550;
    final double topPadding = index == 0 ? 40 : 0;

    return Column(
      children: [
        // الجزء العلوي مع الصورة والشكل الأخضر
        Expanded(
          child: Stack(
            children: [
              // الشكل الأخضر المموج في الخلفية
              Positioned.fill(child: CustomPaint(painter: GreenWavePainter())),
              // الصورة
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: topPadding),
                  child: Image.asset(
                    data.image,
                    height: imageHeight,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),

        // النصوص
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // العنوان الرئيسي
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 16),

              // النص الوصفي
              Text(
                data.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 24 : 10,
      height: 10,
      decoration: BoxDecoration(
        color:
            _currentPage == index
                ? AppColors.primary500
                : AppColors.primary500.withOpacity(0.3),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}

// Model للبيانات
class OnboardingData {
  final String image;
  final String title;
  final String description;

  OnboardingData({
    required this.image,
    required this.title,
    required this.description,
  });
}

// كلاس لرسم الشكل الأخضر المموج في الخلفية
class GreenWavePainter extends CustomPainter {
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
