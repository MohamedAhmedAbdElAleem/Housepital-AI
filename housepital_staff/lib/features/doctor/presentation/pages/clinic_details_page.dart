import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_routes.dart';
import '../../data/models/clinic_model.dart';
import '../cubit/clinic_cubit.dart';

class ClinicDetailsPage extends StatefulWidget {
  const ClinicDetailsPage({super.key});

  @override
  State<ClinicDetailsPage> createState() => _ClinicDetailsPageState();
}

class _ClinicDetailsPageState extends State<ClinicDetailsPage> {
  static const Color _bg = Color(0xFFF4F8FF);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _primary = Color(0xFF2664EC);
  static const Color _primaryDark = Color(0xFF1136A8);
  static const Color _textPrimary = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF475569);

  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final clinic = ModalRoute.of(context)!.settings.arguments as ClinicModel;

    return Scaffold(
      backgroundColor: _bg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(
            context,
            AppRoutes.addClinic,
            arguments: clinic,
          );
        },
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit_rounded),
        label: const Text(
          'Edit Clinic',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(clinic),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(clinic),
                  const SizedBox(height: 16),
                  _sectionTitle('Location & Contact'),
                  const SizedBox(height: 10),
                  _buildInfoCard(
                    children: [
                      _iconRow(
                        Icons.location_on_outlined,
                        '${clinic.address.street}, ${clinic.address.city}',
                      ),
                      const Divider(height: 24),
                      _iconRow(
                          Icons.phone_outlined, clinic.phone ?? 'No phone'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _sectionTitle('Schedule'),
                  const SizedBox(height: 10),
                  _buildWorkingHoursCard(clinic),
                  const SizedBox(height: 16),
                  _sectionTitle('Clinic Settings'),
                  const SizedBox(height: 10),
                  _buildInfoCard(
                    children: [
                      _iconRow(
                        Icons.bookmark_outline_rounded,
                        'Booking Mode: ${clinic.bookingMode.toUpperCase()}',
                      ),
                      const Divider(height: 24),
                      _iconRow(
                        Icons.timer_outlined,
                        'Slot Duration: ${clinic.slotDurationMinutes} mins',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmDelete(context, clinic),
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Delete Clinic'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                        side: const BorderSide(color: Color(0xFFFCA5A5)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(ClinicModel clinic) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: _primaryDark,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.zero,
        title: Container(
          width: double.infinity,
          padding:
              const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 40),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withValues(alpha: 0.72),
                Colors.transparent
              ],
            ),
          ),
          child: Text(
            clinic.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (clinic.images.isNotEmpty)
              PageView.builder(
                itemCount: clinic.images.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentImageIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Image.network(clinic.images[index], fit: BoxFit.cover);
                },
              )
            else
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFEAF2FF), Color(0xFFDCEAFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.apartment_rounded,
                    size: 84,
                    color: Color(0xFF8FADEB),
                  ),
                ),
              ),
            if (clinic.images.length > 1)
              Positioned(
                bottom: 62,
                right: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.48),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${_currentImageIndex + 1} / ${clinic.images.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(ClinicModel clinic) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD8E5FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusBadge(clinic.verificationStatus),
          const SizedBox(height: 10),
          Text(
            clinic.description ?? 'No description provided.',
            style: const TextStyle(
              color: _textSecondary,
              height: 1.4,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final normalized = status.toLowerCase();

    Color color;
    IconData icon;

    switch (normalized) {
      case 'approved':
        color = const Color(0xFF16A34A);
        icon = Icons.verified_rounded;
        break;
      case 'rejected':
        color = const Color(0xFFDC2626);
        icon = Icons.error_outline_rounded;
        break;
      default:
        color = const Color(0xFFF59E0B);
        icon = Icons.timer_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: _textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildInfoCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8E5FF)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildWorkingHoursCard(ClinicModel clinic) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8E5FF)),
      ),
      child: Column(
        children: clinic.workingHours.map((wh) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: _primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    wh.day.replaceFirst(wh.day[0], wh.day[0].toUpperCase()),
                    style: const TextStyle(
                      color: _textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '${wh.openTime} - ${wh.closeTime}',
                  style: const TextStyle(
                    color: _primaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _iconRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: _primaryDark, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: _textSecondary,
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, ClinicModel clinic) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Clinic?'),
          content: Text(
            'Are you sure you want to delete ${clinic.name}? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                final clinicId = clinic.id;
                if (clinicId == null || clinicId.isEmpty) {
                  return;
                }

                context.read<ClinicCubit>().deleteClinic(clinicId);
                Navigator.pop(context);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Color(0xFFDC2626)),
              ),
            ),
          ],
        );
      },
    );
  }
}
