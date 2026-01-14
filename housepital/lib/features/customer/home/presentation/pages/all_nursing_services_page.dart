import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/presentation/pages/service_details_page.dart';

class AllNursingServicesPage extends StatefulWidget {
  const AllNursingServicesPage({super.key});

  @override
  State<AllNursingServicesPage> createState() => _AllNursingServicesPageState();
}

class _AllNursingServicesPageState extends State<AllNursingServicesPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  // Design System
  static const _primary = Color(0xFF00C853);
  static const _surface = Color(0xFFFAFBFC);
  static const _card = Colors.white;
  static const _textPrimary = Color(0xFF0F172A);
  static const _textSecondary = Color(0xFF475569);
  static const _textMuted = Color(0xFF94A3B8);

  final List<String> _categories = [
    'All',
    'Popular',
    'Quick',
    'Specialized',
    'Long-term',
  ];

  final List<_ServiceData> _allServices = [
    _ServiceData(
      id: '1',
      title: 'Wound Care',
      price: 150,
      duration: '30-45 min',
      icon: Icons.healing_rounded,
      iconColor: const Color(0xFFEF4444),
      category: 'Popular',
      rating: 4.9,
      reviewCount: 312,
      description:
          'Professional wound care and dressing services provided by certified nurses.',
      includes: [
        'Professional wound assessment',
        'Sterile dressing',
        'Wound cleaning',
        'Follow-up visits',
        'Progress monitoring',
      ],
    ),
    _ServiceData(
      id: '2',
      title: 'Injections',
      price: 50,
      duration: '15-20 min',
      icon: Icons.medication_liquid_rounded,
      iconColor: const Color(0xFF3B82F6),
      category: 'Quick',
      rating: 4.8,
      reviewCount: 548,
      description: 'Safe and painless injection services at your home.',
      includes: [
        'All types of injections',
        'Proper sterilization',
        'Medication administration',
        'Post-injection care',
      ],
    ),
    _ServiceData(
      id: '3',
      title: 'Elderly Care',
      price: 200,
      duration: '1-4 hours',
      icon: Icons.elderly_rounded,
      iconColor: const Color(0xFF8B5CF6),
      category: 'Long-term',
      rating: 4.9,
      reviewCount: 187,
      description:
          'Comprehensive care for elderly patients including assistance with daily activities.',
      includes: [
        'Daily activity assistance',
        'Medication management',
        'Vital signs monitoring',
        'Companionship',
      ],
    ),
    _ServiceData(
      id: '4',
      title: 'Post-Op Care',
      price: 300,
      duration: '45-60 min',
      icon: Icons.monitor_heart_rounded,
      iconColor: const Color(0xFF10B981),
      category: 'Specialized',
      rating: 4.9,
      reviewCount: 203,
      description:
          'Post-operative care services to ensure smooth recovery after surgery.',
      includes: [
        'Surgical wound care',
        'Pain management',
        'Medication administration',
        'Vital signs monitoring',
      ],
    ),
    _ServiceData(
      id: '5',
      title: 'Baby Care',
      price: 180,
      duration: '2-3 hours',
      icon: Icons.child_care_rounded,
      iconColor: const Color(0xFFF59E0B),
      category: 'Specialized',
      rating: 4.8,
      reviewCount: 156,
      description: 'Professional newborn and infant care services.',
      includes: [
        'Newborn monitoring',
        'Feeding assistance',
        'Bathing',
        'Development assessment',
      ],
    ),
    _ServiceData(
      id: '6',
      title: 'IV Therapy',
      price: 250,
      duration: '45-60 min',
      icon: Icons.water_drop_rounded,
      iconColor: const Color(0xFFEC4899),
      category: 'Popular',
      rating: 4.7,
      reviewCount: 421,
      description:
          'Intravenous fluid and medication therapy administered safely at home.',
      includes: [
        'IV line insertion',
        'Medication administration',
        'Fluid therapy',
        'Monitoring',
      ],
    ),
    _ServiceData(
      id: '7',
      title: 'Catheter Care',
      price: 120,
      duration: '30-40 min',
      icon: Icons.medical_services_rounded,
      iconColor: const Color(0xFF06B6D4),
      category: 'Specialized',
      rating: 4.8,
      reviewCount: 98,
      description:
          'Professional catheter insertion, maintenance, and care services.',
      includes: [
        'Catheter insertion',
        'Regular maintenance',
        'Infection prevention',
        'Patient education',
      ],
    ),
    _ServiceData(
      id: '8',
      title: 'Vital Signs',
      price: 80,
      duration: '20-30 min',
      icon: Icons.favorite_rounded,
      iconColor: const Color(0xFF84CC16),
      category: 'Quick',
      rating: 4.9,
      reviewCount: 672,
      description: 'Complete vital signs monitoring with detailed reporting.',
      includes: [
        'Blood pressure',
        'Temperature',
        'Heart rate',
        'Oxygen saturation',
        'Health report',
      ],
    ),
    _ServiceData(
      id: '9',
      title: 'Blood Draw',
      price: 100,
      duration: '15 min',
      icon: Icons.bloodtype_rounded,
      iconColor: const Color(0xFFDC2626),
      category: 'Quick',
      rating: 4.8,
      reviewCount: 389,
      description: 'Professional blood sample collection at your home.',
      includes: [
        'Blood sample collection',
        'Proper labeling',
        'Lab delivery',
        'Results coordination',
      ],
    ),
    _ServiceData(
      id: '10',
      title: 'Physiotherapy',
      price: 350,
      duration: '60-90 min',
      icon: Icons.accessibility_new_rounded,
      iconColor: const Color(0xFF7C3AED),
      category: 'Long-term',
      rating: 4.9,
      reviewCount: 234,
      description:
          'Home physiotherapy sessions for rehabilitation and mobility.',
      includes: [
        'Assessment',
        'Exercise therapy',
        'Mobility training',
        'Progress tracking',
      ],
    ),
  ];

  List<_ServiceData> get _filteredServices {
    return _allServices.where((service) {
      final matchesCategory =
          _selectedCategory == 'All' || service.category == _selectedCategory;
      final matchesSearch =
          _searchQuery.isEmpty ||
          service.title.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scrollController.addListener(() {
      final scrolled = _scrollController.offset > 10;
      if (scrolled != _isScrolled) {
        setState(() => _isScrolled = scrolled);
      }
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: _surface,
      body: Stack(
        children: [
          // Background decorations
          _buildBackground(),

          // Main content
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildHeader(),
              _buildSearchBar(),
              _buildCategoryTabs(),
              _buildServicesGrid(),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: -100,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [_primary.withAlpha(20), _primary.withAlpha(0)],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 200,
              left: -80,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF667EEA).withAlpha(15),
                      const Color(0xFF667EEA).withAlpha(0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          MediaQuery.of(context).padding.top + 16,
          20,
          24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button and title row
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(8),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: _textPrimary,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nursing Services',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_allServices.length} services available',
                        style: const TextStyle(fontSize: 14, color: _textMuted),
                      ),
                    ],
                  ),
                ),
                // Filter button
                GestureDetector(
                  onTap: () => HapticFeedback.lightImpact(),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00C853), Color(0xFF69F0AE)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: _primary.withAlpha(60),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _primary.withAlpha(10),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          style: const TextStyle(fontSize: 15, color: _textPrimary),
          decoration: InputDecoration(
            hintText: 'Search for services...',
            hintStyle: const TextStyle(color: _textMuted, fontSize: 15),
            prefixIcon: Container(
              padding: const EdgeInsets.all(12),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  color: _primary,
                  size: 20,
                ),
              ),
            ),
            suffixIcon:
                _searchQuery.isNotEmpty
                    ? IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _textMuted.withAlpha(30),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: _textSecondary,
                          size: 16,
                        ),
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                    : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SliverToBoxAdapter(
      child: Container(
        height: 48,
        margin: const EdgeInsets.only(top: 20),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          physics: const BouncingScrollPhysics(),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            final isSelected = _selectedCategory == category;
            final count =
                category == 'All'
                    ? _allServices.length
                    : _allServices.where((s) => s.category == category).length;

            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedCategory = category);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  gradient:
                      isSelected
                          ? const LinearGradient(
                            colors: [Color(0xFF00C853), Color(0xFF69F0AE)],
                          )
                          : null,
                  color: isSelected ? null : _card,
                  borderRadius: BorderRadius.circular(14),
                  border:
                      isSelected
                          ? null
                          : Border.all(
                            color: _textMuted.withAlpha(40),
                            width: 1,
                          ),
                  boxShadow:
                      isSelected
                          ? [
                            BoxShadow(
                              color: _primary.withAlpha(60),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                          : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : _textSecondary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? Colors.white.withAlpha(50)
                                : _textMuted.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : _textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildServicesGrid() {
    final services = _filteredServices;

    if (services.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _textMuted.withAlpha(15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search_off_rounded,
                  size: 48,
                  color: _textMuted.withAlpha(100),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'No services found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try a different search or category',
                style: TextStyle(fontSize: 14, color: _textMuted),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                    _selectedCategory = 'All';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00C853), Color(0xFF69F0AE)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _primary.withAlpha(60),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Clear filters',
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
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final service = services[index];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 300 + (index * 50)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: _buildServiceCard(service),
          );
        }, childCount: services.length),
      ),
    );
  }

  Widget _buildServiceCard(_ServiceData service) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _navigateToDetails(service);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: service.iconColor.withAlpha(15),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Subtle gradient accent
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 4,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        service.iconColor,
                        service.iconColor.withAlpha(150),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                child: Row(
                  children: [
                    // Icon container
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: service.iconColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        service.icon,
                        color: service.iconColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Info
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
                                    color: _textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Category badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: service.iconColor.withAlpha(20),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  service.category,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: service.iconColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Details row
                          Row(
                            children: [
                              // Duration
                              Icon(
                                Icons.schedule_rounded,
                                size: 14,
                                color: _textMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                service.duration,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: _textMuted,
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Rating
                              const Icon(
                                Icons.star_rounded,
                                size: 14,
                                color: Color(0xFFFFC107),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${service.rating}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _textPrimary,
                                ),
                              ),
                              Text(
                                ' (${service.reviewCount})',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: _textMuted,
                                ),
                              ),

                              const Spacer(),

                              // Price
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${service.price}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: service.iconColor,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' EGP',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: service.iconColor.withAlpha(180),
                                      ),
                                    ),
                                  ],
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
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetails(_ServiceData service) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (_, __, ___) => ServiceDetailsPage(
              title: service.title,
              price: '${service.price} EGP',
              duration: service.duration,
              icon: service.icon,
              iconColor: service.iconColor,
              description: service.description,
              includes: service.includes,
            ),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          );
        },
      ),
    );
  }
}

class _ServiceData {
  final String id;
  final String title;
  final int price;
  final String duration;
  final IconData icon;
  final Color iconColor;
  final String category;
  final double rating;
  final int reviewCount;
  final String description;
  final List<String> includes;

  _ServiceData({
    required this.id,
    required this.title,
    required this.price,
    required this.duration,
    required this.icon,
    required this.iconColor,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.description,
    required this.includes,
  });
}
