class AppRoutes {
  // Initial
  static const String splash = '/';
  static const String onboarding = '/onboarding';

  // Auth
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Nurse
  static const String nurseHome = '/nurse/home';
  static const String nurseWallet = '/nurse/wallet';

  // Doctor
  static const String doctorHome = '/doctor/home';
  static const String doctorProfile = '/doctor/profile';
  static const String myClinics = '/doctor/clinics';
  static const String addClinic = '/doctor/clinics/add';
  static const String clinicDetails = '/doctor/clinics/details';
  static const String myServices = '/doctor/services';
  static const String myAppointments = '/doctor/appointments';
  static const String doctorWallet = '/doctor/wallet';

  // Admin
  static const String adminDashboard = '/admin/dashboard';

  // Common
  static const String settings = '/settings';
  static const String nurseProfileCompletion = '/nurse/profile-completion';
}
