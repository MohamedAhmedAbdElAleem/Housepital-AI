class ApiConstants {
  // Base URL for the API
  // For Physical Device: Use your computer's actual IP address
  static const String baseUrl = 'http://192.168.1.6:3500';

  // API Endpoints
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String getCurrentUser = '/api/auth/me';

  // OTP Endpoints
  static const String otpRequest = '/api/otp/request';
  static const String otpVerify = '/api/otp/verify';
  static const String otpResend = '/api/otp/resend';
  static const String resetPassword = '/api/otp/reset-password';

  // AI Endpoints
  static const String predictWoundType = '/api/ai/predict/wound-type';
  static const String predictSeverity = '/api/ai/predict/severity';
  static const String aiHealth = '/api/ai/health';

  // Triage Chatbot Endpoints
  static const String triageChat = '/api/triage/chat';
  static const String triageServices = '/api/triage/services';
  static const String triageReset = '/api/triage/reset';

  // Public Services Endpoints
  static const String publicHomeNursingServices =
      '/api/services/public/home-nursing';

  // Profile Endpoints
  static const String profileBase = '/api/profile';
  static const String updateMedicalInfo = '/api/profile/medical-info';
  static const String uploadIdDocument = '/api/profile/upload-id';
  static const String verificationStatus = '/api/profile/verification-status';
  static const String completeProfileSetup = '/api/profile/complete-setup';

  // Cloudinary Endpoints
  static const String cloudinaryBase = '/api/cloudinary';
  static const String cloudinaryUpload = '/api/cloudinary/upload';
  static const String cloudinaryUploadBase64 = '/api/cloudinary/upload-base64';
  static const String cloudinaryDelete = '/api/cloudinary/delete';

  // Notification Endpoints
  static const String notifications = '/api/notifications';
  static const String notificationsUnreadCount =
      '/api/notifications/unread-count';
  static const String notificationsReadAll = '/api/notifications/read-all';
  static const String notificationsClearAll = '/api/notifications/clear-all';

  // Booking & Medical Records Endpoints
  static const String visitReports = '/api/bookings/patients'; // Append /:patientId/visit-reports

  // Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Timeout durations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Wallet Endpoints
  static const String walletBalance = '/api/wallet/balance';
  static const String walletTransactions = '/api/wallet/transactions';
  static const String walletPaymentInfo = '/api/wallet/payment-info';
  static const String walletSubmitReceipt = '/api/wallet/receipts/submit';
  static const String walletMyReceipts = '/api/wallet/receipts/my';

  // Device / IoT Monitoring Endpoints
  static const String deviceVitals = '/api/device/vitals';
  static const String deviceSOS = '/api/device/sos';
  static const String deviceRegister = '/api/device/register';
  static const String deviceList = '/api/device/list';
  // Dynamic: /api/device/:bookingId/live
  static String deviceLiveVitals(String bookingId) => '/api/device/$bookingId/live';
  // Dynamic: /api/device/:bookingId/history
  static String deviceVitalsHistory(String bookingId) => '/api/device/$bookingId/history';
  // Dynamic: /api/device/:bookingId/summary
  static String deviceVitalsSummary(String bookingId) => '/api/device/$bookingId/summary';
  // Dynamic: /api/device/:deviceId/assign
  static String deviceAssign(String deviceId) => '/api/device/$deviceId/assign';
  // Dynamic: /api/device/:deviceId/release
  static String deviceRelease(String deviceId) => '/api/device/$deviceId/release';
  // Dynamic: /api/device/:deviceId/info
  static String deviceInfo(String deviceId) => '/api/device/$deviceId/info';
  // Dynamic: /api/bookings/:bookingId/device-vitals-prefill
  static String deviceVitalsPrefill(String bookingId) => '/api/bookings/$bookingId/device-vitals-prefill';
}
