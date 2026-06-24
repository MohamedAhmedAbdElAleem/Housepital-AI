import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_routes.dart';
import '../../data/models/clinic_model.dart';
import '../cubit/clinic_cubit.dart';
import '../theme/doctor_theme.dart';
import '../widgets/background_blobs.dart';
import '../widgets/glass_header.dart';
import '../widgets/empty_state_widget.dart';

class MyClinicsPage extends StatefulWidget {
  const MyClinicsPage({super.key});

  @override
  State<MyClinicsPage> createState() => _MyClinicsPageState();
}

class _MyClinicsPageState extends State<MyClinicsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ClinicCubit>().fetchClinics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DoctorTheme.background(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addClinic),
        backgroundColor: DoctorTheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: Icon(Icons.add_location_alt_outlined),
        label: Text(
          'Add Clinic',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: BackgroundBlobs(
        child: SafeArea(
          child: Column(
            children: [
              GlassHeader(
                title: 'My Clinics',
                subtitle: 'Manage locations and availability',
                onBack: () => Navigator.maybePop(context),
                actionIcon: Icons.refresh_rounded,
                actionTooltip: 'Refresh',
                onAction: () =>
                    context.read<ClinicCubit>().fetchClinics(),
              ),
              Expanded(
                child: BlocBuilder<ClinicCubit, ClinicState>(
                  builder: (context, state) {
                    if (state is ClinicLoading) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: DoctorTheme.primary,
                        ),
                      );
                    }

                    if (state is ClinicError) {
                      return _buildErrorState(state.message);
                    }

                    if (state is! ClinicLoaded) {
                      return const SizedBox.shrink();
                    }

                    if (state.clinics.isEmpty) {
                      return const EmptyStateWidget(
                        icon: Icons.add_business_outlined,
                        title: 'No clinics yet',
                        subtitle:
                            'Add your first clinic to start receiving appointments and managing your schedule.',
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<ClinicCubit>().fetchClinics();
                      },
                      color: DoctorTheme.primary,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(16, 8, 16, 90),
                        itemCount: state.clinics.length,
                        itemBuilder: (context, index) {
                          return _buildClinicCard(state.clinics[index]);
                        },
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

  // ── Error State ─────────────────────────────────────────────────

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64,
              color: DoctorTheme.danger.withValues(alpha: 0.7)),
            SizedBox(height: 16),
            Text('Could not load clinics', style: DoctorTheme.headingSmall(context)),
            SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: DoctorTheme.bodyMedium(context)),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.read<ClinicCubit>().fetchClinics(),
              style: ElevatedButton.styleFrom(
                backgroundColor: DoctorTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: Icon(Icons.refresh_rounded),
              label: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Clinic Card ─────────────────────────────────────────────────

  Widget _buildClinicCard(ClinicModel clinic) {
    final location = '${clinic.address.street}, ${clinic.address.city}';
    final bookingMode = clinic.bookingMode == 'slots' ? 'Appointments' : 'Queue';

    return Container(
      margin: EdgeInsets.only(bottom: 16),
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
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.clinicDetails, arguments: clinic);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image Area ──
              Stack(
                children: [
                  Container(
                    height: 158,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                      gradient: clinic.images.isEmpty
                          ? LinearGradient(
                              colors: [Color(0xFFF0F6FF), Color(0xFFE7F1FF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      image: clinic.images.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(clinic.images.first),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: clinic.images.isEmpty
                        ? Center(
                            child: Icon(Icons.local_hospital_outlined, size: 56, color: Color(0xFF93B4F7)),
                          )
                        : null,
                  ),
                  // Gradient overlay for readability
                  if (clinic.images.isNotEmpty)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              DoctorTheme.textPrimary(context).withValues(alpha: 0.35),
                              Colors.transparent,
                            ],
                          ),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                        ),
                      ),
                    ),
                  // Status badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _buildStatusBadge(clinic.verificationStatus),
                  ),
                  // Image count
                  if (clinic.images.length > 1)
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: DoctorTheme.textPrimary(context).withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.photo_library_rounded, size: 13, color: DoctorTheme.surface(context)),
                            SizedBox(width: 4),
                            Text(
                              '${clinic.images.length}',
                              style: TextStyle(color: DoctorTheme.surface(context), fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              // ── Details ──
              Padding(
                padding: EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            clinic.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: DoctorTheme.headingSmall(context),
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_ios_rounded, size: 14,
                          color: DoctorTheme.textSecondary.withValues(alpha: 0.7)),
                      ],
                    ),
                    SizedBox(height: 10),
                    _buildIconText(Icons.location_on_outlined, location),
                    SizedBox(height: 6),
                    _buildIconText(Icons.phone_in_talk_outlined, clinic.phone ?? 'No contact info'),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildInfoChip(icon: Icons.access_time_rounded, text: '${clinic.workingHours.length} Work Days'),
                        _buildInfoChip(icon: Icons.bookmark_outline, text: bookingMode),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final normalized = status.toLowerCase();
    Color color;
    String text;
    IconData icon;

    switch (normalized) {
      case 'approved':
        color = DoctorTheme.success;
        text = 'Verified';
        icon = Icons.verified_rounded;
        break;
      case 'rejected':
        color = DoctorTheme.danger;
        text = 'Rejected';
        icon = Icons.cancel_rounded;
        break;
      default:
        color = DoctorTheme.warning;
        text = 'Pending';
        icon = Icons.hourglass_top_rounded;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.28), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: DoctorTheme.surface(context)),
          SizedBox(width: 4),
          Text(text, style: TextStyle(color: DoctorTheme.surface(context), fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: DoctorTheme.textSecondary.withValues(alpha: 0.75)),
        SizedBox(width: 8),
        Expanded(
          child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: DoctorTheme.bodySmall(context)),
        ),
      ],
    );
  }

  Widget _buildInfoChip({required IconData icon, required String text}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: DoctorTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(DoctorTheme.radiusChip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: DoctorTheme.primaryDark),
          SizedBox(width: 6),
          Text(text, style: TextStyle(color: DoctorTheme.primaryDark, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
