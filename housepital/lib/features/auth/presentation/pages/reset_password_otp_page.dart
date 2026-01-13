import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/widgets/custom_popup.dart';

class ResetPasswordOtpPage extends StatefulWidget {
  final String email;

  const ResetPasswordOtpPage({super.key, required this.email});

  @override
  State<ResetPasswordOtpPage> createState() => _ResetPasswordOtpPageState();
}

class _ResetPasswordOtpPageState extends State<ResetPasswordOtpPage>
    with TickerProviderStateMixin {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final List<bool> _isFocused = List.generate(6, (_) => false);

  bool _isLoading = false;
  bool _canResend = false;
  bool _isSuccess = false;
  int _secondsRemaining = 600; // 10 minutes
  Timer? _timer;

  // Animation controllers
  late AnimationController _mainController;
  late AnimationController _floatingController;
  late AnimationController _shakeController;
  late AnimationController _pulseController;
  late AnimationController _successController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _successScaleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initFocusListeners();
    _startTimer();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // Auto-focus on first OTP field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  void _initAnimations() {
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _successScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );

    _mainController.forward();
  }

  void _initFocusListeners() {
    for (int i = 0; i < 6; i++) {
      _focusNodes[i].addListener(() {
        setState(() => _isFocused[i] = _focusNodes[i].hasFocus);
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _mainController.dispose();
    _floatingController.dispose();
    _shakeController.dispose();
    _pulseController.dispose();
    _successController.dispose();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _triggerShake() {
    _shakeController.forward().then((_) => _shakeController.reset());
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  Future<void> _verifyOTP() async {
    if (_otpCode.length != 6) {
      _triggerShake();
      CustomPopup.warning(context, 'Please enter the complete 6-digit code');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();
      final response = await apiService.post(
        ApiConstants.otpVerify,
        body: {'contact': widget.email, 'code': _otpCode},
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (response['success'] == true) {
          setState(() => _isSuccess = true);
          _successController.forward();
          CustomPopup.success(context, 'Code verified successfully!');
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) {
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.newPassword,
                arguments: widget.email,
              );
            }
          });
        } else {
          _triggerShake();
          CustomPopup.error(context, response['message'] ?? 'Invalid code');
          _clearFields();
        }
      }
    } on NetworkException {
      if (mounted) {
        setState(() => _isLoading = false);
        _triggerShake();
        CustomPopup.error(context, 'No internet connection');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _triggerShake();
        CustomPopup.error(context, 'Verification failed');
      }
    }
  }

  Future<void> _resendOTP() async {
    if (!_canResend) return;

    setState(() {
      _canResend = false;
      _secondsRemaining = 120;
    });
    _timer?.cancel();
    _startTimer();
    _clearFields();

    try {
      final apiService = ApiService();
      await apiService.post(
        ApiConstants.otpResend,
        body: {'contact': widget.email},
      );
      if (mounted) {
        CustomPopup.success(context, 'New code sent to your email');
      }
    } catch (e) {
      if (mounted) {
        CustomPopup.error(context, 'Failed to resend code');
      }
    }
  }

  void _clearFields() {
    for (var c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          ..._buildFloatingShapes(size),
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
                      const SizedBox(height: 20),
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildCard(),
                      const SizedBox(height: 24),
                      _buildSecurityNote(),
                      const SizedBox(height: 40),
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
      Positioned(
        top: size.height * 0.12,
        left: size.width * 0.08,
        child: _buildFloatingIcon(Icons.lock_reset_rounded, 22),
      ),
      Positioned(
        top: size.height * 0.22,
        right: size.width * 0.1,
        child: _buildFloatingIcon(Icons.email_rounded, 18),
      ),
      Positioned(
        bottom: size.height * 0.2,
        right: size.width * 0.12,
        child: _buildFloatingIcon(Icons.verified_rounded, 16),
      ),
    ];
  }

  Widget _buildFloatingIcon(IconData icon, double iconSize) {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        final offset = math.sin(_floatingController.value * 2 * math.pi) * 10;
        return Transform.translate(
          offset: Offset(0, offset),
          child: Icon(
            icon,
            size: iconSize,
            color: Colors.white.withValues(alpha: 0.12),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          children: [
            _buildBackButton(),
            const Spacer(),
            _buildAnimatedIcon(),
            const Spacer(),
            const SizedBox(width: 48),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Verify Your Email',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
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
          'Enter the 6-digit code sent to:',
          style: TextStyle(
            fontSize: 15,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.mail_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  widget.email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: _isSuccess ? 1.0 : _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child:
                _isSuccess
                    ? AnimatedBuilder(
                      animation: _successController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _successScaleAnimation.value,
                          child: const Icon(
                            Icons.check_circle_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        );
                      },
                    )
                    : const Icon(
                      Icons.mark_email_read_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
          ),
        );
      },
    );
  }

  Widget _buildCard() {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final shake = math.sin(_shakeAnimation.value * math.pi * 4) * 8;
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
          ],
        ),
        child: Column(
          children: [
            // Timer Section
            _buildTimerSection(),
            const SizedBox(height: 28),

            // OTP Fields
            _buildOTPSection(),
            const SizedBox(height: 24),

            // Resend Section
            _buildResendSection(),
            const SizedBox(height: 28),

            // Verify Button
            _buildVerifyButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerSection() {
    final isExpiring = _secondsRemaining < 30;
    final isExpired = _secondsRemaining == 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isExpired
                  ? [Colors.red.shade50, Colors.orange.shade50]
                  : isExpiring
                  ? [Colors.orange.shade50, Colors.amber.shade50]
                  : [
                    AppColors.primary50,
                    AppColors.primary100.withValues(alpha: 0.5),
                  ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isExpired
                  ? Colors.red.shade300
                  : isExpiring
                  ? Colors.orange.shade300
                  : AppColors.primary200,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isExpired
                ? Icons.timer_off_rounded
                : isExpiring
                ? Icons.warning_amber_rounded
                : Icons.timer_rounded,
            color:
                isExpired
                    ? Colors.red.shade600
                    : isExpiring
                    ? Colors.orange.shade600
                    : AppColors.primary600,
            size: 24,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isExpired ? 'Code expired' : 'Code expires in',
                style: TextStyle(
                  fontSize: 12,
                  color:
                      isExpired
                          ? Colors.red.shade600
                          : isExpiring
                          ? Colors.orange.shade600
                          : AppColors.primary600,
                ),
              ),
              Text(
                isExpired ? 'Request new code' : _formatTime(_secondsRemaining),
                style: TextStyle(
                  fontSize: isExpired ? 14 : 26,
                  fontWeight: FontWeight.bold,
                  color:
                      isExpired
                          ? Colors.red.shade700
                          : isExpiring
                          ? Colors.orange.shade700
                          : AppColors.primary700,
                  fontFamily: isExpired ? null : 'monospace',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOTPSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter verification code',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) => _buildOTPField(index)),
        ),
      ],
    );
  }

  Widget _buildOTPField(int index) {
    final isFocusedField = _isFocused[index];
    final isFilledField = _controllers[index].text.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 48,
      height: 58,
      decoration: BoxDecoration(
        color:
            isFilledField
                ? (_isSuccess ? AppColors.success50 : AppColors.primary50)
                : (isFocusedField ? AppColors.primary50 : Colors.grey.shade50),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              isFilledField
                  ? (_isSuccess ? AppColors.success500 : AppColors.primary500)
                  : (isFocusedField
                      ? AppColors.primary500
                      : Colors.grey.shade300),
          width: isFocusedField || isFilledField ? 2 : 1.5,
        ),
        boxShadow:
            isFocusedField
                ? [
                  BoxShadow(
                    color: AppColors.primary500.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
                : [],
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color:
              isFilledField
                  ? (_isSuccess ? AppColors.success700 : AppColors.primary700)
                  : Colors.grey[800],
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          setState(() {});
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          // Auto verify when complete
          if (_otpCode.length == 6) {
            Future.delayed(const Duration(milliseconds: 300), _verifyOTP);
          }
        },
      ),
    );
  }

  Widget _buildResendSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Didn't receive the code?",
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        TextButton(
          onPressed: _canResend ? _resendOTP : null,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.only(left: 6),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.refresh_rounded,
                size: 16,
                color: _canResend ? AppColors.primary500 : Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                'Resend',
                style: TextStyle(
                  fontSize: 14,
                  color: _canResend ? AppColors.primary500 : Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _verifyOTP,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary500,
          foregroundColor: Colors.white,
          elevation: 0,
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
                      Icon(Icons.verified_rounded, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Verify Code',
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
    );
  }

  Widget _buildSecurityNote() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shield_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Security Notice',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'This code is for password reset only. Never share it with anyone.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
