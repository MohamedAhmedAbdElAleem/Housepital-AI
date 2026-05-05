import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/utils/token_manager.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/nurse_profile_cubit.dart';

class NursePendingApprovalPage extends StatefulWidget {
  const NursePendingApprovalPage({super.key});

  @override
  State<NursePendingApprovalPage> createState() =>
      _NursePendingApprovalPageState();
}

class _NursePendingApprovalPageState extends State<NursePendingApprovalPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
        vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Automatically check status when page loads to avoid being stuck on pending
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkStatus();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    print('\n========== [CHECK STATUS] STARTED ==========');
    setState(() => _isChecking = true);
    final cubit = context.read<NurseProfileCubit>();

    print('[CHECK STATUS] Calling GET /api/nurse/profile/status ...');
    await cubit.loadProfileStatus();

    if (!mounted) return;
    final state = cubit.state;

    print('[CHECK STATUS] Cubit state type: ${state.runtimeType}');

    if (state is NurseProfileStatusLoaded) {
      final status = state.status.verificationStatus;
      final profileStatus = state.status.profileStatus;
      final profileExists = state.status.profileExists;
      final completionPct = state.status.completionPercentage;
      final rejectionReason = state.status.rejectionReason;

      print('[CHECK STATUS] ✅ API response parsed successfully:');
      print('  → verificationStatus : "$status"');
      print('  → profileStatus      : "$profileStatus"');
      print('  → profileExists      : $profileExists');
      print('  → completionPct      : $completionPct%');
      print('  → rejectionReason    : $rejectionReason');

      // Persist the latest status so splash screen reflects it on next launch
      await TokenManager.saveVerificationStatus(status);
      print('[CHECK STATUS] Saved verificationStatus to local storage: "$status"');

      print('[CHECK STATUS] Evaluating: status=="approved" → ${status == 'approved'}');
      print('[CHECK STATUS] Evaluating: profileStatus=="approved" → ${profileStatus == 'approved'}');

      if (status == 'approved' || profileStatus == 'approved') {
        print('[CHECK STATUS] 🟢 APPROVED → navigating to nurseHome');
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.nurseHome,
            (route) => false,
          );
        }
        return;
      } else if (status == 'rejected') {
        print('[CHECK STATUS] 🔴 REJECTED → navigating to nurseRejected');
        await TokenManager.saveRejectionReason(rejectionReason);
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.nurseRejected,
            (route) => false,
          );
        }
        return;
      }

      // Still pending
      print('[CHECK STATUS] 🟡 PENDING → showing snackbar (status="$status", profileStatus="$profileStatus")');
      if (mounted) {
        setState(() => _isChecking = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Still under review. '
              '[verificationStatus: $status | profileStatus: $profileStatus]',
            ),
            backgroundColor: const Color(0xFF2664EC),
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } else if (state is NurseProfileError) {
      print('[CHECK STATUS] ❌ ERROR state: ${state.message}');
      if (mounted) {
        setState(() => _isChecking = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${state.message}'),
            backgroundColor: Colors.red[700],
            duration: const Duration(seconds: 8),
          ),
        );
      }
    } else {
      print('[CHECK STATUS] ⚠️ UNEXPECTED state: ${state.runtimeType}');
      if (mounted) setState(() => _isChecking = false);
    }
    print('========== [CHECK STATUS] DONE ==========\n');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Animated icon
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final scale = 1.0 + (_pulseController.value * 0.08);
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF10B981)
                                .withValues(alpha: 0.15),
                            const Color(0xFF3498BB)
                                .withValues(alpha: 0.08),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF059669)],
                            ),
                          ),
                          child: const Icon(
                            Icons.hourglass_top_rounded,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              const Text(
                'Application Under Review',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your documents and profile are being reviewed by our team. '
                'This usually takes 1–2 business days. You will receive an email once your account is approved.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 48),
              // Check status button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isChecking ? null : _checkStatus,
                  icon: _isChecking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.refresh_rounded),
                  label: Text(
                    _isChecking ? 'Checking...' : 'Check Status',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
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
                  foregroundColor: Colors.grey[600],
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
