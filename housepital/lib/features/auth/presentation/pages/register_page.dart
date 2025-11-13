import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/widgets/custom_popup.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/models/register_request.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedCountryCode = '+20';

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
    _fullNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    // Add debug print
    print('🔵 Register button pressed!');

    // Manual validation with popup messages
    if (_fullNameController.text.trim().isEmpty) {
      CustomPopup.warning(context, 'Please enter your full name');
      return;
    }
    if (_fullNameController.text.trim().length < 3) {
      CustomPopup.warning(context, 'Name must be at least 3 characters');
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      CustomPopup.warning(context, 'Please enter your email');
      return;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      CustomPopup.warning(context, 'Please enter a valid email');
      return;
    }

    if (_mobileController.text.trim().isEmpty) {
      CustomPopup.warning(context, 'Please enter your mobile number');
      return;
    }
    final phoneRegex = RegExp(r'^01[0125][0-9]{8}$');
    if (!phoneRegex.hasMatch(_mobileController.text.trim())) {
      CustomPopup.warning(context, 'Invalid Egyptian mobile number');
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

    if (_confirmPasswordController.text.isEmpty) {
      CustomPopup.warning(context, 'Please confirm your password');
      return;
    }
    if (_confirmPasswordController.text != _passwordController.text) {
      CustomPopup.warning(context, 'Passwords do not match');
      return;
    }

    // Check terms agreement
    if (!_agreeToTerms) {
      print('❌ Terms not agreed');
      CustomPopup.warning(context, 'Please agree to Terms of Service');
      return;
    }

    print('✅ All validation passed');

    setState(() {
      _isLoading = true;
    });

    print('🔄 Starting API call...');

    try {
      // Create register request
      final request = RegisterRequest(
        name: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        mobile: _mobileController.text.trim(), // Send without country code
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      );

      print('📤 Sending request: ${request.toString()}');

      // Call API
      final response = await _authRepository.register(request);

      print('📥 Response received: ${response.toString()}');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (response.success) {
          print('🎉 Registration successful!');
          CustomPopup.success(context, response.message);
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.of(context).pushNamed(AppRoutes.login);
            }
          });
        } else {
          print('❌ Registration failed: ${response.message}');
          // Show the actual error message from server
          CustomPopup.error(context, response.message);
        }
      }
    } on ValidationException catch (e) {
      print('❌ Validation error: ${e.toString()}');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Show the actual validation error
        CustomPopup.error(context, 'Please check your information');
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
        // Show the actual server error message
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // الموجة الخضراء
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.40,
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
                      const SizedBox(height: 5),

                      // Logo
                      Image.asset(
                        'assets/images/WhiteLogo.png',
                        width: 110,
                        height: 110,
                        fit: BoxFit.contain,
                      ),

                      const SizedBox(height: 4),

                      // App Name
                      const Text(
                        'Housepital',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 2),

                      // Tagline
                      const Text(
                        'AI-Powered Home Nursing',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // White Container
                      Container(
                        padding: const EdgeInsets.all(16),
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Full Name
                            _buildTextField(
                              label: 'Full Name',
                              hint: 'Enter your full name',
                              controller: _fullNameController,
                            ),

                            const SizedBox(height: 10),

                            // Email
                            _buildTextField(
                              label: 'Email',
                              hint: 'You@example.com',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                            ),

                            const SizedBox(height: 10),

                            // Mobile Number
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Mobile Number',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 70,
                                      height: 48,
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: _selectedCountryCode,
                                          isExpanded: true,
                                          items:
                                              [
                                                    '+20',
                                                    '+1',
                                                    '+44',
                                                    '+971',
                                                    '+966',
                                                  ]
                                                  .map(
                                                    (code) => DropdownMenuItem(
                                                      value: code,
                                                      child: Text(
                                                        code,
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color:
                                                              Colors
                                                                  .grey
                                                                  .shade700,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedCountryCode = value!;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _mobileController,
                                        keyboardType: TextInputType.phone,
                                        decoration: InputDecoration(
                                          hintText: '1012345678',
                                          hintStyle: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontSize: 14,
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey.shade50,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide(
                                              color: AppColors.primary500,
                                              width: 2,
                                            ),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Colors.red,
                                              width: 1,
                                            ),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: const BorderSide(
                                                  color: Colors.red,
                                                  width: 2,
                                                ),
                                              ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 12,
                                              ),
                                          errorStyle: const TextStyle(
                                            fontSize: 11,
                                            height: 0.8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // Password
                            _buildPasswordField(
                              label: 'Password',
                              hint: 'Enter Your password',
                              controller: _passwordController,
                              obscure: _obscurePassword,
                              onToggle: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),

                            const SizedBox(height: 10),

                            // Confirm Password
                            _buildPasswordField(
                              label: 'Confirm Password',
                              hint: 'Confirm your password',
                              controller: _confirmPasswordController,
                              obscure: _obscureConfirmPassword,
                              onToggle: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),

                            const SizedBox(height: 10),

                            // Terms Checkbox
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Checkbox(
                                  value: _agreeToTerms,
                                  onChanged: (value) {
                                    setState(() {
                                      _agreeToTerms = value ?? false;
                                    });
                                  },
                                  activeColor: AppColors.primary500,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black87,
                                      ),
                                      children: [
                                        const TextSpan(text: 'I agree to the '),
                                        TextSpan(
                                          text: 'terms of Service',
                                          style: TextStyle(
                                            color: AppColors.primary500,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const TextSpan(text: ' and '),
                                        TextSpan(
                                          text: 'Privacy Policy.',
                                          style: TextStyle(
                                            color: AppColors.primary500,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Create Account Button
                            SizedBox(
                              width: double.infinity,
                              height: 46,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleRegister,
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
                                          'Create Account',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                              ),
                            ),

                            const SizedBox(height: 6),

                            // Login Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Already has account ?',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(
                                      context,
                                    ).pushNamed(AppRoutes.login);
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.only(left: 4),
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Log In',
                                    style: TextStyle(
                                      fontSize: 13,
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
                      const SizedBox(height: 10),
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

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary500, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            errorStyle: const TextStyle(fontSize: 11, height: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary500, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            errorStyle: const TextStyle(fontSize: 11, height: 0.8),
            suffixIcon: IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.grey.shade600,
                size: 22,
              ),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
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
