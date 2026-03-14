import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_routes.dart';
import '../cubit/auth_cubit.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  String _selectedRole = 'doctor'; // Default role
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2664EC), // Primary Blue
                  Color(0xFF3498BB), // Secondary Cyan
                ],
              ),
            ),
          ),

          // 2. Decorative Circles
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),

          // 3. Content
          BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              } else if (state is AuthAuthenticated) {
                _navigateToDashboard(state.user.role);
              }
            },
            builder: (context, state) {
              final isLoading = state is AuthLoading;

              return SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: _slideAnim,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Header Logo
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.medical_services_rounded,
                                size: 50,
                                color: AppColors.primary500,
                              ),
                            ),
                            const SizedBox(height: 24),

                            const Text(
                              'JOIN OUR TEAM',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Create your staff account',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 40),

                            // GLASSMORPHISM CARD
                            ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 10,
                                  sigmaY: 10,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.5),
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 16,
                                        offset: Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        const SizedBox(height: 16),

                                        // Name Input
                                        TextFormField(
                                          controller: _nameController,
                                          decoration: _buildInputDecoration(
                                            'Full Name',
                                            Icons.person_outline,
                                          ),
                                          validator:
                                              (val) =>
                                                  (val == null || val.isEmpty)
                                                      ? 'Name is required'
                                                      : null,
                                        ),
                                        const SizedBox(height: 16),

                                        // Email Input
                                        TextFormField(
                                          controller: _emailController,
                                          decoration: _buildInputDecoration(
                                            'Email Address',
                                            Icons.email_outlined,
                                          ),
                                          validator:
                                              (val) =>
                                                  (val == null ||
                                                          !val.contains('@'))
                                                      ? 'Invalid email'
                                                      : null,
                                        ),
                                        const SizedBox(height: 16),

                                        // Mobile Number Input
                                        TextFormField(
                                          controller: _mobileController,
                                          keyboardType: TextInputType.phone,
                                          decoration: _buildInputDecoration(
                                            'Mobile Number',
                                            Icons.phone_outlined,
                                          ),
                                          validator: (val) {
                                            if (val == null || val.isEmpty) {
                                              return 'Mobile number is required';
                                            }
                                            // Egyptian mobile number validation (11 digits starting with 01)
                                            if (!RegExp(
                                              r'^01[0125][0-9]{8}$',
                                            ).hasMatch(val)) {
                                              return 'Enter valid Egyptian mobile (e.g., 01012345678)';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 16),

                                        // Password Input
                                        TextFormField(
                                          controller: _passwordController,
                                          obscureText: !_isPasswordVisible,
                                          decoration: _buildInputDecoration(
                                            'Password',
                                            Icons.lock_outline,
                                          ).copyWith(
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _isPasswordVisible
                                                    ? Icons.visibility
                                                    : Icons.visibility_off,
                                                color: AppColors.primary500,
                                              ),
                                              onPressed:
                                                  () => setState(
                                                    () =>
                                                        _isPasswordVisible =
                                                            !_isPasswordVisible,
                                                  ),
                                            ),
                                          ),
                                          validator:
                                              (val) =>
                                                  (val == null ||
                                                          val.length < 6)
                                                      ? 'Password must be at least 6 characters'
                                                      : null,
                                        ),
                                        const SizedBox(height: 16),

                                        // Confirm Password Input
                                        TextFormField(
                                          controller:
                                              _confirmPasswordController,
                                          obscureText:
                                              !_isConfirmPasswordVisible,
                                          decoration: _buildInputDecoration(
                                            'Confirm Password',
                                            Icons.lock_outline,
                                          ).copyWith(
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _isConfirmPasswordVisible
                                                    ? Icons.visibility
                                                    : Icons.visibility_off,
                                                color: AppColors.primary500,
                                              ),
                                              onPressed:
                                                  () => setState(
                                                    () =>
                                                        _isConfirmPasswordVisible =
                                                            !_isConfirmPasswordVisible,
                                                  ),
                                            ),
                                          ),
                                          validator:
                                              (val) =>
                                                  (val !=
                                                          _passwordController
                                                              .text)
                                                      ? 'Passwords do not match'
                                                      : null,
                                        ),
                                        const SizedBox(height: 20),

                                        // Role Selection
                                        const Text(
                                          'Select Your Role',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildRoleCard(
                                                'Doctor',
                                                Icons.medical_services,
                                                'doctor',
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: _buildRoleCard(
                                                'Nurse',
                                                Icons.local_hospital,
                                                'nurse',
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 24),

                                        // Register Button
                                        ElevatedButton(
                                          onPressed:
                                              isLoading
                                                  ? null
                                                  : _onRegisterPressed,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.primary500,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 18,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            elevation: 5,
                                            shadowColor: AppColors.primary500
                                                .withOpacity(0.4),
                                          ),
                                          child:
                                              isLoading
                                                  ? const SizedBox(
                                                    height: 24,
                                                    width: 24,
                                                    child:
                                                        CircularProgressIndicator(
                                                          color: Colors.white,
                                                          strokeWidth: 2,
                                                        ),
                                                  )
                                                  : const Text(
                                                    'CREATE ACCOUNT',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      letterSpacing: 1,
                                                    ),
                                                  ),
                                        ),
                                        const SizedBox(height: 16),

                                        // Back to Login
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(context),
                                          child: const Text(
                                            'Already have an account? Login',
                                            style: TextStyle(
                                              color: AppColors.primary500,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            Text(
                              'v1.0.0 • Housepital Inc.',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(String title, IconData icon, String role) {
    final isSelected = _selectedRole == role;
    return InkWell(
      onTap: () => setState(() => _selectedRole = role),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primary500.withOpacity(0.1)
                  : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary500 : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary500 : Colors.grey[600],
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? AppColors.primary500 : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primary500),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary500, width: 2),
      ),
    );
  }

  void _onRegisterPressed() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        mobile: _mobileController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
      );
    }
  }

  void _navigateToDashboard(String role) {
    String route;
    // Auto-detect role and navigate accordingly
    switch (role.toLowerCase()) {
      case 'doctor':
        route = AppRoutes.doctorHome;
        break;
      case 'nurse':
        route = AppRoutes.nurseHome;
        break;
      case 'admin':
        route = AppRoutes.adminDashboard;
        break;
      default:
        route = AppRoutes.login;
    }
    Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
  }
}
