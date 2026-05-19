import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/service_model.dart';
import '../cubit/service_cubit.dart';
import '../theme/doctor_theme.dart';
import '../widgets/background_blobs.dart';
import '../widgets/glass_header.dart';
import '../widgets/empty_state_widget.dart';
import 'service_form_page.dart';

class MyServicesPage extends StatefulWidget {
  const MyServicesPage({super.key});

  @override
  State<MyServicesPage> createState() => _MyServicesPageState();
}

class _MyServicesPageState extends State<MyServicesPage> {
  @override
  void initState() {
    super.initState();
    context.read<ServiceCubit>().fetchServices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DoctorTheme.background(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddService,
        backgroundColor: DoctorTheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: Icon(Icons.add),
        label: Text(
          'add_service'.tr(),
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: BackgroundBlobs(
        child: SafeArea(
          child: Column(
            children: [
              GlassHeader(
                title: 'my_services'.tr(),
                subtitle: 'manage_pricing_and_consultation_options'.tr(),
                onBack: () => Navigator.maybePop(context),
                actionIcon: Icons.refresh_rounded,
                actionTooltip: 'Refresh',
                onAction: () =>
                    context.read<ServiceCubit>().fetchServices(),
              ),
              Expanded(
                child: BlocConsumer<ServiceCubit, ServiceState>(
                  listener: (context, state) {
                    if (state is ServiceError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: DoctorTheme.danger,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is ServiceLoading) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: DoctorTheme.primary,
                        ),
                      );
                    }

                    if (state is ServiceLoaded) {
                      if (state.services.isEmpty) {
                        return EmptyStateWidget(
                          icon: Icons.medical_services_outlined,
                          title: 'no_services_added_yet'.tr(),
                          subtitle:
                              'start_by_adding_your_first_service_with_clear_duration_and_pricing'.tr(),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<ServiceCubit>().fetchServices();
                        },
                        color: DoctorTheme.primary,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(16, 8, 16, 90),
                          itemCount: state.services.length,
                          separatorBuilder: (_, __) =>
                              SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return _buildServiceCard(state.services[index]);
                          },
                        ),
                      );
                    }

                    return Center(
                      child: Text(
                        'something_went_wrong'.tr(),
                        style: DoctorTheme.bodyMedium(context),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Navigation ──────────────────────────────────────────────────

  Future<void> _openAddService() async {
    final serviceCubit = context.read<ServiceCubit>();
    await Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ServiceFormPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.06, 0),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
    serviceCubit.fetchServices();
  }

  Future<void> _openEditService(ServiceModel service) async {
    final serviceCubit = context.read<ServiceCubit>();
    await Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (context, animation, secondaryAnimation) =>
            ServiceFormPage(serviceToEdit: service),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.06, 0),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
    serviceCubit.fetchServices();
  }

  // ── Service Card ─────────────────────────────────────────────────

  Widget _buildServiceCard(ServiceModel service) {
    final accentColor = service.isActive
        ? DoctorTheme.success
        : DoctorTheme.danger;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: DoctorTheme.surface(context),
        borderRadius: BorderRadius.circular(DoctorTheme.radiusMD),
        border: Border.all(color: DoctorTheme.border(context)),
        boxShadow: DoctorTheme.cardShadow(context),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(DoctorTheme.radiusMD),
          onTap: () => _openEditService(service),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left accent strip
                Container(width: 4, color: accentColor),
                // Content
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(DoctorTheme.radiusXS),
                            gradient: LinearGradient(
                              colors: [
                                DoctorTheme.primary.withValues(alpha: 0.2),
                                DoctorTheme.secondary.withValues(alpha: 0.1),
                              ],
                            ),
                          ),
                          child: Icon(
                            Icons.medical_services_rounded,
                            color: DoctorTheme.primaryDark,
                            size: 28,
                          ),
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                service.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: DoctorTheme.titleMedium(context),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${service.durationMinutes} mins  •  ${service.clinics.length} Clinics',
                                style: DoctorTheme.bodySmall(context),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Price chip
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF1136A8),
                                    Color(0xFF2664EC),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(
                                  DoctorTheme.radiusChip,
                                ),
                              ),
                              child: Text(
                                '${service.price.toInt()} ${service.currency}',
                                style: TextStyle(
                                  color: DoctorTheme.surface(context),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            SizedBox(height: 6),
                            // Status badge
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: service.isActive
                                    ? DoctorTheme.successLight
                                    : DoctorTheme.dangerLight,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                service.isActive ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: accentColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
