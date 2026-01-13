class AppRoutes {
  // Initial
  static const String splash = '/';
  static const String onboarding = '/onboarding';

  // Auth
  static const String login = '/login';
  static const String register = '/register';
  static const String medicalHistory = '/medical-history';
  static const String otp = '/otp';
  static const String verifyIdentity = '/verify-identity';
  static const String scanNationalID = '/scan-national-id';
  static const String verifyingIdentity = '/verifying-identity';
  static const String verificationSuccess = '/verification-success';
  static const String forgotPassword = '/forgot-password';
  static const String resetPasswordOtp = '/reset-password-otp';
  static const String newPassword = '/new-password';
  static const String resetPasswordSuccess = '/reset-password-success';

  // Customer
  static const String customerHome = '/customer/home';
  static const String customerProfile = '/customer/profile';
  static const String customerServices = '/customer/services';
  static const String customerServiceDetails = '/customer/service-details';
  static const String customerBooking = '/customer/booking';
  static const String customerChat = '/customer/chat';
  static const String customerPlans = '/customer/plans';
  static const String customerHistory = '/customer/history';

  // Nurse
  static const String nurseHome = '/nurse/home';
  static const String nurseProfile = '/nurse/profile';
  static const String nurseRequests = '/nurse/requests';
  static const String nurseCurrentServices = '/nurse/current-services';
  static const String nurseChat = '/nurse/chat';

  // Doctor
  static const String doctorHome = '/doctor/home';
  static const String doctorProfile = '/doctor/profile';
  static const String doctorRequests = '/doctor/requests';
  static const String doctorCurrentServices = '/doctor/current-services';
  static const String doctorChat = '/doctor/chat';

  // Admin
  static const String adminDashboard = '/admin/dashboard';

  // Common
  static const String chatbot = '/chatbot';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
}
