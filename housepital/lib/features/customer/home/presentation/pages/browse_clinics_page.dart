import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:housepital/core/constants/api_constants.dart';
import 'clinic_details_page.dart';

class BrowseClinicsPage extends StatefulWidget {
  const BrowseClinicsPage({super.key});

  @override
  State<BrowseClinicsPage> createState() => _BrowseClinicsPageState();
}

class _BrowseClinicsPageState extends State<BrowseClinicsPage> {
  List<dynamic> _clinics = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchClinics();
  }

  Future<void> _fetchClinics() async {
    try {
      final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
      final response = await dio.get('/clinics');
      
      if (response.statusCode == 200) {
        setState(() {
          _clinics = response.data['data'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      appBar: AppBar(
        title: const Text('Browse Clinics'),
        backgroundColor: const Color(0xFF00D47F),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D47F)))
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _clinics.isEmpty
                  ? const Center(child: Text('No clinics available'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _clinics.length,
                      separatorBuilder: (c, i) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final clinic = _clinics[index];
                        return _buildClinicCard(context, clinic);
                      },
                    ),
    );
  }

  Widget _buildClinicCard(BuildContext context, dynamic clinic) {
    final name = clinic['name'] ?? 'Clinic';
    final address = clinic['address'] ?? {};
    final city = address['city'] ?? '';
    final street = address['street'] ?? '';
    final doctor = clinic['doctor'];
    final doctorName = doctor?['user']?['name'] ?? 'Unknown Doctor';
    final specialization = doctor?['specialization'] ?? '';
    final images = clinic['images'] as List<dynamic>?;
    final imageUrl = images?.isNotEmpty == true ? images!.first : null;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ClinicDetailsPage(clinicId: clinic['_id']),
          ),
        );
      },
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                height: 120,
                width: double.infinity,
                color: Colors.grey[200],
                child: imageUrl != null
                    ? Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.local_hospital, size: 40))
                    : const Center(child: Icon(Icons.local_hospital, size: 40, color: Colors.grey)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '$street, $city',
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 14, color: Color(0xFF00D47F)),
                      const SizedBox(width: 4),
                      Text(
                        'Dr. $doctorName',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      if (specialization.isNotEmpty) ...[
                        const Text(' • '),
                        Text(specialization, style: const TextStyle(color: Colors.grey)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
