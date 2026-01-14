import 'package:flutter/material.dart';
import '../../data/models/clinic_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/doctor_cubit.dart';

class ClinicDetailsPage extends StatefulWidget {
  const ClinicDetailsPage({super.key});

  @override
  State<ClinicDetailsPage> createState() => _ClinicDetailsPageState();
}

class _ClinicDetailsPageState extends State<ClinicDetailsPage> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final clinic = ModalRoute.of(context)!.settings.arguments as ClinicModel;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(clinic),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(clinic),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Location & Contact'),
                  const SizedBox(height: 12),
                  _buildContactInfo(clinic),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Schedule'),
                  const SizedBox(height: 12),
                  _buildWorkingHours(clinic),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Settings'),
                  const SizedBox(height: 12),
                  _buildSettingsCard(clinic),
                  const SizedBox(height: 40),
                  Center(
                    child: TextButton.icon(
                      onPressed: () => _confirmDelete(context, clinic),
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: const Text(
                        'Delete Clinic',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(
            context,
            '/doctor/clinics/add', // AppRoutes.addClinic
            arguments: clinic,
          );
        },
        backgroundColor: Colors.blue[800],
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text('Edit Clinic', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildSliverAppBar(ClinicModel clinic) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.blue[900],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.zero,
        title: Container(
          width: double.infinity,
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16,
            top: 40,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black.withOpacity(0.8), Colors.transparent],
            ),
          ),
          child: Text(
            clinic.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
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
                  setState(() => _currentImageIndex = index);
                },
                itemBuilder: (context, index) {
                  return Image.network(clinic.images[index], fit: BoxFit.cover);
                },
              )
            else
              Container(
                color: Colors.blue[50],
                child: Icon(Icons.apartment, size: 80, color: Colors.blue[200]),
              ),

            // Page Indicator
            if (clinic.images.length > 1)
              Positioned(
                bottom: 60, // Above the title gradient
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentImageIndex + 1} / ${clinic.images.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ClinicModel clinic) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusBadge(clinic.verificationStatus),
              const SizedBox(height: 8),
              Text(
                clinic.description ?? 'No description provided.',
                style: TextStyle(color: Colors.grey[600], height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;
    switch (status.toLowerCase()) {
      case 'approved':
        color = Colors.green;
        icon = Icons.verified;
        break;
      case 'rejected':
        color = Colors.red;
        icon = Icons.error_outline;
        break;
      default:
        color = Colors.orange;
        icon = Icons.timer_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
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
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blue[900],
      ),
    );
  }

  Widget _buildContactInfo(ClinicModel clinic) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          _buildRowIcon(
            Icons.location_on,
            '${clinic.address.street}, ${clinic.address.city}',
          ),
          const Divider(height: 24),
          _buildRowIcon(Icons.phone, clinic.phone ?? 'No phone'),
        ],
      ),
    );
  }

  Widget _buildWorkingHours(ClinicModel clinic) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: clinic.workingHours.map((wh) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  wh.day.replaceFirst(wh.day[0], wh.day[0].toUpperCase()),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ), // Capitalize
                Text(
                  '${wh.openTime} - ${wh.closeTime}',
                  style: TextStyle(color: Colors.blue[800]),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSettingsCard(ClinicModel clinic) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          _buildRowIcon(
            Icons.bookmark_border,
            'Booking Mode: ${clinic.bookingMode.toUpperCase()}',
          ),
          const SizedBox(height: 12),
          _buildRowIcon(
            Icons.timer_outlined,
            'Slot Duration: ${clinic.slotDurationMinutes} mins',
          ),
        ],
      ),
    );
  }

  Widget _buildRowIcon(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue[700], size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
      ],
    );
  }

  void _confirmDelete(BuildContext context, ClinicModel clinic) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Clinic?'),
        content: Text(
          'Are you sure you want to delete ${clinic.name}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<DoctorCubit>().deleteClinic(clinic.id!);
              Navigator.pop(context); // Go back to MyClinics
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
