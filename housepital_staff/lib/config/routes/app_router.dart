import 'package:flutter/material.dart';
import '../../core/constants/app_routes.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/doctor/presentation/pages/doctor_profile_page.dart';
import '../../features/doctor/presentation/pages/doctor_home_page.dart';
import '../../features/doctor/presentation/pages/doctor_profile_completion_page.dart';
import '../../features/doctor/presentation/pages/doctor_pending_approval_page.dart';
import '../../features/doctor/presentation/pages/doctor_rejected_page.dart';
import '../../features/doctor/presentation/pages/my_clinics_page.dart';
import '../../features/doctor/presentation/pages/clinic_form_page.dart';
import '../../features/doctor/presentation/pages/clinic_details_page.dart';
import '../../features/doctor/presentation/pages/my_services_page.dart';
import '../../features/doctor/presentation/pages/appointments_page.dart';
import '../../features/doctor/data/models/clinic_model.dart';
import '../../features/nurse/presentation/pages/nurse_home_page.dart';
import '../../features/nurse/presentation/pages/nurse_profile_page.dart';
import '../../features/nurse/presentation/pages/nurse_profile_completion_page.dart';
import '../../features/nurse/presentation/pages/nurse_personal_info_page.dart';
import '../../features/nurse/presentation/pages/nurse_credentials_page.dart';
import '../../features/nurse/presentation/pages/nurse_service_areas_page.dart';
import '../../features/nurse/presentation/pages/nurse_schedule_page.dart';
import '../../features/nurse/presentation/pages/nurse_reviews_page.dart';
import '../../features/nurse/presentation/pages/nurse_settings_page.dart';
import '../../features/nurse/presentation/pages/nurse_pending_approval_page.dart';
import '../../features/nurse/presentation/pages/nurse_rejected_page.dart';
import '../../features/nurse/presentation/pages/wallet_page.dart';
import '../../features/doctor/presentation/pages/wallet_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin/presentation/pages/admin_home_page.dart';
import '../../features/admin/presentation/pages/admin_users_page.dart';
import '../../features/admin/presentation/pages/add_staff_page.dart';
import '../../features/admin/presentation/pages/admin_bookings_page.dart';

class AppRouter {
  static Route<dynamic> _buildDefaultRoute(
    Widget page, {
    RouteSettings? settings,
  }) {
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }

  static Route<dynamic> _buildDoctorRoute(
    Widget page, {
    RouteSettings? settings,
  }) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        final slide = Tween<Offset>(
          begin: const Offset(0.06, 0),
          end: Offset.zero,
        ).animate(curved);

        final fade = Tween<double>(begin: 0.0, end: 1.0).animate(curved);

        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
    );
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _buildDefaultRoute(const SplashPage(), settings: settings);

      case AppRoutes.login:
        return _buildDefaultRoute(const LoginPage(), settings: settings);

      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());

      case AppRoutes.nurseHome:
        return _buildDefaultRoute(const NurseHomePage(), settings: settings);

      case AppRoutes.nurseProfile:
        return MaterialPageRoute(
          builder: (_) => const NurseProfilePage(),
        );

      case AppRoutes.nurseProfileCompletion:
        return MaterialPageRoute(
          builder: (_) => const NurseProfileCompletionPage(),
        );

      case AppRoutes.nursePersonalInfo:
        return MaterialPageRoute(
          builder: (_) => const NursePersonalInfoPage(),
        );

      case AppRoutes.nurseCredentials:
        return MaterialPageRoute(
          builder: (_) => const NurseCredentialsPage(),
        );

      case AppRoutes.nurseServiceAreas:
        return MaterialPageRoute(
          builder: (_) => const NurseServiceAreasPage(),
        );

      case AppRoutes.nurseSchedule:
        return MaterialPageRoute(
          builder: (_) => const NurseSchedulePage(),
        );

      case AppRoutes.nurseReviews:
        return MaterialPageRoute(
          builder: (_) => const NurseReviewsPage(),
        );

      case AppRoutes.nurseSettings:
        return MaterialPageRoute(
          builder: (_) => const NurseSettingsPage(),
        );

      case AppRoutes.nursePendingApproval:
        return _buildDefaultRoute(
          const NursePendingApprovalPage(),
          settings: settings,
        );

      case AppRoutes.nurseRejected:
        return _buildDefaultRoute(
          const NurseRejectedPage(),
          settings: settings,
        );

      case AppRoutes.doctorHome:
        return _buildDoctorRoute(const DoctorHomePage(), settings: settings);

      case AppRoutes.doctorProfile:
        return _buildDoctorRoute(const DoctorProfilePage(), settings: settings);

      case AppRoutes.doctorProfileCompletion:
        return _buildDoctorRoute(
          const DoctorProfileCompletionPage(),
          settings: settings,
        );

      case AppRoutes.doctorPendingApproval:
        return _buildDefaultRoute(
          const DoctorPendingApprovalPage(),
          settings: settings,
        );

      case AppRoutes.doctorRejected:
        return _buildDefaultRoute(
          const DoctorRejectedPage(),
          settings: settings,
        );

      case AppRoutes.myClinics:
        return _buildDoctorRoute(const MyClinicsPage(), settings: settings);

      case AppRoutes.addClinic:
        final clinic = settings.arguments as ClinicModel?;
        return _buildDoctorRoute(
          ClinicFormPage(clinicToEdit: clinic),
          settings: settings,
        );

      case AppRoutes.clinicDetails:
        return _buildDoctorRoute(const ClinicDetailsPage(), settings: settings);

      case AppRoutes.myServices:
        return _buildDoctorRoute(const MyServicesPage(), settings: settings);

      case AppRoutes.myAppointments:
        return _buildDoctorRoute(const AppointmentsPage(), settings: settings);

      case AppRoutes.adminDashboard:
      case AppRoutes.adminVerifications:
        return _buildDefaultRoute(
          const AdminDashboardPage(),
          settings: settings,
        );

      case AppRoutes.adminHome:
        return _buildDefaultRoute(
          const AdminHomePage(),
          settings: settings,
        );

      case AppRoutes.adminUsers:
        return _buildDefaultRoute(
          const AdminUsersPage(),
          settings: settings,
        );

      case AppRoutes.adminBookings:
        return _buildDefaultRoute(
          const AdminBookingsPage(),
          settings: settings,
        );

      case AppRoutes.adminAddStaff:
        final staffType = settings.arguments as String? ?? 'nurse';
        return _buildDefaultRoute(
          AddStaffPage(staffType: staffType),
          settings: settings,
        );

      case AppRoutes.nurseWallet:
        return _buildDefaultRoute(const NurseWalletPage(), settings: settings);

      case AppRoutes.doctorWallet:
        return _buildDefaultRoute(const DoctorWalletPage(), settings: settings);

      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
        );
    }
  }
}
