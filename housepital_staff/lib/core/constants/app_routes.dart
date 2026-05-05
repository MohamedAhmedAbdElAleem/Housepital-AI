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
  static const String nurseProfile = '/nurse/profile';
  static const String nursePersonalInfo = '/nurse/personal-info';
  static const String nurseCredentials = '/nurse/credentials';
  static const String nurseServiceAreas = '/nurse/service-areas';
  static const String nurseSchedule = '/nurse/schedule';
  static const String nurseReviews = '/nurse/reviews';
  static const String nurseSettings = '/nurse/settings';
  static const String nurseWallet = '/nurse/wallet';
  static const String nursePendingApproval = '/nurse/pending-approval';
  static const String nurseRejected = '/nurse/rejected';

  // Doctor
  static const String doctorHome = '/doctor/home';
  static const String doctorProfile = '/doctor/profile';
  static const String doctorProfileCompletion = '/doctor/profile-completion';
  static const String doctorPendingApproval = '/doctor/pending-approval';
  static const String doctorRejected = '/doctor/rejected';
  static const String myClinics = '/doctor/clinics';
  static const String addClinic = '/doctor/clinics/add';
  static const String clinicDetails = '/doctor/clinics/details';
  static const String myServices = '/doctor/services';
  static const String myAppointments = '/doctor/appointments';
  static const String doctorWallet = '/doctor/wallet';

  // Admin
  static const String adminHome = '/admin/home';
  static const String adminDashboard = '/admin/dashboard'; // mapped to verifications
  static const String adminVerifications = '/admin/verifications';
  static const String adminUsers = '/admin/users';
  static const String adminAddStaff = '/admin/add-staff';
  static const String adminBookings = '/admin/bookings';

  // Common
  static const String settings = '/settings';
  static const String nurseProfileCompletion = '/nurse/profile-completion';
}
