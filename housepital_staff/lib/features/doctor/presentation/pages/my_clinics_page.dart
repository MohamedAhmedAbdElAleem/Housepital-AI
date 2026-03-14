import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_routes.dart';
import '../../data/models/clinic_model.dart';
import '../cubit/clinic_cubit.dart';

class MyClinicsPage extends StatefulWidget {
  const MyClinicsPage({super.key});

  @override
  State<MyClinicsPage> createState() => _MyClinicsPageState();
}

class _MyClinicsPageState extends State<MyClinicsPage> {
  static const Color _bg = Color(0xFFF4F8FF);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _primary = Color(0xFF2664EC);
  static const Color _primaryDark = Color(0xFF1136A8);
  static const Color _secondary = Color(0xFF3498BB);
  static const Color _textPrimary = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF475569);

  @override
  void initState() {
    super.initState();
    context.read<ClinicCubit>().fetchClinics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addClinic),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text(
          'Add Clinic',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: -120,
            right: -80,
            child: _buildBackgroundBlob(
              size: 280,
              colors: const [Color(0x2A2664EC), Color(0x003498BB)],
            ),
          ),
          Positioned(
            top: 220,
            left: -100,
            child: _buildBackgroundBlob(
              size: 240,
              colors: const [Color(0x1A1136A8), Color(0x002664EC)],
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: BlocBuilder<ClinicCubit, ClinicState>(
                    builder: (context, state) {
                      if (state is ClinicLoading) {
                        return const Center(
                          child: CircularProgressIndicator(color: _primary),
                        );
                      }

                      if (state is ClinicError) {
                        return _buildErrorState(state.message);
                      }

                      if (state is! ClinicLoaded) {
                        return const SizedBox.shrink();
                      }

                      if (state.clinics.isEmpty) {
                        return _buildEmptyState();
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<ClinicCubit>().fetchClinics();
                        },
                        color: _primary,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
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
        ],
      ),
    );
  }

  Widget _buildBackgroundBlob(
      {required double size, required List<Color> colors}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_primaryDark, _primary, _secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _primaryDark.withValues(alpha: 0.24),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              color: Colors.white,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.18),
                fixedSize: const Size(40, 40),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Clinics',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Manage locations and availability',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => context.read<ClinicCubit>().fetchClinics(),
              icon: const Icon(Icons.refresh_rounded),
              color: Colors.white,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.18),
                fixedSize: const Size(40, 40),
              ),
              tooltip: 'Refresh',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.red.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            const Text(
              'Could not load clinics',
              style: TextStyle(
                color: _textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.read<ClinicCubit>().fetchClinics(),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    _primary.withValues(alpha: 0.15),
                    _secondary.withValues(alpha: 0.08),
                  ],
                ),
              ),
              child: const Icon(
                Icons.add_business_outlined,
                size: 48,
                color: _primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No clinics yet',
              style: TextStyle(
                color: _textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your first clinic to start receiving appointments and managing your schedule in one place.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClinicCard(ClinicModel clinic) {
    final location = '${clinic.address.street}, ${clinic.address.city}';
    final bookingMode =
        clinic.bookingMode == 'slots' ? 'Appointments' : 'Queue';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD8E5FF)),
        boxShadow: [
          BoxShadow(
            color: _primaryDark.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.clinicDetails,
              arguments: clinic,
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    height: 158,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(22)),
                      gradient: clinic.images.isEmpty
                          ? const LinearGradient(
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
                        ? const Center(
                            child: Icon(
                              Icons.local_hospital_outlined,
                              size: 56,
                              color: Color(0xFF93B4F7),
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _buildStatusBadge(clinic.verificationStatus),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.star_rounded,
                              size: 15, color: Color(0xFFF59E0B)),
                          SizedBox(width: 4),
                          Text(
                            '4.8 (120)',
                            style: TextStyle(
                              color: _textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
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
                            style: const TextStyle(
                              color: _textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: _textSecondary.withValues(alpha: 0.7),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildIconText(Icons.location_on_outlined, location),
                    const SizedBox(height: 6),
                    _buildIconText(Icons.phone_in_talk_outlined,
                        clinic.phone ?? 'No contact info'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildInfoChip(
                          icon: Icons.access_time_rounded,
                          text: '${clinic.workingHours.length} Work Days',
                        ),
                        _buildInfoChip(
                          icon: Icons.bookmark_outline,
                          text: bookingMode,
                        ),
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
        color = const Color(0xFF16A34A);
        text = 'Verified';
        icon = Icons.verified_rounded;
        break;
      case 'rejected':
        color = const Color(0xFFDC2626);
        text = 'Rejected';
        icon = Icons.cancel_rounded;
        break;
      default:
        color = const Color(0xFFF59E0B);
        text = 'Pending';
        icon = Icons.hourglass_top_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.28),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _textSecondary.withValues(alpha: 0.75)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _primaryDark),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: _primaryDark,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
