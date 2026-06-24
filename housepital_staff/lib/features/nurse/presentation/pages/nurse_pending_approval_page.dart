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
    setState(() => _isChecking = true);
    final cubit = context.read<NurseProfileCubit>();
    await cubit.loadProfileStatus();

    if (!mounted) return;
    final state = cubit.state;

    if (state is NurseProfileStatusLoaded) {
      final status = state.status.verificationStatus;
      final profileStatus = state.status.profileStatus;
      final rejectionReason = state.status.rejectionReason;

      await TokenManager.saveVerificationStatus(status);

      if (status == 'approved' || profileStatus == 'approved') {
        if (mounted) Navigator.pushNamedAndRemoveUntil(context, AppRoutes.nurseHome, (route) => false);
        return;
      } else if (status == 'rejected') {
        await TokenManager.saveRejectionReason(rejectionReason);
        if (mounted) Navigator.pushNamedAndRemoveUntil(context, AppRoutes.nurseRejected, (route) => false);
        return;
      }

      if (mounted) {
        setState(() => _isChecking = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Still under review...'), backgroundColor: Theme.of(context).colorScheme.primary, duration: const Duration(seconds: 4)));
      }
    } else if (state is NurseProfileError) {
      if (mounted) {
        setState(() => _isChecking = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${state.message}'), backgroundColor: Colors.red[700]));
      }
    } else {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Spacer(flex: 2),
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
                            const Color(0xFF10B981).withAlpha(isDark ? 40 : 15),
                            const Color(0xFF3498BB).withAlpha(isDark ? 30 : 8),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                          ),
                          child: const Icon(Icons.hourglass_top_rounded, size: 48, color: Colors.white),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              Text(
                'Application Under Review',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
              ),
              const SizedBox(height: 16),
              Text(
                'Your documents and profile are being reviewed by our team. This usually takes 1–2 business days. You will receive an email once your account is approved.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: theme.colorScheme.onSurface.withAlpha(150), height: 1.6),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isChecking ? null : _checkStatus,
                  icon: _isChecking
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.refresh_rounded),
                  label: Text(_isChecking ? 'Checking...' : 'Check Status', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  context.read<AuthCubit>().logout();
                  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
                },
                icon: const Icon(Icons.logout_rounded, size: 20),
                label: const Text('Logout'),
                style: TextButton.styleFrom(foregroundColor: theme.colorScheme.onSurface.withAlpha(150)),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
