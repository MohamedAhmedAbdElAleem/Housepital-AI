import 'package:flutter/material.dart';
import '../../core/constants/app_routes.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/auth/presentation/pages/verify_identity_page.dart';
import '../../features/auth/presentation/pages/scan_national_id_page.dart';
import '../../features/auth/presentation/pages/verifying_identity_page.dart';
import '../../features/auth/presentation/pages/verification_success_page.dart';
import '../../features/auth/presentation/pages/verify_email_page.dart';
import '../../features/auth/presentation/pages/verify_otp_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/reset_password_otp_page.dart';
import '../../features/auth/presentation/pages/new_password_page.dart';
import '../../features/auth/presentation/pages/reset_password_success_page.dart';
import '../../features/customer/home/presentation/pages/customer_home_page.dart';
import '../../features/nurse/home/presentation/pages/nurse_home_page.dart';
import '../../features/doctor/home/presentation/pages/doctor_home_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());

      case AppRoutes.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingPage());

      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());

      case AppRoutes.otp:
        final email = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => OTPPage(email: email));

      case AppRoutes.verifyIdentity:
        return MaterialPageRoute(builder: (_) => const VerifyIdentityPage());

      case AppRoutes.scanNationalID:
        return MaterialPageRoute(builder: (_) => const ScanNationalIDPage());

      case AppRoutes.verifyingIdentity:
        return MaterialPageRoute(builder: (_) => const VerifyingIdentityPage());

      case AppRoutes.verificationSuccess:
        return MaterialPageRoute(
          builder: (_) => const VerificationSuccessPage(),
        );

      case AppRoutes.verifyEmail:
        return MaterialPageRoute(builder: (_) => const VerifyEmailPage());

      case AppRoutes.verifyOTP:
        return MaterialPageRoute(builder: (_) => const VerifyOTPPage());

      case AppRoutes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());

      case AppRoutes.resetPasswordOtp:
        final email = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ResetPasswordOtpPage(email: email),
        );

      case AppRoutes.newPassword:
        final email = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => NewPasswordPage(email: email));

      case AppRoutes.resetPasswordSuccess:
        return MaterialPageRoute(
          builder: (_) => const ResetPasswordSuccessPage(),
        );

      case AppRoutes.customerHome:
        return MaterialPageRoute(builder: (_) => const CustomerHomePage());

      case AppRoutes.nurseHome:
        return MaterialPageRoute(builder: (_) => const NurseHomePage());

      case AppRoutes.doctorHome:
        return MaterialPageRoute(builder: (_) => const DoctorHomePage());

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
