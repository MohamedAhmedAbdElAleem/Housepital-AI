import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/custom_popup.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/error/exceptions.dart';
import '../../data/datasources/otp_remote_datasource.dart';
import '../../data/repositories/otp_repository_impl.dart';
import '../../data/models/otp_models.dart';

class OTPPage extends StatefulWidget {
  final String email;

  const OTPPage({super.key, required this.email});

  @override
  State<OTPPage> createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> with TickerProviderStateMixin {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final List<bool> _isFocused = List.generate(6, (index) => false);
  final List<bool> _isFilled = List.generate(6, (index) => false);

  int _secondsRemaining = 600;
  Timer? _timer;
  bool _isLoading = false;
  bool _canResend = true;
  int _currentAttempts = 0;
  final int _maxAttempts = 5;
  bool _isLocked = false;
  bool _isSuccess = false;

  // Animation controllers
  late AnimationController _mainController;
  late AnimationController _floatingController;
  late AnimationController _shakeController;
  late AnimationController _successController;
  late AnimationController _pulseController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _successScaleAnimation;
  late Animation<double> _pulseAnimation;

  late final OTPRepositoryImpl _otpRepository;

  @override
  void initState() {
    super.initState();
    _initRepository();
    _initAnimations();
    _initFocusListeners();
    _startTimer();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendOTP();
    });
  }

  void _initRepository() {
    final apiService = ApiService();
    final remoteDataSource = OTPRemoteDataSourceImpl(apiService: apiService);
    _otpRepository = OTPRepositoryImpl(remoteDataSource: remoteDataSource);
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

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _successScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _mainController.forward();

    // Auto-focus on first OTP field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
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
        timer.cancel();
        setState(() => _canResend = true);
      }
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _triggerShake() {
    _shakeController.forward().then((_) => _shakeController.reset());
  }

  void _updateFilledState() {
    for (int i = 0; i < 6; i++) {
      _isFilled[i] = _controllers[i].text.isNotEmpty;
    }
  }

  Future<void> _sendOTP() async {
    setState(() => _isLoading = true);

    try {
      final request = OTPRequest(
        contact: widget.email,
        contactType: 'email',
        purpose: 'email_verification',
      );

      final response = await _otpRepository.requestOTP(request);

      if (mounted && response.success) {
        CustomPopup.success(context, 'Verification code sent to your email');
      }
    } on NetworkException {
      if (mounted) CustomPopup.error(context, 'No internet connection');
    } on ServerException {
      if (mounted) CustomPopup.error(context, 'Failed to send code');
    } catch (e) {
      if (mounted) CustomPopup.error(context, 'Something went wrong');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOTP() async {
    if (_isLocked) {
      _triggerShake();
      CustomPopup.error(
        context,
        'Too many failed attempts. Request a new code.',
      );
      return;
    }

    String otpCode = _controllers.map((c) => c.text).join();

    if (otpCode.length != 6) {
      _triggerShake();
      CustomPopup.warning(context, 'Please enter the complete 6-digit code');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final request = OTPVerifyRequest(contact: widget.email, code: otpCode);
      final response = await _otpRepository.verifyOTP(request);

      if (mounted) {
        if (response.success) {
          setState(() {
            _currentAttempts = 0;
            _isSuccess = true;
          });
          _successController.forward();
          CustomPopup.success(context, 'Email verified successfully!');
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.of(
                context,
              ).pushReplacementNamed(AppRoutes.verifyIdentity);
            }
          });
        } else {
          _handleFailedAttempt();
        }
      }
    } on ValidationException {
      _handleFailedAttempt();
    } on NetworkException {
      if (mounted) CustomPopup.error(context, 'No internet connection');
    } on ServerException catch (e) {
      if (e.toString().contains('429')) {
        setState(() {
          _isLocked = true;
          _currentAttempts = _maxAttempts;
        });
        if (mounted) {
          CustomPopup.error(context, 'Too many failed attempts.');
        }
      } else {
        if (mounted) CustomPopup.error(context, 'Server error');
      }
    } catch (e) {
      if (mounted) CustomPopup.error(context, 'Something went wrong');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleFailedAttempt() {
    _triggerShake();
    setState(() {
      _currentAttempts++;
      if (_currentAttempts >= _maxAttempts) _isLocked = true;
    });

    int remaining = _maxAttempts - _currentAttempts;
    if (_isLocked) {
      CustomPopup.error(context, 'Account locked! Request a new code.');
    } else {
      CustomPopup.error(
        context,
        'Invalid code. $remaining attempts remaining.',
      );
    }
  }

  Future<void> _resendOTP() async {
    if (!_canResend) {
      CustomPopup.warning(context, 'Please wait before requesting new code');
      return;
    }

    setState(() {
      _canResend = false;
      _secondsRemaining = 600;
      _currentAttempts = 0;
      _isLocked = false;
      for (var controller in _controllers) {
        controller.clear();
      }
      _updateFilledState();
    });

    _timer?.cancel();
    _startTimer();

    try {
      final response = await _otpRepository.resendOTP(widget.email);
      if (mounted && response.success) {
        CustomPopup.success(context, 'New verification code sent!');
      }
    } on NetworkException {
      if (mounted) CustomPopup.error(context, 'No internet connection');
    } on ServerException {
      if (mounted) CustomPopup.error(context, 'Failed to resend code');
    } catch (e) {
      if (mounted) CustomPopup.error(context, 'Something went wrong');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _mainController.dispose();
    _floatingController.dispose();
    _shakeController.dispose();
    _successController.dispose();
    _pulseController.dispose();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
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
                      const SizedBox(height: 30),
                      _buildOTPCard(),
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
        top: size.height * 0.15,
        left: size.width * 0.1,
        child: _buildFloatingIcon(Icons.verified_rounded, 22),
      ),
      Positioned(
        top: size.height * 0.22,
        right: size.width * 0.08,
        child: _buildFloatingIcon(Icons.email_rounded, 18),
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
            _buildAnimatedLogo(),
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
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
                    fontWeight: FontWeight.w500,
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

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: _isSuccess ? 1.0 : _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(16),
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
                    : Image.asset(
                      'assets/images/WhiteLogo.png',
                      width: 40,
                      height: 40,
                    ),
          ),
        );
      },
    );
  }

  Widget _buildOTPCard() {
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
            // Timer display
            _buildTimerSection(),
            const SizedBox(height: 28),

            // OTP Fields
            _buildOTPFields(),
            const SizedBox(height: 24),

            // Attempts indicator
            if (_currentAttempts > 0) _buildAttemptsIndicator(),
            if (_currentAttempts > 0) const SizedBox(height: 20),

            // Resend section
            _buildResendSection(),
            const SizedBox(height: 28),

            // Verify button
            _buildVerifyButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerSection() {
    final isExpiring = _secondsRemaining < 60;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isExpiring
                  ? [Colors.red.shade50, Colors.orange.shade50]
                  : [
                    AppColors.primary50,
                    AppColors.primary100.withValues(alpha: 0.5),
                  ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpiring ? Colors.red.shade200 : AppColors.primary200,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isExpiring ? Icons.timer_off_rounded : Icons.timer_rounded,
            color: isExpiring ? Colors.red.shade600 : AppColors.primary600,
            size: 24,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Code expires in',
                style: TextStyle(
                  fontSize: 12,
                  color:
                      isExpiring ? Colors.red.shade600 : AppColors.primary600,
                ),
              ),
              Text(
                _formatTime(_secondsRemaining),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color:
                      isExpiring ? Colors.red.shade700 : AppColors.primary700,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOTPFields() {
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
          children: List.generate(6, (index) => _buildOTPDigitField(index)),
        ),
      ],
    );
  }

  Widget _buildOTPDigitField(int index) {
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
          setState(() => _updateFilledState());
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          // Auto verify when all filled
          if (_controllers.every((c) => c.text.isNotEmpty)) {
            Future.delayed(const Duration(milliseconds: 300), _verifyOTP);
          }
        },
      ),
    );
  }

  Widget _buildAttemptsIndicator() {
    final progress = _currentAttempts / _maxAttempts;
    final isWarning = _currentAttempts >= 3;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:
            _isLocked
                ? Colors.red.shade50
                : (isWarning ? Colors.orange.shade50 : Colors.grey.shade50),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              _isLocked
                  ? Colors.red.shade300
                  : (isWarning ? Colors.orange.shade300 : Colors.grey.shade300),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                _isLocked ? Icons.lock_rounded : Icons.info_outline_rounded,
                color:
                    _isLocked
                        ? Colors.red.shade600
                        : (isWarning
                            ? Colors.orange.shade600
                            : Colors.grey.shade600),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _isLocked
                      ? 'Account locked! Please request a new code'
                      : 'Attempt $_currentAttempts of $_maxAttempts',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color:
                        _isLocked
                            ? Colors.red.shade700
                            : (isWarning
                                ? Colors.orange.shade700
                                : Colors.grey.shade700),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                _isLocked
                    ? Colors.red.shade500
                    : (isWarning
                        ? Colors.orange.shade500
                        : AppColors.primary500),
              ),
              minHeight: 6,
            ),
          ),
        ],
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
          onPressed: _canResend && !_isLoading ? _resendOTP : null,
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
        onPressed: _isLoading || _isLocked ? null : _verifyOTP,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isLocked ? Colors.grey : AppColors.primary500,
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
                    children: [
                      Icon(
                        _isLocked
                            ? Icons.lock_rounded
                            : Icons.verified_user_rounded,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _isLocked ? 'Locked' : 'Verify Email',
                        style: const TextStyle(
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
              Icons.security_rounded,
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
                  'Never share this code with anyone. Our team will never ask for it.',
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
