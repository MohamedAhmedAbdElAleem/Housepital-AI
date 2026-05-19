import 'package:easy_localization/easy_localization.dart';
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
                content: Text('still_under_review_we_ll_notify_you_soon'.tr()),
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
                          decoration: const BoxDecoration(
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
                  'profile_under_review'.tr(),
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
                  'our_verification_team_is_reviewing_your_documents_and_credentials_this_usually_takes_1_2_business_days'.tr(),
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
                      _infoRow(Icons.timer_outlined, 'review_typically_takes_1_2_business_days'.tr()),
                      SizedBox(height: 10),
                      _infoRow(Icons.notifications_none_rounded, 'You\'ll be notified when a decision is made'),
                      SizedBox(height: 10),
                      _infoRow(Icons.support_agent_rounded, 'contact_support_if_it_takes_longer_than_expected'.tr()),
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
                        _isChecking ? 'Checking...' : 'check_my_status'.tr(),
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
                    'sign_out'.tr(),
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
