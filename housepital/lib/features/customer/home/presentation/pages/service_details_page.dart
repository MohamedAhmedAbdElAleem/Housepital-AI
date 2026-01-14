import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:housepital/core/constants/api_constants.dart';
import 'package:housepital/shared/models/doctor_model.dart';
import 'package:housepital/shared/models/service_model.dart';
import 'package:housepital/shared/models/clinic_model.dart';
import 'doctor_booking_flow.dart';

class ServiceDetailsPage extends StatefulWidget {
  final String serviceId;

  const ServiceDetailsPage({super.key, required this.serviceId});

  @override
  State<ServiceDetailsPage> createState() => _ServiceDetailsPageState();
}

class _ServiceDetailsPageState extends State<ServiceDetailsPage> {
  ServiceModel? _service;
  DoctorModel? _doctor;
  List<ClinicModel> _clinics = [];
  bool _isLoading = true;
  String? _error;
  ClinicModel? _selectedClinic;

  @override
  void initState() {
    super.initState();
    _fetchServiceDetails();
  }

  Future<void> _fetchServiceDetails() async {
    try {
      final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
      
      // Fetch all services and find this one
      final response = await dio.get('/services/public');
      final services = response.data['data'] as List;
      final serviceData = services.firstWhere(
        (s) => s['_id'] == widget.serviceId,
        orElse: () => null,
      );
      
      if (serviceData == null) {
        setState(() {
          _error = 'Service not found';
          _isLoading = false;
        });
        return;
      }

      _service = ServiceModel.fromJson(serviceData);
      
      // Get doctor info
      final providerData = serviceData['providerId'];
      if (providerData != null) {
        // Fetch full doctor details
        final doctorId = providerData is String ? providerData : providerData['_id'];
        try {
          final doctorResponse = await dio.get('/doctors/$doctorId');
          final doctorData = doctorResponse.data['data'];
          _doctor = DoctorModel.fromJson(doctorData);
          
          // Get clinics
          if (doctorData['clinics'] != null) {
            _clinics = (doctorData['clinics'] as List)
                .map((c) => ClinicModel.fromJson(c))
                .toList();
            // Auto-select first clinic
            if (_clinics.isNotEmpty) {
              _selectedClinic = _clinics.first;
            }
          }
        } catch (e) {
          debugPrint('Could not fetch doctor: $e');
        }
      }

      setState(() {
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

    if (_error != null || _service == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Service Details')),
        body: Center(child: Text(_error ?? 'Unknown error')),
      );
    }

    final service = _service!;

    return Scaffold(
      appBar: AppBar(
        title: Text(service.name),
        backgroundColor: const Color(0xFF00D47F),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00D47F), Color(0xFF00B870)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.medical_services, color: Colors.white, size: 40),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${service.durationMinutes} minutes',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${service.price.toStringAsFixed(0)} EGP',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Description
            if (service.description?.isNotEmpty == true) ...[
              const SizedBox(height: 24),
              Text('About', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(service.description ?? ''),
            ],

            // Doctor
            if (_doctor != null) ...[
              const SizedBox(height: 24),
              Text('Provider', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(' ${_doctor!.rating.toStringAsFixed(1)}'),
                    ],
                  ),
                ),
              ),
            ],

            // Clinic Selection
            if (_clinics.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Select Clinic', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              ..._clinics.map((clinic) {
                final isSelected = _selectedClinic?.id == clinic.id;
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
                    onTap: () => setState(() => _selectedClinic = clinic),
                    leading: const Icon(Icons.location_on, color: Colors.grey),
                    title: Text(clinic.name),
                    subtitle: Text('${clinic.address.street}, ${clinic.address.city}'),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Color(0xFF00D47F))
                        : null,
                  ),
                );
              }).toList(),
            ],

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: (_doctor != null)
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DoctorBookingFlow(
                          doctor: _doctor!,
                          service: service,
                          clinic: _selectedClinic!, // May be null for home visits
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
            child: const Text('Book Now', style: TextStyle(fontSize: 18)),
          ),
        ),
      ),
    );
  }
}
