import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_routes.dart';
import '../../data/models/clinic_model.dart';
import '../cubit/clinic_cubit.dart';
import '../theme/doctor_theme.dart';

class ClinicDetailsPage extends StatefulWidget {
  const ClinicDetailsPage({super.key});

  @override
  State<ClinicDetailsPage> createState() => _ClinicDetailsPageState();
}

class _ClinicDetailsPageState extends State<ClinicDetailsPage> {
  // Colors from DoctorTheme

  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final clinic = ModalRoute.of(context)!.settings.arguments as ClinicModel;

    return Scaffold(
      backgroundColor: DoctorTheme.background(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(
            context,
            AppRoutes.addClinic,
            arguments: clinic,
          );
        },
        backgroundColor: DoctorTheme.primary,
        foregroundColor: Colors.white,
        icon: Icon(Icons.edit_rounded),
        label: Text(
          'edit_clinic'.tr(),
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(clinic),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(clinic),
                  SizedBox(height: 16),
                  _sectionTitle('location_contact'.tr()),
                  SizedBox(height: 10),
                  _buildInfoCard(
                    children: [
                      _iconRow(
                        Icons.location_on_outlined,
                        '${clinic.address.street}, ${clinic.address.city}',
                      ),
                      const Divider(height: 24),
                      _iconRow(
                          Icons.phone_outlined, clinic.phone ?? 'no_phone'.tr()),
                    ],
                  ),
                  SizedBox(height: 16),
                  _sectionTitle('Schedule'),
                  SizedBox(height: 10),
                  _buildWorkingHoursCard(clinic),
                  SizedBox(height: 16),
                  _sectionTitle('clinic_settings'.tr()),
                  SizedBox(height: 10),
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
                  SizedBox(height: 16),
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmDelete(context, clinic),
                      icon: Icon(Icons.delete_outline_rounded),
                      label: Text('delete_clinic'.tr()),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                        side: BorderSide(color: Color(0xFFFCA5A5)),
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
      backgroundColor: DoctorTheme.primaryDark,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.zero,
        title: Container(
          width: double.infinity,
          padding:
              EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 40),
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
            style: TextStyle(
              color: DoctorTheme.surface(context),
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
                child: Center(
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
                      EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: DoctorTheme.textPrimary(context).withValues(alpha: 0.48),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${_currentImageIndex + 1} / ${clinic.images.length}',
                    style: TextStyle(
                      color: DoctorTheme.surface(context),
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
      padding: EdgeInsets.all(16),
      decoration: DoctorTheme.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusBadge(clinic.verificationStatus),
          SizedBox(height: 10),
          Text(
            clinic.description ?? 'no_description_provided'.tr(),
            style: TextStyle(
              color: DoctorTheme.textSecondary(context),
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
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 6),
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
      style: DoctorTheme.headingSmall(context),
    );
  }

  Widget _buildInfoCard({required List<Widget> children}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: DoctorTheme.cardDecoration(context),
      child: Column(children: children),
    );
  }

  Widget _buildWorkingHoursCard(ClinicModel clinic) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: DoctorTheme.cardDecoration(context),
      child: Column(
        children: clinic.workingHours.map((wh) {
          return Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: DoctorTheme.primary,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    wh.day.replaceFirst(wh.day[0], wh.day[0].toUpperCase()),
                    style: TextStyle(
                      color: DoctorTheme.textPrimary(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '${wh.openTime} - ${wh.closeTime}',
                  style: TextStyle(
                    color: DoctorTheme.primaryDark,
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
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: DoctorTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: DoctorTheme.primaryDark, size: 18),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: DoctorTheme.bodyMedium(context),
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
          title: Text('delete_clinic'.tr()),
          content: Text(
            'Are you sure you want to delete ${clinic.name}? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('cancel'.tr()),
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
              child: Text(
                'delete'.tr(),
                style: TextStyle(color: Color(0xFFDC2626)),
              ),
            ),
          ],
        );
      },
    );
  }
}
