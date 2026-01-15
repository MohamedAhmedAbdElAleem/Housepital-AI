import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'service_details_page.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 DESIGN SYSTEM
// ═══════════════════════════════════════════════════════════════════════════

class _ServicesDesign {
  static const primaryGreen = Color(0xFF00C853);
  static const surface = Color(0xFFF8FAFC);
  static const cardBg = Colors.white;
  static const textPrimary = Color(0xFF1E293B);
  static const textSecondary = Color(0xFF64748B);
  static const textMuted = Color(0xFF94A3B8);
  static const divider = Color(0xFFE2E8F0);

  static const headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00C853), Color(0xFF00B248), Color(0xFF009624)],
  );

  static BoxShadow get cardShadow => BoxShadow(
    color: Colors.black.withOpacity(0.06),
    blurRadius: 20,
    offset: const Offset(0, 8),
  );

  static BoxShadow get softShadow => BoxShadow(
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

  // Service Categories Data
  final List<ServiceCategory> _categories = [
    ServiceCategory(
      name: 'All Services',
      icon: Icons.grid_view_rounded,
      color: _ServicesDesign.primaryGreen,
      services: [],
    ),
    ServiceCategory(
      name: 'Post-Surgery',
      icon: Icons.healing_rounded,
      color: const Color(0xFF3B82F6),
      services: [
        ServiceItem(
          title: 'Post-Surgical Care',
          description:
              'Professional nursing care for patients recovering from surgery',
          price: '350 EGP',
          duration: '2-3 hours',
          icon: Icons.healing_rounded,
          color: const Color(0xFF3B82F6),
          rating: 4.9,
          bookings: 5200,
          isPopular: true,
          includes: [
            'Wound dressing and care',
            'Pain management assistance',
            'Vital signs monitoring',
            'Medication administration',
            'Post-operative exercises guidance',
            'Infection prevention measures',
          ],
        ),
      ],
    ),
    ServiceCategory(
      name: 'Elderly Care',
      icon: Icons.elderly_rounded,
      color: const Color(0xFF8B5CF6),
      services: [
        ServiceItem(
          title: 'Elderly Care',
          description: 'Compassionate care for seniors with chronic conditions',
          price: '300 EGP',
          duration: '3-4 hours',
          icon: Icons.elderly_rounded,
          color: const Color(0xFF8B5CF6),
          rating: 4.8,
          bookings: 4100,
          includes: [
            'Personal hygiene assistance',
            'Medication reminders',
            'Mobility assistance',
            'Vital signs monitoring',
            'Companionship and emotional support',
            'Light meal preparation',
          ],
        ),
        ServiceItem(
          title: 'Chronic Disease Management',
          description: 'Ongoing care for diabetes, hypertension, and more',
          price: '280 EGP',
          duration: '2-3 hours',
          icon: Icons.monitor_heart_rounded,
          color: const Color(0xFFEC4899),
          rating: 4.7,
          bookings: 3200,
          includes: [
            'Blood sugar monitoring',
            'Blood pressure checks',
            'Medication management',
            'Diet counseling',
            'Exercise guidance',
            'Health education',
          ],
        ),
      ],
    ),
    ServiceCategory(
      name: 'Injections',
      icon: Icons.vaccines_rounded,
      color: const Color(0xFF00C853),
      services: [
        ServiceItem(
          title: 'IV Therapy',
          description: 'Intravenous fluid and medication administration',
          price: '200 EGP',
          duration: '30-60 min',
          icon: Icons.vaccines_rounded,
          color: const Color(0xFF00C853),
          rating: 4.9,
          bookings: 8500,
          isPopular: true,
          includes: [
            'IV line insertion',
            'Fluid administration',
            'Medication infusion',
            'Vital signs monitoring',
            'Post-procedure care',
          ],
        ),
        ServiceItem(
          title: 'IM/SC Injections',
          description: 'Intramuscular and subcutaneous injections',
          price: '100 EGP',
          duration: '15-20 min',
          icon: Icons.medication_rounded,
          color: const Color(0xFF14B8A6),
          rating: 4.8,
          bookings: 12000,
          includes: [
            'Injection administration',
            'Site preparation',
            'Post-injection monitoring',
            'Proper disposal of materials',
          ],
        ),
      ],
    ),
    ServiceCategory(
      name: 'Wound Care',
      icon: Icons.medical_services_rounded,
      color: const Color(0xFFF59E0B),
      services: [
        ServiceItem(
          title: 'Wound Dressing',
          description: 'Professional wound cleaning and dressing',
          price: '150 EGP',
          duration: '30-45 min',
          icon: Icons.medical_services_rounded,
          color: const Color(0xFFF59E0B),
          rating: 4.8,
          bookings: 6300,
          includes: [
            'Wound assessment',
            'Cleaning and disinfection',
            'Sterile dressing application',
            'Infection monitoring',
            'Care instructions',
          ],
        ),
        ServiceItem(
          title: 'Burn Care',
          description: 'Specialized care for burn injuries',
          price: '180 EGP',
          duration: '45-60 min',
          icon: Icons.local_fire_department_rounded,
          color: const Color(0xFFEF4444),
          rating: 4.9,
          bookings: 2100,
          includes: [
            'Burn assessment',
            'Wound cleaning',
            'Specialized dressing',
            'Pain management',
            'Healing monitoring',
          ],
        ),
      ],
    ),
    ServiceCategory(
      name: 'Orthopedic',
      icon: Icons.accessibility_new_rounded,
      color: const Color(0xFFEF4444),
      services: [
        ServiceItem(
          title: 'Fracture Care',
          description: 'Care for patients with broken bones or fractures',
          price: '250 EGP',
          duration: '1-2 hours',
          icon: Icons.accessibility_new_rounded,
          color: const Color(0xFFEF4444),
          rating: 4.7,
          bookings: 3800,
          includes: [
            'Cast care instructions',
            'Pain management',
            'Mobility assistance',
            'Physical therapy exercises',
            'Swelling monitoring',
          ],
        ),
      ],
    ),
  ];

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
    return Scaffold(
      backgroundColor: _ServicesDesign.surface,
      body: Stack(
        children: [
          // Background gradient
          Container(
            height: 280,
            decoration: const BoxDecoration(
              gradient: _ServicesDesign.headerGradient,
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SlideTransition(
                    position: _slideAnim,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: _buildContent(),
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

  Widget _buildHeader() {
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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Our Services',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Professional healthcare at your doorstep',
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
              color: Colors.white,
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
                const Icon(
                  Icons.search_rounded,
                  color: _ServicesDesign.textMuted,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    style: const TextStyle(
                      fontSize: 15,
                      color: _ServicesDesign.textPrimary,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Search services...',
                      hintStyle: TextStyle(
                        color: _ServicesDesign.textMuted,
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 16),
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
                        color: _ServicesDesign.textMuted.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: _ServicesDesign.textMuted,
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

  Widget _buildContent() {
    return Container(
      decoration: const BoxDecoration(
        color: _ServicesDesign.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Category Chips
            SliverToBoxAdapter(child: _buildCategoryChips()),

            // Popular Services (only when showing all)
            if (_selectedCategoryIndex == 0 && _searchQuery.isEmpty) ...[
              SliverToBoxAdapter(
                child: _buildSectionTitle('🔥 Popular Services'),
              ),
              SliverToBoxAdapter(child: _buildPopularServices()),
              SliverToBoxAdapter(child: _buildSectionTitle('📋 All Services')),
            ],

            // Services List
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver:
                  _filteredServices.isEmpty
                      ? SliverToBoxAdapter(child: _buildEmptyState())
                      : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildServiceCard(
                            _filteredServices[index],
                            index,
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

  Widget _buildCategoryChips() {
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
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color:
                      isSelected ? Colors.transparent : _ServicesDesign.divider,
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
                              : _ServicesDesign.textPrimary,
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: _ServicesDesign.textPrimary,
        ),
      ),
    );
  }

  Widget _buildPopularServices() {
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

  Widget _buildServiceCard(ServiceItem service, int index) {
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
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
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _ServicesDesign.textPrimary,
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
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.local_fire_department_rounded,
                                    size: 12,
                                    color: Color(0xFFF59E0B),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Popular',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF92400E),
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
                        style: const TextStyle(
                          fontSize: 13,
                          color: _ServicesDesign.textSecondary,
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
                              const Icon(
                                Icons.schedule_rounded,
                                size: 14,
                                color: _ServicesDesign.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                service.duration,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: _ServicesDesign.textMuted,
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
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _ServicesDesign.textPrimary,
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
                    color: _ServicesDesign.surface,
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

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _ServicesDesign.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 48,
              color: _ServicesDesign.primaryGreen,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Services Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _ServicesDesign.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              fontSize: 14,
              color: _ServicesDesign.textSecondary,
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
                color: _ServicesDesign.primaryGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Clear Filters',
                style: TextStyle(
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
