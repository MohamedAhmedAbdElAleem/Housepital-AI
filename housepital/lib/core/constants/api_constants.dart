class ApiConstants {
  // Base URL - Use your computer's IP for physical device testing
  static const String baseUrl = 'http://192.168.56.212:3500/api';

  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String verifyEmail = '/auth/verify-email';
  static const String verifyOTP = '/auth/verify-otp';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // User Endpoints
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/update';
  static const String medicalHistory = '/user/medical-history';

  // Services Endpoints
  static const String services = '/services';
  static const String serviceDetails = '/services/:id';
  static const String bookService = '/services/book';
  static const String serviceHistory = '/services/history';

  // Nurse/Doctor Endpoints
  static const String requests = '/requests';
  static const String acceptRequest = '/requests/accept';
  static const String currentServices = '/requests/current';
  static const String uploadReport = '/requests/report';

  // Chat Endpoints
  static const String chatMessages = '/chat/messages';
  static const String sendMessage = '/chat/send';

  // AI Chatbot
  static const String chatbot = '/ai/chatbot';
  static const String triage = '/ai/triage';
  static const String recommendations = '/ai/recommendations';

  // Plans
  static const String plans = '/plans';
  static const String subscribe = '/plans/subscribe';
}
