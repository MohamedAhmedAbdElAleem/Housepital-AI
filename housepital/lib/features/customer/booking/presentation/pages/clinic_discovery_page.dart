import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/network/api_service.dart';
import 'clinic_booking_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 🏥  CLINIC DISCOVERY PAGE
// Lists all available clinics so the patient can then book an appointment.
// ─────────────────────────────────────────────────────────────────────────────

class ClinicDiscoveryPage extends StatefulWidget {
  const ClinicDiscoveryPage({super.key});

  @override
  State<ClinicDiscoveryPage> createState() => _ClinicDiscoveryPageState();
}

class _ClinicDiscoveryPageState extends State<ClinicDiscoveryPage> {
  static const _primary = Color(0xFF3B82F6);
  static const _surface = Color(0xFFF8FAFC);

  List<dynamic> _clinics = [];
  List<dynamic> _filtered = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchClinics();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
        _applyFilter();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchClinics() async {
    try {
      final api = ApiService();
      final response = await api.get('/api/clinics/public');
      final data = response is Map ? (response['data'] ?? []) : response;
      if (mounted) {
        setState(() {
          _clinics = data is List ? data : [];
          _filtered = _clinics;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filtered = _clinics;
      return;
    }
    _filtered =
        _clinics.where((c) {
          final name = (c['name'] ?? '').toString().toLowerCase();
          final doctor =
              ((c['doctor'] ?? {})['name'] ?? '').toString().toLowerCase();
          final area =
              ((c['address'] ?? {})['area'] ?? '').toString().toLowerCase();
          return name.contains(_searchQuery) ||
              doctor.contains(_searchQuery) ||
              area.contains(_searchQuery);
        }).toList();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: _surface,
      body: Column(
        children: [
          _buildHeader(context),
          _buildSearchBar(),
          Expanded(
            child:
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(color: _primary),
                    )
                    : _filtered.isEmpty
                    ? _buildEmpty()
                    : RefreshIndicator(
                      onRefresh: _fetchClinics,
                      color: _primary,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filtered.length,
                        itemBuilder:
                            (_, i) => _buildClinicCard(_filtered[i], context),
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'احجز موعد في العيادة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'ابحث عن عيادة وحدد الخدمة',
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_hospital_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'ابحث بالاسم، الطبيب، أو المنطقة...',
          hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF94A3B8),
          ),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                    icon: const Icon(
                      Icons.clear_rounded,
                      color: Color(0xFF94A3B8),
                      size: 18,
                    ),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                  : null,
        ),
      ),
    );
  }

  Widget _buildClinicCard(dynamic clinic, BuildContext context) {
    final name = clinic['name'] ?? 'Clinic';
    final doctor = clinic['doctor'];
    final doctorName = (doctor is Map ? doctor['name'] : null) ?? 'Doctor';
    final doctorSpec = (doctor is Map ? doctor['specialization'] : null) ?? '';
    final address = clinic['address'];
    final area = (address is Map ? address['area'] : null) ?? '';
    final city = (address is Map ? address['city'] : null) ?? '';
    final locationText = [area, city].where((s) => s.isNotEmpty).join(', ');
    final images = clinic['images'] as List?;
    final hasImage = images != null && images.isNotEmpty;
    final clinicId = clinic['_id'] ?? '';
    final doctorId = (doctor is Map ? doctor['_id'] : null) ?? '';
    final bookingMode = (clinic['bookingMode'] as String?) ?? 'slots';
    final isQueue = bookingMode == 'queue';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => ClinicBookingPage(
                  clinicId: clinicId,
                  clinicName: name,
                  doctorId: doctorId,
                  doctorName: doctorName,
                  doctorSpecialization:
                      doctorSpec.isNotEmpty ? doctorSpec : null,
                  clinicData: clinic is Map<String, dynamic> ? clinic : null,
                ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image / placeholder
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child:
                  hasImage
                      ? Image.network(
                        images.first,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _clinicImagePlaceholder(),
                      )
                      : _clinicImagePlaceholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_rounded,
                        size: 14,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$doctorName${doctorSpec.isNotEmpty ? ' · $doctorSpec' : ''}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  if (locationText.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          locationText,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isQueue
                                  ? const Color(0xFFFFFBEB)
                                  : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isQueue
                                  ? Icons.people_rounded
                                  : Icons.schedule_rounded,
                              size: 12,
                              color:
                                  isQueue ? const Color(0xFFF59E0B) : _primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isQueue ? 'طابور' : 'مواعيد',
                              style: TextStyle(
                                fontSize: 11,
                                color:
                                    isQueue
                                        ? const Color(0xFFF59E0B)
                                        : _primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: _primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'احجز الآن',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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

  Widget _clinicImagePlaceholder() {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.local_hospital_rounded,
          size: 48,
          color: Colors.white.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 72,
              color: Colors.blue.shade100,
            ),
            const SizedBox(height: 16),
            const Text(
              'لا توجد عيادات',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'لا نتائج لـ "$_searchQuery"'
                  : 'لا توجد عيادات متاحة حالياً.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}
