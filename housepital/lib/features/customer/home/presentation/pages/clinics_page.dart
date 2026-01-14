import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // Or use your ApiClient
import '../../../../../../core/constants/api_constants.dart';
import '../../../../../../core/network/api_service.dart'; // Adjust path
import 'package:housepital/shared/models/doctor_model.dart';
import 'doctor_details_page.dart'; // Will create next

class ClinicsPage extends StatefulWidget {
  const ClinicsPage({super.key});

  @override
  State<ClinicsPage> createState() => _ClinicsPageState();
}

class _ClinicsPageState extends State<ClinicsPage> {
  // Using a simple state here for MVP, could use Cubit later
  List<DoctorModel> _doctors = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    try {
      // Use ApiService or Dio with proper BaseURL from constants
      final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
      
      final response = await dio.get('/doctors');
      debugPrint("Doctors Response: ${response.data}");
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        setState(() {
          _doctors = data.map((e) => DoctorModel.fromJson(e)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching doctors: $e");
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      appBar: AppBar(
        title: const Text('Find a Doctor'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _doctors.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final doctor = _doctors[index];
                    return _buildDoctorCard(context, doctor);
                  },
                ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, DoctorModel doctor) {
    return GestureDetector(
      onTap: () {
         Navigator.push(
           context,
           MaterialPageRoute(builder: (_) => DoctorDetailsPage(doctor: doctor)),
         );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
             BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
             ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: doctor.profilePicture.isNotEmpty 
                  ? NetworkImage(doctor.profilePicture) 
                  : null,
              child: doctor.profilePicture.isEmpty 
                  ? const Icon(Icons.person, size: 30) 
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr. ${doctor.name}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    doctor.specialization,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                      const Text(' 4.8 (120 reviews)', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
