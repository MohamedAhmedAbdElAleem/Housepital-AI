import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/doctor_cubit.dart';
import '../theme/doctor_theme.dart';
import '../widgets/background_blobs.dart';

class DoctorRejectedPage extends StatelessWidget {
  const DoctorRejectedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DoctorTheme.background,
      body: BackgroundBlobs(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: BlocBuilder<DoctorCubit, DoctorState>(
              builder: (context, state) {
                String? rejectionReason;
                if (state is DoctorProfileLoaded) {
                  rejectionReason = state.profile.rejectionReason;
                }

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // ── Icon with Gradient Ring ──
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            DoctorTheme.danger.withValues(alpha: 0.15),
                            DoctorTheme.danger.withValues(alpha: 0.05),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: DoctorTheme.danger.withValues(alpha: 0.12),
                            blurRadius: 30,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: DoctorTheme.dangerLight,
                        ),
                        child: const Icon(
                          Icons.block_rounded,
                          color: DoctorTheme.danger,
                          size: 44,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Title ──
                    const Text(
                      'Verification Unsuccessful',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: DoctorTheme.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Your profile could not be verified at this time. Please review the feedback below and resubmit.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: DoctorTheme.textSecondary,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),

                    // ── Rejection Reason Card ──
                    if (rejectionReason != null &&
                        rejectionReason.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: DoctorTheme.surface,
                          borderRadius:
                              BorderRadius.circular(DoctorTheme.radiusSM),
                          border: Border.all(
                            color: DoctorTheme.danger.withValues(alpha: 0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: DoctorTheme.danger.withValues(alpha: 0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Red accent strip
                              Container(
                                width: 4,
                                color: DoctorTheme.danger,
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(Icons.feedback_rounded,
                                              size: 18,
                                              color: DoctorTheme.danger),
                                          SizedBox(width: 8),
                                          Text(
                                            'Reason',
                                            style: TextStyle(
                                              color: DoctorTheme.danger,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        rejectionReason,
                                        style: const TextStyle(
                                          color: DoctorTheme.textSecondary,
                                          fontSize: 14,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 28),

                    // ── Update Profile Button ──
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: DoctorTheme.headerGradient,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  DoctorTheme.primary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.doctorProfileCompletion,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(Icons.edit_document),
                          label: const Text(
                            'Update & Resubmit',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
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
                      child: const Text(
                        'Sign out',
                        style: TextStyle(
                          color: DoctorTheme.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
