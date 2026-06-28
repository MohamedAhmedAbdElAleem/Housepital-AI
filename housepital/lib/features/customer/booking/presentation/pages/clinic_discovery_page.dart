import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../../core/network/api_service.dart';
import 'clinic_booking_page.dart';

class ClinicDiscoveryPage extends StatefulWidget {
  const ClinicDiscoveryPage({super.key});

  @override
  State<ClinicDiscoveryPage> createState() => _ClinicDiscoveryPageState();
}

class _ClinicDiscoveryPageState extends State<ClinicDiscoveryPage> {
  bool get isDark => Theme.of(context).brightness == Brightness.dark;
  bool get isAr => Localizations.localeOf(context).languageCode == 'ar';

  String t(String ar, String en) => isAr ? ar : en;

  static const _primary = Color(0xFF3B82F6);
  static const _primaryDark = Color(0xFF1D4ED8);
  Color get _surface => isDark ? const Color(0xFF0D0C11) : const Color(0xFFF0F4F8);
  Color get _textPrimary => isDark ? const Color(0xFFF2F2F5) : const Color(0xFF1A202C);
  Color get _textMuted => isDark ? const Color(0xFFA19EAB) : const Color(0xFFA0AEC0);

  List<dynamic> _clinics = [];
  List<dynamic> _filtered = [];
  bool _isLoading = true;
  String _searchQuery = '';
  int _selectedCategoryIndex = 0;

  final List<String> _categoriesAr = [
    'الكل',
    'أسنان',
    'عظام',
    'أطفال',
    'قلب',
    'باطنة',
    'جلدية',
  ];

  final List<String> _categoriesEn = [
    'All',
    'Dental',
    'Orthopedic',
    'Pediatric',
    'Cardiology',
    'Internal Medicine',
    'Dermatology',
  ];

  List<String> get _categories => isAr ? _categoriesAr : _categoriesEn;

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
    _filtered =
        _clinics.where((c) {
          final name = (c['name'] ?? '').toString().toLowerCase();
          final docInfo = c['doctor'] ?? {};
          final doctor = (docInfo['name'] ?? '').toString().toLowerCase();
          final spec = (docInfo['specialization'] ?? '').toString();
          final area =
              ((c['address'] ?? {})['area'] ?? '').toString().toLowerCase();

          bool matchesSearch = true;
          if (_searchQuery.isNotEmpty) {
            matchesSearch =
                name.contains(_searchQuery) ||
                doctor.contains(_searchQuery) ||
                area.contains(_searchQuery);
          }

          bool matchesCategory = true;
          if (_selectedCategoryIndex != 0) {
            final specLow = spec.toLowerCase();
            final catAr = _categoriesAr[_selectedCategoryIndex];
            final catEn = _categoriesEn[_selectedCategoryIndex].toLowerCase();
            matchesCategory =
                specLow.contains(catAr) ||
                specLow.contains(catEn) ||
                catAr.contains(specLow) ||
                catEn.contains(specLow);
          }

          return matchesSearch && matchesCategory;
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
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 295,
            pinned: true,
            stretch: true,
            backgroundColor: _primary,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(50),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withAlpha(80)),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_primary, _primaryDark],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Icon(
                        Icons.local_hospital_rounded,
                        size: 250,
                        color: Colors.white.withAlpha(15),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              t('احجز موعد', 'Book Appointment'),
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.1,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              t('ابحث عن عيادة وحدد الخدمة الطبية.', 'Search for a clinic and select your service.'),
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color: Colors.white.withAlpha(220),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 10,
                                  sigmaY: 10,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E1C24) : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isDark ? Colors.white.withAlpha(15) : Colors.black.withAlpha(10),
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    style: TextStyle(
                                      color: _textPrimary,
                                      fontFamily: 'Inter',
                                      fontSize: 15,
                                    ),
                                    decoration: InputDecoration(
                                      hintText:
                                          t('ابحث بالاسم، الطبيب، أو المنطقة...', 'Search by name, doctor, or area...'),
                                      hintStyle: TextStyle(
                                        color: _textMuted,
                                        fontSize: 15,
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.search_rounded,
                                        color: _primary,
                                        size: 22,
                                      ),
                                      suffixIcon:
                                          _searchQuery.isNotEmpty
                                              ? IconButton(
                                                icon: Container(
                                                  padding: const EdgeInsets.all(
                                                    4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withAlpha(10),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    Icons.close_rounded,
                                                    color: _textMuted,
                                                    size: 14,
                                                  ),
                                                ),
                                                onPressed:
                                                    () =>
                                                        _searchController
                                                            .clear(),
                                              )
                                              : null,
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 36,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: _categories.length,
                                itemBuilder: (context, index) {
                                  final cat = _categories[index];
                                  final isSelected = index == _selectedCategoryIndex;
                                  return GestureDetector(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      setState(() {
                                        _selectedCategoryIndex = index;
                                        _applyFilter();
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      margin: const EdgeInsets.only(left: 8),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : Colors.white.withAlpha(50),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color:
                                              isSelected
                                                  ? Colors.transparent
                                                  : Colors.white.withAlpha(80),
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        cat,
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 14,
                                          fontWeight:
                                              isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                          color:
                                              isSelected
                                                  ? _primary
                                                  : Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: _primary)),
            )
          else if (_filtered.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 64,
                      color: isDark ? Colors.white.withAlpha(60) : Colors.grey.withAlpha(100),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      t('لا توجد عيادات', 'No clinics found'),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _searchQuery.isNotEmpty
                          ? t('لا نتائج لـ "$_searchQuery"', 'No results found for "$_searchQuery"')
                          : t('لا توجد عيادات متاحة حالياً.', 'No clinics currently available.'),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: isDark ? const Color(0xFFA19EAB) : const Color(0xFF718096),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(
                      milliseconds: 300 + (index * 50).clamp(0, 500),
                    ),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Opacity(opacity: value, child: child),
                      );
                    },
                    child: _buildClinicCard(_filtered[index], context),
                  );
                }, childCount: _filtered.length),
              ),
            ),
        ],
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
    final bookingMode = (clinic['bookingMode'] as String?) ?? 'slots';
    final isQueue = bookingMode == 'queue';

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder:
                (_, __, ___) => ClinicBookingPage(
                  clinicId: clinic['_id'] ?? '',
                  clinicName: name,
                  doctorId: (doctor is Map ? doctor['_id'] : null) ?? '',
                  doctorName: doctorName,
                  doctorSpecialization:
                      doctorSpec.isNotEmpty ? doctorSpec : null,
                  clinicData: clinic is Map<String, dynamic> ? clinic : null,
                ),
            transitionsBuilder: (_, animation, __, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: child,
              );
            },
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF16151A) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? _primary.withAlpha(40) : _primary.withAlpha(20),
            width: isDark ? 1.0 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? _primary.withAlpha(20)
                  : Colors.black.withAlpha(5),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child:
                  hasImage
                      ? Image.network(
                        images.first,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _clinicImagePlaceholder(),
                      )
                      : _clinicImagePlaceholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isQueue
                                  ? const Color(0xFFF59E0B).withAlpha(20)
                                  : _primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isQueue
                                  ? Icons.people_rounded
                                  : Icons.schedule_rounded,
                              size: 14,
                              color:
                                  isQueue ? const Color(0xFFF59E0B) : _primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isQueue ? t('طابور', 'Queue') : t('مواعيد', 'Appointment'),
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color:
                                    isQueue
                                        ? const Color(0xFFF59E0B)
                                        : _primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.person_rounded,
                        size: 16,
                        color: _textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$doctorName${doctorSpec.isNotEmpty ? ' · $doctorSpec' : ''}',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: isDark ? const Color(0xFFA19EAB) : const Color(0xFF475569),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (locationText.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: _textMuted,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          locationText,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: _textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
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
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [_primary, _primaryDark]),
      ),
      child: Center(
        child: Icon(
          Icons.local_hospital_rounded,
          size: 64,
          color: Colors.white.withAlpha(40),
        ),
      ),
    );
  }
}
