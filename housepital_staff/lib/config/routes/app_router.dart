import 'package:flutter/material.dart';
import '../../core/constants/app_routes.dart';
import '../../core/widgets/placeholder_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/doctor/presentation/pages/doctor_profile_page.dart';

import '../../features/doctor/presentation/pages/doctor_home_page.dart';
import '../../features/nurse/presentation/pages/nurse_home_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());

      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case AppRoutes.nurseHome:
        return MaterialPageRoute(builder: (_) => const NurseHomePage());

      case AppRoutes.doctorHome:
        return MaterialPageRoute(builder: (_) => const DoctorHomePage());

      case AppRoutes.doctorProfile:
        return MaterialPageRoute(builder: (_) => const DoctorProfilePage());

      case AppRoutes.adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardPage());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
