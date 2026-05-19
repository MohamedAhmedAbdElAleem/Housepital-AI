import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../../core/network/api_service.dart';
import '../../../booking/presentation/pages/clinic_booking_page.dart';
import '../../../services/presentation/pages/service_details_page.dart';

enum SearchResultType { nursing, clinic }

class SearchResult {
  final String id;
  final String title;
  final String subtitle;
  final SearchResultType type;
  final IconData icon;
  final Color iconColor;
  final dynamic originalData; // Stores the raw clinic Map or _ServiceData

  SearchResult({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.icon,
    required this.iconColor,
    this.originalData,
  });
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _query = '';
  
  bool _isLoading = false;
  List<SearchResult> _allResults = [];
  List<SearchResult> _filteredResults = [];

  @override
  void initState() {
    super.initState();
    _loadAllData();
    _searchController.addListener(_onSearchChanged);
    // Auto focus search on page entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _query = _searchController.text.toLowerCase();
      _filterResults();
    });
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    
    // 1. Load Hardcoded Nursing Services
    final nursingServices = _getNursingServices();
    
    // 2. Fetch Clinics from API
    List<SearchResult> clinics = [];
    try {
      final api = ApiService();
      final response = await api.get('/api/clinics/public');
      final data = response is Map ? (response['data'] ?? []) : response;
      if (data is List) {
        clinics = data.map((c) {
          final doctor = c['doctor'] is Map ? c['doctor']['name'] : 'Doctor';
          final spec = c['doctor'] is Map ? c['doctor']['specialization'] : '';
          return SearchResult(
            id: c['_id'] ?? '',
            title: c['name'] ?? 'Clinic',
            subtitle: '$doctor${spec.isNotEmpty ? ' • $spec' : ''}',
            type: SearchResultType.clinic,
            icon: Icons.local_hospital_rounded,
            iconColor: const Color(0xFF3B82F6),
            originalData: c,
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('Search error fetching clinics: $e');
    }

    if (mounted) {
      setState(() {
        _allResults = [...nursingServices, ...clinics];
        _filteredResults = _allResults;
        _isLoading = false;
      });
    }
  }

  void _filterResults() {
    if (_query.isEmpty) {
      _filteredResults = _allResults;
    } else {
      _filteredResults = _allResults.where((res) {
        return res.title.toLowerCase().contains(_query) || 
               res.subtitle.toLowerCase().contains(_query);
      }).toList();
    }
  }

  List<SearchResult> _getNursingServices() {
    // Mirroring data from all_nursing_services_page.dart
    final rawServices = [
      {'title': 'Wound Care', 'price': 150, 'icon': Icons.healing_rounded, 'color': Color(0xFFEF4444)},
      {'title': 'Injections', 'price': 50, 'icon': Icons.medication_liquid_rounded, 'color': Color(0xFF3B82F6)},
      {'title': 'Elderly Care', 'price': 200, 'icon': Icons.elderly_rounded, 'color': Color(0xFF8B5CF6)},
      {'title': 'Post-Op Care', 'price': 300, 'icon': Icons.monitor_heart_rounded, 'color': Color(0xFF10B981)},
      {'title': 'IV Therapy', 'price': 250, 'icon': Icons.water_drop_rounded, 'color': Color(0xFFEC4899)},
      {'title': 'Blood Draw', 'price': 100, 'icon': Icons.bloodtype_rounded, 'color': Color(0xFFDC2626)},
    ];

    return rawServices.map((s) {
      return SearchResult(
        id: s['title'] as String,
        title: s['title'] as String,
        subtitle: 'Home Nursing Service • ${s['price']} EGP',
        type: SearchResultType.nursing,
        icon: s['icon'] as IconData,
        iconColor: s['color'] as Color,
        originalData: s,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // 1. The Canopy
          _buildCanopy(theme),

          // 2. The Overlapping Body
          Padding(
            padding: const EdgeInsets.only(top: 180),
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Column(
                children: [
                  _buildSearchInput(isDark),
                  Expanded(
                    child: _isLoading 
                      ? const Center(child: CircularProgressIndicator())
                      : _buildResultsList(isDark),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanopy(ThemeData theme) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(20),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Search',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  Widget _buildSearchInput(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: (isDark ? Colors.black : Colors.white).withAlpha(isDark ? 30 : 50),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withAlpha(isDark ? 20 : 40),
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontFamily: 'Inter',
              ),
              decoration: InputDecoration(
                hintText: 'Clinics, nurses, services...',
                hintStyle: TextStyle(
                  color: (isDark ? Colors.white : Colors.black).withAlpha(100),
                ),
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF43A048)),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsList(bool isDark) {
    if (_filteredResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.withAlpha(100)),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                color: Colors.grey.withAlpha(180),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
      itemCount: _filteredResults.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final res = _filteredResults[index];
        return _buildResultCard(res, isDark);
      },
    );
  }

  Widget _buildResultCard(SearchResult res, bool isDark) {
    return GestureDetector(
      onTap: () => _onResultTap(res),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
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
                color: res.iconColor.withAlpha(30),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(res.icon, color: res.iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    res.title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    res.subtitle,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: (isDark ? Colors.white : Colors.black).withAlpha(150),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.grey.withAlpha(100),
            ),
          ],
        ),
      ),
    );
  }

  void _onResultTap(SearchResult res) {
    if (res.type == SearchResultType.nursing) {
      final data = res.originalData;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ServiceDetailsPage(
            title: data['title'],
            price: '${data['price']} EGP',
            duration: '30-45 min',
            icon: data['icon'],
            iconColor: data['iconColor'] ?? data['color'],
            description: 'Professional healthcare service delivered at home.',
            includes: const ['Assessment', 'Professional Care', 'Follow-up'],
          ),
        ),
      );
    } else {
      final clinic = res.originalData;
      final doctor = clinic['doctor'] is Map ? clinic['doctor'] : {};
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ClinicBookingPage(
            clinicId: clinic['_id'] ?? '',
            clinicName: clinic['name'] ?? '',
            doctorId: doctor['_id'] ?? '',
            doctorName: doctor['name'] ?? '',
            doctorSpecialization: doctor['specialization'],
            clinicData: Map<String, dynamic>.from(clinic),
          ),
        ),
      );
    }
  }
}
