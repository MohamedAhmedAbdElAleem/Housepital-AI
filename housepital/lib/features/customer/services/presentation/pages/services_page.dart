import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../generated/l10n/app_localizations.dart';
import 'service_details_page.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 DYNAMIC DESIGN SYSTEM
// ═══════════════════════════════════════════════════════════════════════════

class _ServicesTheme {
  final bool isDark;
  _ServicesTheme(BuildContext context) : isDark = Theme.of(context).brightness == Brightness.dark;

  Color get primaryGreen => const Color(0xFF00C853);
  Color get surface => isDark ? const Color(0xFF0D0C11) : const Color(0xFFF8FAFC);
  Color get cardBg => isDark ? const Color(0xFF16151A) : Colors.white;
  Color get textPrimary => isDark ? Colors.white : const Color(0xFF1E293B);
  Color get textSecondary => isDark ? const Color(0xFFA19EAB) : const Color(0xFF64748B);
  Color get textMuted => isDark ? const Color(0xFF555263) : const Color(0xFF94A3B8);
  Color get divider => isDark ? const Color(0xFF2A2831) : const Color(0xFFE2E8F0);

  LinearGradient get headerGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00C853), Color(0xFF00B248), Color(0xFF009624)],
  );

  BoxShadow get cardShadow => BoxShadow(
    color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
    blurRadius: 20,
    offset: const Offset(0, 8),
  );

  BoxShadow get softShadow => BoxShadow(
    color: primaryGreen.withOpacity(0.15),
    blurRadius: 20,
    offset: const Offset(0, 8),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// 📦 SERVICE DATA MODEL
// ═══════════════════════════════════════════════════════════════════════════

class ServiceCategory {
  final String name;
  final IconData icon;
  final Color color;
  final List<ServiceItem> services;

  const ServiceCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.services,
  });
}

class ServiceItem {
  final String title;
  final String englishTitle; // Always English — used for API matching
  final String? serviceRoute; // Stable English category slug for API matching
  final String description;
  final String price;
  final String duration;
  final IconData icon;
  final Color color;
  final double rating;
  final int bookings;
  final List<String> includes;
  final bool isPopular;

  const ServiceItem({
    required this.title,
    required this.englishTitle,
    this.serviceRoute,
    required this.description,
    required this.price,
    required this.duration,
    required this.icon,
    required this.color,
    this.rating = 4.8,
    this.bookings = 1000,
    this.includes = const [],
    this.isPopular = false,
  });
}

// ═══════════════════════════════════════════════════════════════════════════
// 📱 MAIN PAGE
// ═══════════════════════════════════════════════════════════════════════════

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage>
    with TickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  int _selectedCategoryIndex = 0;
  String _searchQuery = '';

  List<ServiceCategory> _getLocalizedCategories(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final design = _ServicesTheme(context);
    return [
      ServiceCategory(
        name: l10n.categoryAllServices,
        icon: Icons.grid_view_rounded,
        color: design.primaryGreen,
        services: [],
      ),
      ServiceCategory(
        name: l10n.categoryPostSurgery,
        icon: Icons.healing_rounded,
        color: const Color(0xFF3B82F6),
        services: [
          ServiceItem(
            title: l10n.servicePostSurgicalCareTitle,
            englishTitle: 'Post-Surgical Care',
            serviceRoute: 'post_surgical_care',
            description: l10n.servicePostSurgicalCareDesc,
            price: l10n.priceEgp(350),
            duration: l10n.servicePostSurgicalCareDuration,
            icon: Icons.healing_rounded,
            color: const Color(0xFF3B82F6),
            rating: 4.9,
            bookings: 5200,
            isPopular: true,
            includes: [
              l10n.servicePostSurgicalCareInc1,
              l10n.servicePostSurgicalCareInc2,
              l10n.servicePostSurgicalCareInc3,
              l10n.servicePostSurgicalCareInc4,
              l10n.servicePostSurgicalCareInc5,
              l10n.servicePostSurgicalCareInc6,
            ],
          ),
        ],
      ),
      ServiceCategory(
        name: l10n.categoryElderlyCare,
        icon: Icons.elderly_rounded,
        color: const Color(0xFF8B5CF6),
        services: [
          ServiceItem(
            title: l10n.serviceElderlyCareTitle,
            englishTitle: 'Elderly Care',
            serviceRoute: 'elderly_care',
            description: l10n.serviceElderlyCareDesc,
            price: l10n.priceEgp(300),
            duration: l10n.serviceElderlyCareDuration,
            icon: Icons.elderly_rounded,
            color: const Color(0xFF8B5CF6),
            rating: 4.8,
            bookings: 4100,
            includes: [
              l10n.serviceElderlyCareInc1,
              l10n.serviceElderlyCareInc2,
              l10n.serviceElderlyCareInc3,
              l10n.serviceElderlyCareInc4,
            ],
          ),
          ServiceItem(
            title: l10n.serviceChronicDiseaseTitle,
            englishTitle: 'Chronic Disease Management',
            serviceRoute: 'chronic_disease_management',
            description: l10n.serviceChronicDiseaseDesc,
            price: l10n.priceEgp(280),
            duration: l10n.serviceChronicDiseaseDuration,
            icon: Icons.monitor_heart_rounded,
            color: const Color(0xFFEC4899),
            rating: 4.7,
            bookings: 3200,
            includes: [
              l10n.serviceChronicDiseaseInc1,
              l10n.serviceChronicDiseaseInc2,
              l10n.serviceChronicDiseaseInc3,
              l10n.serviceChronicDiseaseInc4,
              l10n.serviceChronicDiseaseInc5,
              l10n.serviceChronicDiseaseInc6,
            ],
          ),
        ],
      ),
      ServiceCategory(
        name: l10n.categoryInjections,
        icon: Icons.vaccines_rounded,
        color: const Color(0xFF00C853),
        services: [
          ServiceItem(
            title: l10n.serviceIvTherapyTitle,
            englishTitle: 'IV Therapy',
            serviceRoute: 'iv_therapy',
            description: l10n.serviceIvTherapyDesc,
            price: l10n.priceEgp(200),
            duration: l10n.serviceIvTherapyDurationShort,
            icon: Icons.vaccines_rounded,
            color: const Color(0xFF00C853),
            rating: 4.9,
            bookings: 8500,
            isPopular: true,
            includes: [
              l10n.serviceIvTherapyInc1,
              l10n.serviceIvTherapyInc2,
              l10n.serviceIvTherapyInc3,
              l10n.serviceIvTherapyInc4,
              l10n.serviceIvTherapyInc5,
            ],
          ),
          ServiceItem(
            title: l10n.serviceImScInjectionsTitle,
            englishTitle: 'IM/SC Injections',
            serviceRoute: 'im_sc_injections',
            description: l10n.serviceImScInjectionsDesc,
            price: l10n.priceEgp(100),
            duration: l10n.serviceImScInjectionsDuration,
            icon: Icons.medication_rounded,
            color: const Color(0xFF14B8A6),
            rating: 4.8,
            bookings: 12000,
            includes: [
              l10n.serviceImScInjectionsInc1,
              l10n.serviceImScInjectionsInc2,
              l10n.serviceImScInjectionsInc3,
              l10n.serviceImScInjectionsInc4,
            ],
          ),
        ],
      ),
      ServiceCategory(
        name: l10n.categoryWoundCare,
        icon: Icons.medical_services_rounded,
        color: const Color(0xFFF59E0B),
        services: [
          ServiceItem(
            title: l10n.serviceWoundDressingTitle,
            englishTitle: 'Wound Dressing',
            serviceRoute: 'wound_dressing',
            description: l10n.serviceWoundDressingDesc,
            price: l10n.priceEgp(150),
            duration: l10n.serviceWoundDressingDuration,
            icon: Icons.medical_services_rounded,
            color: const Color(0xFFF59E0B),
            rating: 4.8,
            bookings: 6300,
            includes: [
              l10n.serviceWoundDressingInc1,
              l10n.serviceWoundDressingInc2,
              l10n.serviceWoundDressingInc3,
              l10n.serviceWoundDressingInc4,
              l10n.serviceWoundDressingInc5,
            ],
          ),
          ServiceItem(
            title: l10n.serviceBurnCareTitle,
            englishTitle: 'Burn Care',
            serviceRoute: 'burn_care',
            description: l10n.serviceBurnCareDesc,
            price: l10n.priceEgp(180),
            duration: l10n.serviceBurnCareDuration,
            icon: Icons.local_fire_department_rounded,
            color: const Color(0xFFEF4444),
            rating: 4.9,
            bookings: 2100,
            includes: [
              l10n.serviceBurnCareInc1,
              l10n.serviceBurnCareInc2,
              l10n.serviceBurnCareInc3,
              l10n.serviceBurnCareInc4,
              l10n.serviceBurnCareInc5,
            ],
          ),
        ],
      ),
      ServiceCategory(
        name: l10n.categoryOrthopedic,
        icon: Icons.accessibility_new_rounded,
        color: const Color(0xFFEF4444),
        services: [
          ServiceItem(
            title: l10n.serviceFractureCareTitle,
            englishTitle: 'Fracture Care',
            serviceRoute: 'fracture_care',
            description: l10n.serviceFractureCareDesc,
            price: l10n.priceEgp(250),
            duration: l10n.serviceFractureCareDuration,
            icon: Icons.accessibility_new_rounded,
            color: const Color(0xFFEF4444),
            rating: 4.7,
            bookings: 3800,
            includes: [
              l10n.serviceFractureCareInc1,
              l10n.serviceFractureCareInc2,
              l10n.serviceFractureCareInc3,
              l10n.serviceFractureCareInc4,
              l10n.serviceFractureCareInc5,
            ],
          ),
        ],
      ),
    ];
  }

  List<ServiceCategory> get _categories => _getLocalizedCategories(context);

  List<ServiceItem> get _allServices {
    final services = <ServiceItem>[];
    for (var category in _categories) {
      services.addAll(category.services);
    }
    return services;
  }

  List<ServiceItem> get _filteredServices {
    List<ServiceItem> services;

    if (_selectedCategoryIndex == 0) {
      services = _allServices;
    } else {
      services = _categories[_selectedCategoryIndex].services;
    }

    if (_searchQuery.isEmpty) return services;

    return services
        .where(
          (s) =>
              s.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              s.description.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final design = _ServicesTheme(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: design.surface,
      body: Stack(
        children: [
          // Background gradient
          Container(
            height: 280,
            decoration: BoxDecoration(
              gradient: design.headerGradient,
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(design, l10n),
                Expanded(
                  child: SlideTransition(
                    position: _slideAnim,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: _buildContent(design, l10n),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(_ServicesTheme design, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar
          Row(
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
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.ourServices,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      l10n.servicesSubtitle,
                      style: const TextStyle(fontSize: 13, color: Colors.white70),
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
                  Icons.filter_list_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: design.cardBg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: design.textMuted,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    style: TextStyle(
                      fontSize: 15,
                      color: design.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: l10n.searchServices,
                      hintStyle: TextStyle(
                        color: design.textMuted,
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: design.textMuted.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: design.textMuted,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(_ServicesTheme design, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: design.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Category Chips
            SliverToBoxAdapter(child: _buildCategoryChips(design)),

            // Popular Services (only when showing all)
            if (_selectedCategoryIndex == 0 && _searchQuery.isEmpty) ...[
              SliverToBoxAdapter(
                child: _buildSectionTitle(l10n.popularServices, design),
              ),
              SliverToBoxAdapter(child: _buildPopularServices(l10n)),
              SliverToBoxAdapter(child: _buildSectionTitle(l10n.allServices, design)),
            ],

            // Services List
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver:
                  _filteredServices.isEmpty
                      ? SliverToBoxAdapter(child: _buildEmptyState(design, l10n))
                      : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildServiceCard(
                            _filteredServices[index],
                            index,
                            design,
                            l10n,
                          ),
                          childCount: _filteredServices.length,
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips(_ServicesTheme design) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategoryIndex == index;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedCategoryIndex = index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient:
                    isSelected
                        ? LinearGradient(
                          colors: [
                            category.color,
                            category.color.withOpacity(0.8),
                          ],
                        )
                        : null,
                color: isSelected ? null : design.cardBg,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color:
                      isSelected ? Colors.transparent : design.divider,
                ),
                boxShadow:
                    isSelected
                        ? [
                          BoxShadow(
                            color: category.color.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                        : null,
              ),
              child: Row(
                children: [
                  Icon(
                    category.icon,
                    size: 18,
                    color: isSelected ? Colors.white : category.color,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected
                              ? Colors.white
                              : design.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, _ServicesTheme design) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: design.textPrimary,
        ),
      ),
    );
  }

  Widget _buildPopularServices(AppLocalizations l10n) {
    final popularServices = _allServices.where((s) => s.isPopular).toList();

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: popularServices.length,
        itemBuilder: (context, index) {
          final service = popularServices[index];
          return GestureDetector(
            onTap: () => _navigateToDetails(service),
            child: Container(
              width: 280,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [service.color, service.color.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: service.color.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Background pattern
                  Positioned(
                    right: -20,
                    bottom: -20,
                    child: Icon(
                      service.icon,
                      size: 120,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                service.icon,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    service.rating.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          service.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              service.price,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: Colors.white54,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              service.duration,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
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
        },
      ),
    );
  }

  Widget _buildServiceCard(ServiceItem service, int index, _ServicesTheme design, AppLocalizations l10n) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50)),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () => _navigateToDetails(service),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: design.cardBg,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(design.isDark ? 0.25 : 0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Hero(
                  tag: 'service_icon_${service.title}',
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          service.color.withOpacity(0.15),
                          service.color.withOpacity(0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(service.icon, color: service.color, size: 30),
                  ),
                ),

                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              service.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: design.textPrimary,
                              ),
                            ),
                          ),
                          if (service.isPopular)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: design.isDark ? Colors.amber.withOpacity(0.15) : const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.local_fire_department_rounded,
                                    size: 12,
                                    color: Color(0xFFF59E0B),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    l10n.popularLabel,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: design.isDark ? Colors.amber : const Color(0xFF92400E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        service.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: design.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // Price
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: service.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              service.price,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: service.color,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Duration
                          Row(
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 14,
                                color: design.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                service.duration,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: design.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          // Rating
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: Color(0xFFF59E0B),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                service.rating.toString(),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: design.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Arrow
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: design.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: service.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(_ServicesTheme design, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: design.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 48,
              color: design.primaryGreen,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.noServicesFound,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: design.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.tryAdjustingFilters,
            style: TextStyle(
              fontSize: 14,
              color: design.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
                _selectedCategoryIndex = 0;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: design.primaryGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                l10n.clearFilters,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetails(ServiceItem service) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (_, __, ___) => ServiceDetailsPage(
              title: service.title,
              englishTitle: service.englishTitle,
              serviceRoute: service.serviceRoute,
              price: service.price,
              duration: service.duration,
              icon: service.icon,
              iconColor: service.color,
              description: service.description,
              includes: service.includes,
            ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}
