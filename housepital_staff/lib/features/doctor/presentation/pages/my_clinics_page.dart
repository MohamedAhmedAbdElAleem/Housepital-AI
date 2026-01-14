import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_routes.dart';
import '../cubit/doctor_cubit.dart';
import '../../data/models/clinic_model.dart';
import 'dart:io';

class MyClinicsPage extends StatefulWidget {
  const MyClinicsPage({super.key});

  @override
  State<MyClinicsPage> createState() => _MyClinicsPageState();
}

class _MyClinicsPageState extends State<MyClinicsPage> {
  @override
  void initState() {
    super.initState();
    context.read<DoctorCubit>().fetchClinics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'My Clinics',
          style: TextStyle(
            color: Colors.blueAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blueAccent),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [Colors.blue, Colors.blueAccent],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.addClinic),
          icon: const Icon(
            Icons.add_location_alt_outlined,
            color: Colors.white,
          ),
          label: const Text(
            'Add New Clinic',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: BlocBuilder<DoctorCubit, DoctorState>(
          builder: (context, state) {
            if (state is DoctorLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DoctorError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: TextStyle(color: Colors.red[800]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<DoctorCubit>().fetchClinics(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else if (state is DoctorClinicsLoaded) {
              if (state.clinics.isEmpty) return _buildEmptyState();
              return RefreshIndicator(
                onRefresh: () async =>
                    context.read<DoctorCubit>().fetchClinics(),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    100,
                    16,
                    80,
                  ), // Top padding for transparency
                  itemCount: state.clinics.length,
                  itemBuilder: (context, index) =>
                      _buildPremiumClinicCard(state.clinics[index]),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.blue.withOpacity(0.1), blurRadius: 20),
              ],
            ),
            child: Icon(
              Icons.add_business_outlined,
              size: 80,
              color: Colors.blue[200],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Expand Your Practice',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Add your clinics to manage appointments, schedules, and more from one place.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumClinicCard(ClinicModel clinic) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
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
              // Image Header (Carousel placeholder)
              Stack(
                children: [
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      color: Colors.grey[100],
                      image: clinic.images.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(clinic.images.first),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: clinic.images.isEmpty
                        ? Icon(
                            Icons.apartment_rounded,
                            size: 60,
                            color: Colors.grey[300],
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
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: Colors.amber[700],
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '4.8 (120)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            clinic.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildIconText(
                      Icons.location_on_outlined,
                      '${clinic.address.street}, ${clinic.address.city}',
                    ),
                    const SizedBox(height: 6),
                    _buildIconText(
                      Icons.phone_in_talk_outlined,
                      clinic.phone ?? 'No contact info',
                    ),
                    const SizedBox(height: 16),
                    Divider(color: Colors.grey[100]),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoChip(
                          Icons.access_time_rounded,
                          '${clinic.workingHours.length} Work Days',
                        ),
                        _buildInfoChip(
                          Icons.bookmark_outline,
                          '${clinic.bookingMode == 'slots' ? 'Appointments' : 'Queue'}',
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
    Color color;
    String text;

    switch (status.toLowerCase()) {
      case 'approved':
        color = Colors.green;
        text = 'Verified';
        break;
      case 'rejected':
        color = Colors.red;
        text = 'Rejected';
        break;
      default:
        color = Colors.orange;
        text = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status.toLowerCase() == 'approved') ...[
            const Icon(Icons.verified, size: 14, color: Colors.white),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue[50], // Very light blue
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.blue[700]),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.blue[800],
            ),
          ),
        ],
      ),
    );
  }
}
