import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:housepital/core/constants/api_constants.dart';
import 'package:housepital/shared/models/doctor_model.dart';
import 'package:housepital/shared/models/service_model.dart';
import 'package:housepital/shared/models/clinic_model.dart';
import 'doctor_booking_flow.dart';

class ClinicDetailsPage extends StatefulWidget {
  final String clinicId;

  const ClinicDetailsPage({super.key, required this.clinicId});

  @override
  State<ClinicDetailsPage> createState() => _ClinicDetailsPageState();
}

class _ClinicDetailsPageState extends State<ClinicDetailsPage> {
  Map<String, dynamic>? _clinic;
  DoctorModel? _doctor;
  List<ServiceModel> _services = [];
  bool _isLoading = true;
  String? _error;
  ServiceModel? _selectedService;

  @override
  void initState() {
    super.initState();
    _fetchClinicDetails();
  }

  Future<void> _fetchClinicDetails() async {
    try {
      final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
      
      // Fetch clinic by ID - we need to add this endpoint or use a workaround
      // For now, let's fetch all clinics and filter (not ideal but works for MVP)
      final clinicsResponse = await dio.get('/clinics');
      final clinics = clinicsResponse.data['data'] as List;
      final clinic = clinics.firstWhere((c) => c['_id'] == widget.clinicId, orElse: () => null);
      
      if (clinic == null) {
        setState(() {
          _error = 'Clinic not found';
          _isLoading = false;
        });
        return;
      }

      // Get doctor ID from clinic
      final doctorId = clinic['doctor']?['_id'] ?? clinic['doctor'];
      
      // Fetch doctor details to get services
      if (doctorId != null) {
        try {
          final doctorResponse = await dio.get('/doctors/$doctorId');
          final doctorData = doctorResponse.data['data'];
          _doctor = DoctorModel.fromJson(doctorData);
          
          // Get services that are available at THIS clinic
          if (doctorData['services'] != null) {
            final allServices = (doctorData['services'] as List)
                .map((s) => ServiceModel.fromJson(s))
                .toList();
            // Filter services that include this clinic
            _services = allServices.where((s) => 
              s.clinics.contains(widget.clinicId) || s.clinics.isEmpty
            ).toList();
          }
        } catch (e) {
          debugPrint('Could not fetch doctor details: $e');
        }
      }

      setState(() {
        _clinic = clinic;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF00D47F))),
      );
    }

    if (_error != null || _clinic == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Clinic Details')),
        body: Center(child: Text(_error ?? 'Unknown error')),
      );
    }

    final clinic = _clinic!;
    final name = clinic['name'] ?? 'Clinic';
    final description = clinic['description'] ?? '';
    final address = clinic['address'] ?? {};
    final images = clinic['images'] as List<dynamic>?;
    final imageUrl = images?.isNotEmpty == true ? images!.first : null;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF00D47F),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(name),
              background: imageUrl != null
                  ? Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: Colors.grey))
                  : Container(color: const Color(0xFF009960)),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Address
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.location_on, color: Color(0xFF00D47F)),
                    title: Text('${address['street'] ?? ''}, ${address['city'] ?? ''}'),
                    subtitle: Text(address['area'] ?? ''),
                  ),
                ),
                
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('About', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(description),
                ],

                // Doctor Info
                if (_doctor != null) ...[
                  const SizedBox(height: 24),
                  Text('Doctor', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: _doctor!.profilePicture.isNotEmpty
                            ? NetworkImage(_doctor!.profilePicture)
                            : null,
                        child: _doctor!.profilePicture.isEmpty ? const Icon(Icons.person) : null,
                      ),
                      title: Text('Dr. ${_doctor!.name}'),
                      subtitle: Text(_doctor!.specialization),
                    ),
                  ),
                ],

                // Services
                const SizedBox(height: 24),
                Text('Select Service', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                
                if (_services.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No services available at this clinic'),
                    ),
                  )
                else
                  ..._services.map((service) {
                    final isSelected = _selectedService?.id == service.id;
                    return Card(
                      color: isSelected ? const Color(0xFF00D47F).withOpacity(0.1) : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFF00D47F) : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ListTile(
                        onTap: () => setState(() => _selectedService = service),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00D47F).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.medical_services, color: Color(0xFF00D47F)),
                        ),
                        title: Text(service.name),
                        subtitle: Text('${service.durationMinutes} mins'),
                        trailing: Text(
                          '${service.price.toStringAsFixed(0)} EGP',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00D47F),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  }).toList(),

                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: (_selectedService != null && _doctor != null)
                ? () {
                    // Create ClinicModel from the raw data
                    final clinicModel = ClinicModel.fromJson(clinic);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DoctorBookingFlow(
                          doctor: _doctor!,
                          service: _selectedService!,
                          clinic: clinicModel,
                        ),
                      ),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: const Color(0xFF00D47F),
              disabledBackgroundColor: Colors.grey[300],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              _selectedService != null ? 'Book Now' : 'Select a Service',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}
