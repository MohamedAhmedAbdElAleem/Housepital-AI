import 'package:flutter/material.dart';
import '../../core/constants/app_routes.dart';
import '../../core/widgets/placeholder_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/doctor/presentation/pages/doctor_profile_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());

      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case AppRoutes.nurseHome:
        return MaterialPageRoute(
          builder: (_) => const PlaceholderPage(title: 'Nurse Home'),
        );

      case AppRoutes.doctorHome:
        return MaterialPageRoute(
          builder: (_) => const PlaceholderPage(title: 'Doctor Home'),
        );

      case AppRoutes.doctorProfile:
        return MaterialPageRoute(builder: (_) => const DoctorProfilePage());

      case AppRoutes.adminDashboard:
        return MaterialPageRoute(
          builder: (_) => const PlaceholderPage(title: 'Admin Dashboard'),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
