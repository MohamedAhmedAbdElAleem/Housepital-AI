class ApiConstants {
  // For Android Emulator: 10.0.2.2  |  For iOS Simulator: localhost  |  For Physical Device: 192.168.1.3 or 172.20.10.3
  static const String baseUrl = 'http://192.168.1.208:3500/api';
  // Base URL - Use localhost for emulator/simulator
  // For physical device testing, use your computer's IP: http://172.20.10.3:3500/api
  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String verifyEmail = '/auth/verify-email';
  static const String verifyOTP = '/auth/verify-otp';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // User Endpoints
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/update-profile';
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

  // Nurse Profile Endpoints
  static const String nurseProfile = '/nurse/profile';
  static const String nurseProfileSubmit = '/nurse/profile/submit';
  static const String nurseProfileStatus = '/nurse/profile/status';

  // Cloudinary
  static const String cloudinaryUpload = '/cloudinary/upload';

  // Booking Endpoints (Nurse)
  static const String nursePendingBookings = '/bookings/nurse/pending';
  static const String nurseActiveBooking = '/bookings/nurse/active';
  static const String nurseBookingHistory = '/bookings/nurse/history';

  // Matching Endpoints (Nurse)
  static const String nurseMatchingOffers = '/matching/nurse-offers';
  static String respondToNurseOffer(String offerId) =>
      '/matching/nurse-offers/$offerId/respond';

  static String acceptBooking(String id) => '/bookings/$id/accept';
  static String verifyPin(String id) => '/bookings/$id/verify-pin';
  static String completeVisit(String id) => '/bookings/$id/complete';
  static String completeVisitWithReport(String id) =>
      '/bookings/$id/complete-with-report';
  static String getVisitReport(String id) => '/bookings/$id/visit-report';
  static String getLastVisitReport(String patientId) =>
      '/bookings/patients/$patientId/last-visit-report';
  static String updateBookingStatus(String id) => '/bookings/$id/status';

  // Wallet Endpoints
  static const String walletBalance = '/wallet/balance';
  static const String walletTransactions = '/wallet/transactions';
  static const String walletPaymentInfo = '/wallet/payment-info';
  static const String walletSubmitReceipt = '/wallet/receipts/submit';
  static const String walletMyReceipts = '/wallet/receipts/my';
  static const String walletRechargeInitiate = '/wallet/recharge/initiate';
  static String walletRechargeStatus(String orderId) =>
      '/wallet/recharge/status/$orderId';

  // Admin Wallet Receipt Endpoints
  static const String walletPendingReceipts = '/wallet/receipts/pending';
  static const String walletAllReceipts = '/wallet/receipts/all';
  static String walletReviewReceipt(String id) => '/wallet/receipts/$id/review';
}
