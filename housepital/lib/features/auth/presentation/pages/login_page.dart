import 'package:flutter/material.dart';
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
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Initialize repository
  late final AuthRepositoryImpl _authRepository;

  @override
  void initState() {
    super.initState();
    final apiService = ApiService();
    final remoteDataSource = AuthRemoteDataSourceImpl(apiService: apiService);
    _authRepository = AuthRepositoryImpl(remoteDataSource: remoteDataSource);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Debug print
    print('🔵 Login button pressed!');

    // Manual validation with popup messages
    if (_emailController.text.trim().isEmpty) {
      CustomPopup.warning(context, 'Please enter your email');
      return;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      CustomPopup.warning(context, 'Please enter a valid email');
      return;
    }

    if (_passwordController.text.isEmpty) {
      CustomPopup.warning(context, 'Please enter your password');
      return;
    }
    if (_passwordController.text.length < 6) {
      CustomPopup.warning(context, 'Password must be at least 6 characters');
      return;
    }

    print('✅ Validation passed');

    setState(() {
      _isLoading = true;
    });

    print('🔄 Starting login API call...');

    try {
      // Create login request
      final request = LoginRequest(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      print('📤 Sending login request: ${request.toString()}');

      // Call API
      final response = await _authRepository.login(request);

      print('📥 Response received: ${response.toString()}');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (response.success) {
          print('🎉 Login successful!');

          // Save the token if available
          if (response.token != null) {
            await TokenManager.saveToken(response.token!);
            print('🔑 Token saved successfully');
          }

          // Save the user ID if available
          if (response.user != null && response.user!.id.isNotEmpty) {
            await TokenManager.saveUserId(response.user!.id);
            print('🆔 User ID saved successfully: ${response.user!.id}');
          }

          CustomPopup.success(context, response.message);

          // Navigate based on user role
          if (response.user != null) {
            final role = response.user!.role;
            print('👤 User role: $role');

            // Navigate and remove all previous routes
            Navigator.pushNamedAndRemoveUntil(
              context,
              _getHomeRouteForRole(role),
              (route) => false,
            );
          } else {
            // Default to customer home if no user data
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.customerHome,
              (route) => false,
            );
          }
        } else {
          print('❌ Login failed: ${response.message}');
          CustomPopup.error(context, 'Invalid email or password');
        }
      }
    } on UnauthorizedException catch (e) {
      print('❌ Unauthorized: ${e.message}');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        CustomPopup.error(context, 'Invalid email or password');
      }
    } on NetworkException catch (e) {
      print('❌ Network error: ${e.message}');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        CustomPopup.error(context, 'No internet connection');
      }
    } on ServerException catch (e) {
      print('❌ Server error: ${e.message}');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        CustomPopup.error(context, 'Server error. Please try again');
      }
    } catch (e) {
      print('❌ Unexpected error: ${e.toString()}');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
        return AppRoutes.customerHome; // Or create admin route
      default:
        return AppRoutes.customerHome;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Green Wave
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),

                      // Logo
                      Image.asset(
                        'assets/images/WhiteLogo.png',
                        width: 200,
                        height: 200,
                        fit: BoxFit.contain,
                      ),

                      // App Name
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

                      // Tagline
                      const Text(
                        'AI-Powered Home Nursing',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // White Container
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
                            // Email Field
                            const Text(
                              'Email or phone number',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
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
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 1,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
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

                            // Password Field
                            const Text(
                              'Password',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
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
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 1,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
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

                            // Remember Me & Forgot Password
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
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
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

                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary500,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  disabledBackgroundColor: AppColors.primary500
                                      .withOpacity(0.6),
                                ),
                                child:
                                    _isLoading
                                        ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : const Text(
                                          'Log In',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Register Link
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
                      const SizedBox(height: 20),
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
}

// Wave Painter
class SplashWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.7);

    path.cubicTo(
      size.width * 0.95,
      size.height * 0.75,
      size.width * 0.85,
      size.height * 0.82,
      size.width * 0.7,
      size.height * 0.86,
    );

    path.cubicTo(
      size.width * 0.55,
      size.height * 0.90,
      size.width * 0.45,
      size.height * 0.91,
      size.width * 0.3,
      size.height * 0.88,
    );

    path.cubicTo(
      size.width * 0.2,
      size.height * 0.86,
      size.width * 0.1,
      size.height * 0.78,
      0,
      size.height * 0.65,
    );

    path.close();

    final paint =
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
          ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);

    // Border
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

    // Overlay
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

    // Decorative circles
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
