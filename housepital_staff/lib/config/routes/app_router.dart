import 'package:flutter/material.dart';
import '../../core/constants/app_routes.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/doctor/presentation/pages/doctor_profile_page.dart';
import '../../features/doctor/presentation/pages/doctor_home_page.dart';
import '../../features/doctor/presentation/pages/my_clinics_page.dart';
import '../../features/doctor/presentation/pages/clinic_form_page.dart';
import '../../features/doctor/presentation/pages/clinic_details_page.dart';
import '../../features/doctor/presentation/pages/my_services_page.dart';
import '../../features/doctor/presentation/pages/appointments_page.dart';
import '../../features/doctor/data/models/clinic_model.dart';
import '../../features/nurse/presentation/pages/nurse_home_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';

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

      case AppRoutes.nurseHome:
        return _buildDefaultRoute(const NurseHomePage(), settings: settings);

      case AppRoutes.doctorHome:
        return _buildDoctorRoute(const DoctorHomePage(), settings: settings);

      case AppRoutes.doctorProfile:
        return _buildDoctorRoute(const DoctorProfilePage(), settings: settings);

      case AppRoutes.myClinics:
        return _buildDoctorRoute(const MyClinicsPage(), settings: settings);

      case AppRoutes.addClinic:
        final clinic = settings.arguments as ClinicModel?;
        return _buildDoctorRoute(
          ClinicFormPage(clinicToEdit: clinic),
          settings: settings,
        );

      case AppRoutes.clinicDetails:
        return _buildDoctorRoute(
          const ClinicDetailsPage(),
          settings: settings,
        );

      case AppRoutes.myServices:
        return _buildDoctorRoute(const MyServicesPage(), settings: settings);

      case AppRoutes.myAppointments:
        return _buildDoctorRoute(const AppointmentsPage(), settings: settings);

      case AppRoutes.adminDashboard:
        return _buildDefaultRoute(
          const AdminDashboardPage(),
          settings: settings,
        );

      default:
        return _buildDefaultRoute(
          Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
          settings: settings,
        );
    }
  }
}
