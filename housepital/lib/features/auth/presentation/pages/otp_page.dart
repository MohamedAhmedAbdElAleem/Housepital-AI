import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
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

  const OTPPage({Key? key, required this.email}) : super(key: key);

  @override
  State<OTPPage> createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  int _secondsRemaining = 600; // 10:00 (10 minutes)
  Timer? _timer;
  bool _isLoading = false;
  bool _canResend = true;
  int _currentAttempts = 0; // عداد المحاولات الفاشلة
  int _maxAttempts = 5; // الحد الأقصى للمحاولات
  bool _isLocked = false; // حالة القفل بعد 5 محاولات

  // Initialize repository
  late final OTPRepositoryImpl _otpRepository;

  @override
  void initState() {
    super.initState();
    final apiService = ApiService();
    final remoteDataSource = OTPRemoteDataSourceImpl(apiService: apiService);
    _otpRepository = OTPRepositoryImpl(remoteDataSource: remoteDataSource);

    _startTimer();
    // إرسال OTP تلقائياً عند فتح الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendOTP();
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
        setState(() {
          _canResend = true;
        });
      }
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _sendOTP() async {
    setState(() {
      _isLoading = true;
    });

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
      if (mounted) {
        CustomPopup.error(context, 'No internet connection');
      }
    } on ServerException {
      if (mounted) {
        CustomPopup.error(context, 'Failed to send code. Please try again.');
      }
    } catch (e) {
      if (mounted) {
        CustomPopup.error(context, 'Something went wrong');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _verifyOTP() async {
    // التحقق من حالة القفل
    if (_isLocked) {
      CustomPopup.error(
        context,
        'Too many failed attempts. Please request a new code.',
      );
      return;
    }

    // Get OTP code
    String otpCode = _controllers.map((c) => c.text).join();

    if (otpCode.length != 6) {
      CustomPopup.warning(context, 'Please enter the complete 6-digit code');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = OTPVerifyRequest(contact: widget.email, code: otpCode);

      final response = await _otpRepository.verifyOTP(request);

      if (mounted) {
        if (response.success) {
          // إعادة تعيين العداد عند النجاح
          setState(() {
            _currentAttempts = 0;
          });
          CustomPopup.success(context, 'Email verified successfully!');
          // Navigate to Verify Identity page
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.of(
                context,
              ).pushReplacementNamed(AppRoutes.verifyIdentity);
            }
          });
        } else {
          // زيادة عداد المحاولات عند الفشل
          setState(() {
            _currentAttempts++;
            if (_currentAttempts >= _maxAttempts) {
              _isLocked = true;
            }
          });

          // رسالة خطأ مع عدد المحاولات المتبقية
          int remainingAttempts = _maxAttempts - _currentAttempts;
          if (_isLocked) {
            CustomPopup.error(
              context,
              'Account locked! Please request a new code.',
            );
          } else {
            CustomPopup.error(
              context,
              'Invalid code. $remainingAttempts ${remainingAttempts == 1 ? "attempt" : "attempts"} remaining.',
            );
          }
        }
      }
    } on ValidationException {
      setState(() {
        _currentAttempts++;
        if (_currentAttempts >= _maxAttempts) {
          _isLocked = true;
        }
      });

      if (mounted) {
        int remainingAttempts = _maxAttempts - _currentAttempts;
        if (_isLocked) {
          CustomPopup.error(
            context,
            'Account locked! Please request a new code.',
          );
        } else {
          CustomPopup.error(
            context,
            'Invalid code. $remainingAttempts ${remainingAttempts == 1 ? "attempt" : "attempts"} remaining.',
          );
        }
      }
    } on NetworkException {
      if (mounted) {
        CustomPopup.error(context, 'No internet connection');
      }
    } on ServerException catch (e) {
      // التحقق من رمز 429 (Too Many Requests)
      if (e.toString().contains('429')) {
        setState(() {
          _isLocked = true;
          _currentAttempts = _maxAttempts;
        });
        if (mounted) {
          CustomPopup.error(
            context,
            'Too many failed attempts. Please request a new code.',
          );
        }
      } else {
        if (mounted) {
          CustomPopup.error(context, 'Server error. Please try again.');
        }
      }
    } catch (e) {
      if (mounted) {
        CustomPopup.error(context, 'Something went wrong');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendOTP() async {
    if (!_canResend) {
      CustomPopup.warning(context, 'Please wait before requesting a new code');
      return;
    }

    setState(() {
      _canResend = false;
      _secondsRemaining = 600; // 10:00 (10 minutes)
      _currentAttempts = 0; // إعادة تعيين عداد المحاولات
      _isLocked = false; // إلغاء القفل
      // Clear all fields
      for (var controller in _controllers) {
        controller.clear();
      }
    });

    _timer?.cancel();
    _startTimer();

    try {
      final response = await _otpRepository.resendOTP(widget.email);

      if (mounted && response.success) {
        CustomPopup.success(context, 'New verification code sent!');
      }
    } on NetworkException {
      if (mounted) {
        CustomPopup.error(context, 'No internet connection');
      }
    } on ServerException {
      if (mounted) {
        CustomPopup.error(context, 'Failed to resend code. Please try again.');
      }
    } catch (e) {
      if (mounted) {
        CustomPopup.error(context, 'Something went wrong');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary500,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // زر الرجوع
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.black87,
                          size: 20,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // اللوجو
                  Image.asset(
                    'assets/images/Logo.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 24),

                  // العنوان
                  const Text(
                    'Verify your email',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // النص الوصفي
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Enter the 6-digit code sent to:\n',
                        ),
                        TextSpan(
                          text: widget.email,
                          style: TextStyle(
                            color: AppColors.primary500,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // حقول OTP
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 45,
                        height: 50,
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1.5,
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
                              vertical: 12,
                            ),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (value) {
                            if (value.isNotEmpty && index < 5) {
                              _focusNodes[index + 1].requestFocus();
                            } else if (value.isEmpty && index > 0) {
                              _focusNodes[index - 1].requestFocus();
                            }
                          },
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 24),

                  // عداد الوقت والمحاولات
                  Column(
                    children: [
                      Text(
                        'Code expires in ${_formatTime(_secondsRemaining)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (_currentAttempts > 0 && !_isLocked) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Attempt ${_currentAttempts} of $_maxAttempts',
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                _currentAttempts >= 3
                                    ? Colors.orange.shade700
                                    : Colors.grey.shade600,
                            fontWeight:
                                _currentAttempts >= 3
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                          ),
                        ),
                      ],
                      if (_isLocked) ...[
                        const SizedBox(height: 8),
                        Text(
                          '⚠️ Account locked - Request new code',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 16),

                  // إعادة إرسال الكود
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Didn't receive a code?",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      TextButton(
                        onPressed:
                            _canResend && !_isLoading ? _resendOTP : null,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.only(left: 4),
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Resend code',
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                _canResend ? AppColors.primary500 : Colors.grey,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor:
                                _canResend ? AppColors.primary500 : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // زر التحقق
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _verifyOTP,
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
                                'Verify',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
}
