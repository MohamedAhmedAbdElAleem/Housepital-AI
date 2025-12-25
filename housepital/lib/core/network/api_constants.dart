class ApiConstants {
  // Base URL for the API
  // For Android Emulator: Use 10.0.2.2 (maps to localhost on your computer)
  // For Physical Device: Use your computer's actual IP address
  static const String baseUrl = 'http://10.0.2.2:3500';

  // API Endpoints
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String getCurrentUser = '/api/auth/me';

  // OTP Endpoints
  static const String otpRequest = '/api/otp/request';
  static const String otpVerify = '/api/otp/verify';
  static const String otpResend = '/api/otp/resend';
  static const String resetPassword = '/api/otp/reset-password';

  // Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Timeout durations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
