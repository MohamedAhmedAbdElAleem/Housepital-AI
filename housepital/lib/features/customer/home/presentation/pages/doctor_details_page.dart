import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:housepital/core/constants/api_constants.dart';
import 'package:housepital/shared/models/doctor_model.dart';
import 'package:housepital/shared/models/service_model.dart';
import 'package:housepital/shared/models/clinic_model.dart';
import 'doctor_booking_flow.dart';

class DoctorDetailsPage extends StatefulWidget {
  final DoctorModel doctor;

  const DoctorDetailsPage({super.key, required this.doctor});

  @override
  State<DoctorDetailsPage> createState() => _DoctorDetailsPageState();
}

class _DoctorDetailsPageState extends State<DoctorDetailsPage> {
  late DoctorModel _fullDoctor;
  bool _isLoading = true;
  String? _error;

  ServiceModel? _selectedService;
  ClinicModel? _selectedClinic;

  @override
  void initState() {
    super.initState();
    _fetchDoctorDetails();
  }

  Future<void> _fetchDoctorDetails() async {
    try {
      final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
      // Call /api/doctors/:id to get full details including services and clinics
      final response = await dio.get('/doctors/${widget.doctor.id}');
      
      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (mounted) {
          setState(() {
            _fullDoctor = DoctorModel.fromJson(data);
            
            // Auto-select defaults if available
            if (_fullDoctor.services.isNotEmpty) {
              // Try to find a 'Consultation' service by default, or the first one
              _selectedService = _fullDoctor.services.firstWhere(
                (s) => s.name.toLowerCase().contains('consultation'),
                orElse: () => _fullDoctor.services.first,
              );
            }
            
            if (_fullDoctor.clinics.isNotEmpty) {
              _selectedClinic = _fullDoctor.clinics.first;
            }

            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load details: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text(_error!)),
      );
    }

    final doctor = _fullDoctor; // Use the full details

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Dr. ${doctor.name}'),
              background: doctor.profilePicture.isNotEmpty
                  ? Image.network(
                      doctor.profilePicture,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey),
                    )
                  : Container(color: Colors.blueGrey),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                 Text(
                   doctor.specialization,
                   style: const TextStyle(fontSize: 18, color: Colors.grey),
                 ),
                 const SizedBox(height: 16),
                 const Text(
                   'About',
                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                 ),
                 const SizedBox(height: 8),
                 Text(
                   doctor.bio.isNotEmpty ? doctor.bio : 'No bio available.',
                   style: const TextStyle(fontSize: 16),
                 ),
                 
                 const SizedBox(height: 24),
                 // Stats
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceAround,
                   children: [
                     _buildStat('Experience', '${doctor.experienceYears} Years'),
                     _buildStat('Patients', '500+'),
                     _buildStat('Reviews', '4.9 ⭐'),
                   ],
                 ),

                 const Divider(height: 48),

                 // --- Services Section ---
                 const Text(
                   'Select Service',
                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                 ),
                 const SizedBox(height: 12),
                 if (doctor.services.isEmpty)
                   const Text('No services available', style: TextStyle(color: Colors.grey))
                 else
                   Wrap(
                     spacing: 12,
                     runSpacing: 12,
                     children: doctor.services.map((service) {
                       final isSelected = _selectedService?.id == service.id;
                       return ChoiceChip(
                         label: Text('${service.name} (${service.price} EGP)'),
                         selected: isSelected,
                         onSelected: (selected) {
                           setState(() {
                             _selectedService = selected ? service : null;
                           });
                         },
                         selectedColor: const Color(0xFF00D47F).withOpacity(0.2),
                         labelStyle: TextStyle(
                           color: isSelected ? const Color(0xFF00D47F) : Colors.black,
                           fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                         ),
                       );
                     }).toList(),
                   ),

                 const SizedBox(height: 24),

                 // --- Clinics Section ---
                 const Text(
                   'Select Clinic Location',
                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                 ),
                 const SizedBox(height: 12),
                 if (doctor.clinics.isEmpty)
                   const Text('No clinics available', style: TextStyle(color: Colors.grey))
                 else
                   ListView.separated(
                     shrinkWrap: true,
                     physics: const NeverScrollableScrollPhysics(),
                     itemCount: doctor.clinics.length,
                     separatorBuilder: (c, i) => const SizedBox(height: 12),
                     itemBuilder: (context, index) {
                       final clinic = doctor.clinics[index];
                       final isSelected = _selectedClinic?.id == clinic.id;
                       return InkWell(
                         onTap: () {
                           setState(() => _selectedClinic = clinic);
                         },
                         child: Container(
                           padding: const EdgeInsets.all(16),
                           decoration: BoxDecoration(
                             color: isSelected ? const Color(0xFF00D47F).withOpacity(0.05) : Colors.white,
                             border: Border.all(
                               color: isSelected ? const Color(0xFF00D47F) : Colors.grey.shade300,
                               width: 2,
                             ),
                             borderRadius: BorderRadius.circular(12),
                           ),
                           child: Row(
                             children: [
                               const Icon(Icons.location_on, color: Colors.grey),
                               const SizedBox(width: 12),
                               Expanded(
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Text(
                                       clinic.name,
                                       style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                     ),
                                     Text(
                                       "${clinic.address.city}, ${clinic.address.street}",
                                       style: const TextStyle(color: Colors.grey),
                                     ),
                                   ],
                                 ),
                               ),
                               if (isSelected)
                                 const Icon(Icons.check_circle, color: Color(0xFF00D47F)),
                             ],
                           ),
                         ),
                       );
                     },
                   ),

                 const SizedBox(height: 40),

                 SizedBox(
                   width: double.infinity,
                   child: ElevatedButton(
                     onPressed: (_selectedService != null && _selectedClinic != null)
                         ? () {
                             Navigator.push(
                               context,
                               MaterialPageRoute(
                                 builder: (_) => DoctorBookingFlow(
                                   doctor: doctor,
                                   service: _selectedService!,
                                   clinic: _selectedClinic!,
                                 ),
                               ),
                             );
                           }
                         : null, // Disable if selection missing
                     style: ElevatedButton.styleFrom(
                       padding: const EdgeInsets.all(16),
                       backgroundColor: const Color(0xFF00D47F),
                       disabledBackgroundColor: Colors.grey.shade300,
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(12),
                       ),
                     ),
                     child: Text(
                       (_selectedService != null && _selectedClinic != null)
                           ? 'Book Appointment'
                           : 'Select Service & Clinic',
                       style: const TextStyle(fontSize: 18),
                     ),
                   ),
                 ),
                 const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
