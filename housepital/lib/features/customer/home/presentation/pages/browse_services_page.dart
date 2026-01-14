import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:housepital/core/constants/api_constants.dart';
import 'service_details_page.dart';

class BrowseServicesPage extends StatefulWidget {
  const BrowseServicesPage({super.key});

  @override
  State<BrowseServicesPage> createState() => _BrowseServicesPageState();
}

class _BrowseServicesPageState extends State<BrowseServicesPage> {
  List<dynamic> _services = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    try {
      final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
      final response = await dio.get('/services/public');
      
      if (response.statusCode == 200) {
        setState(() {
          _services = response.data['data'] ?? [];
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
        title: const Text('Browse Services'),
        backgroundColor: const Color(0xFF00D47F),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D47F)))
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _services.isEmpty
                  ? const Center(child: Text('No services available'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _services.length,
                      separatorBuilder: (c, i) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final service = _services[index];
                        return _buildServiceCard(context, service);
                      },
                    ),
    );
  }

  Widget _buildServiceCard(BuildContext context, dynamic service) {
    final name = service['name'] ?? 'Service';
    final price = (service['price'] ?? 0).toDouble();
    final duration = service['durationMinutes'] ?? 0;
    final category = service['category'] ?? '';
    final provider = service['providerId'];
    final providerName = provider?['user']?['name'] ?? 'Provider';
    final specialization = provider?['specialization'] ?? '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ServiceDetailsPage(serviceId: service['_id']),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF00D47F).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.medical_services, color: Color(0xFF00D47F), size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('$duration mins', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      if (category.isNotEmpty) ...[
                        const Text(' • ', style: TextStyle(color: Colors.grey)),
                        Text(category, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dr. $providerName${specialization.isNotEmpty ? " • $specialization" : ""}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${price.toStringAsFixed(0)} EGP',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00D47F),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
