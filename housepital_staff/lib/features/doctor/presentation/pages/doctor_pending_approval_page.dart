import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/utils/token_manager.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/doctor_cubit.dart';
import '../theme/doctor_theme.dart';
import '../widgets/background_blobs.dart';

class DoctorPendingApprovalPage extends StatefulWidget {
  const DoctorPendingApprovalPage({super.key});

  @override
  State<DoctorPendingApprovalPage> createState() =>
      _DoctorPendingApprovalPageState();
}

class _DoctorPendingApprovalPageState extends State<DoctorPendingApprovalPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
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
    setState(() => _isChecking = true);
    try {
      final cubit = context.read<DoctorCubit>();
      await cubit.fetchProfile();
      if (!mounted) return;

      final state = cubit.state;
      if (state is DoctorProfileLoaded) {
        final status = state.profile.verificationStatus.toLowerCase();
        await TokenManager.saveVerificationStatus(status);

        if (status == 'approved') {
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.doctorHome,
              (route) => false,
            );
          }
        } else if (status == 'rejected') {
          if (mounted) {
            Navigator.pushReplacementNamed(context, AppRoutes.doctorRejected);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Still under review — we\'ll notify you soon.'),
                backgroundColor: DoctorTheme.warning,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        }
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DoctorTheme.background(context),
      body: BackgroundBlobs(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // ── Animated Icon with Gradient Ring ──
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final scale = 1.0 + _pulseController.value * 0.08;
                    final ringAlpha = 0.08 + _pulseController.value * 0.12;
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              DoctorTheme.warning.withValues(alpha: ringAlpha),
                              DoctorTheme.primary.withValues(alpha: ringAlpha * 0.6),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: DoctorTheme.warning.withValues(alpha: 0.15),
                              blurRadius: 30,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Container(
                          margin: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: DoctorTheme.warningLight,
                          ),
                          child: Icon(
                            Icons.hourglass_top_rounded,
                            color: DoctorTheme.warning,
                            size: 44,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 32),

                // ── Title ──
                Text(
                  'Profile Under Review',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: DoctorTheme.textPrimary(context),
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Our verification team is reviewing your documents and credentials. This usually takes 1-2 business days.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: DoctorTheme.textSecondary(context),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 24),

                // ── Info Card ──
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: DoctorTheme.surfaceDim(context),
                    borderRadius: BorderRadius.circular(DoctorTheme.radiusSM),
                    border: Border.all(color: DoctorTheme.border(context)),
                  ),
                  child: Column(
                    children: [
                      _infoRow(Icons.timer_outlined, 'Review typically takes 1-2 business days'),
                      SizedBox(height: 10),
                      _infoRow(Icons.notifications_none_rounded, 'You\'ll be notified when a decision is made'),
                      SizedBox(height: 10),
                      _infoRow(Icons.support_agent_rounded, 'Contact support if it takes longer than expected'),
                    ],
                  ),
                ),
                SizedBox(height: 28),

                // ── Check Status Button ──
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: _isChecking ? null : DoctorTheme.headerGradient(context),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: _isChecking
                          ? null
                          : [
                              BoxShadow(
                                color: DoctorTheme.primary.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _isChecking ? null : _checkStatus,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: _isChecking
                          ? SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: DoctorTheme.surface(context)),
                            )
                          : Icon(Icons.refresh_rounded),
                      label: Text(
                        _isChecking ? 'Checking...' : 'Check My Status',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // ── Logout ──
                TextButton(
                  onPressed: () {
                    context.read<AuthCubit>().logout();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.login,
                      (route) => false,
                    );
                  },
                  child: Text(
                    'Sign out',
                    style: TextStyle(
                      color: DoctorTheme.textSecondary(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: DoctorTheme.primary),
        SizedBox(width: 10),
        Expanded(
          child: Text(text, style: DoctorTheme.bodySmall(context)),
        ),
      ],
    );
  }
}
