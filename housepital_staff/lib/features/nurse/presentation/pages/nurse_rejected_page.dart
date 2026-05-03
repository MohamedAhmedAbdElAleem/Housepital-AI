import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

class NurseRejectedPage extends StatelessWidget {
  const NurseRejectedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF2F2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFECACA), width: 4),
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 60,
                  color: Color(0xFFEF4444),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Application Rejected',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF991B1B),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Unfortunately, your nurse application was not approved at this time. '
                'Please review the reason below and update your profile to try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.red[900]?.withValues(alpha: 0.7),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),
              // Rejection Reason Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFECACA)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 18, color: Color(0xFFEF4444)),
                        SizedBox(width: 8),
                        Text(
                          'Reason for Rejection',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF991B1B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Your medical license document was not clear enough to verify. Please upload a high-quality scan or photo of your official nursing license.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF4B5563),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              // Update Profile Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.nurseProfileCompletion,
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.edit_document),
                  label: const Text(
                    'Update Application',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Logout button
              TextButton.icon(
                onPressed: () {
                  context.read<AuthCubit>().logout();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout_rounded, size: 20),
                label: const Text('Logout'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red[400],
                ),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
