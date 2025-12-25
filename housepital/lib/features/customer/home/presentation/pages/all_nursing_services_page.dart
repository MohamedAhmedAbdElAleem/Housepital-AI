import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/presentation/pages/service_details_page.dart';

class AllNursingServicesPage extends StatefulWidget {
  const AllNursingServicesPage({super.key});

  @override
  State<AllNursingServicesPage> createState() => _AllNursingServicesPageState();
}

class _AllNursingServicesPageState extends State<AllNursingServicesPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

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
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
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
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeader(),
          _buildSearchBar(),
          _buildCategoryTabs(),
          _buildServicesGrid(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      stretch: true,
      backgroundColor: const Color(0xFF00B870),
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF00D47F), Color(0xFF00B870), Color(0xFF009960)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.medical_services_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nursing Services',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${_allServices.length} services available',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: 'Search services...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Color(0xFF00B870),
            ),
            suffixIcon:
                _searchQuery.isNotEmpty
                    ? IconButton(
                      icon: const Icon(
                        Icons.clear_rounded,
                        color: Color(0xFF94A3B8),
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                    : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SliverToBoxAdapter(
      child: Container(
        height: 50,
        margin: const EdgeInsets.only(top: 20),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            final isSelected = _selectedCategory == category;

            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  gradient:
                      isSelected
                          ? const LinearGradient(
                            colors: [Color(0xFF00D47F), Color(0xFF00B870)],
                          )
                          : null,
                  color: isSelected ? null : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border:
                      isSelected
                          ? null
                          : Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow:
                      isSelected
                          ? [
                            BoxShadow(
                              color: const Color(0xFF00B870).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                          : null,
                ),
                child: Center(
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
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
              Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'No services found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(20),
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
      onTap: () => _navigateToDetails(service),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: service.iconColor.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top colored banner
            Container(
              height: 6,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    service.iconColor,
                    service.iconColor.withOpacity(0.7),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: service.iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      service.icon,
                      color: service.iconColor,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              service.duration,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${service.rating}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            Text(
                              ' (${service.reviewCount})',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${service.price}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: service.iconColor,
                        ),
                      ),
                      const Text(
                        'EGP',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF94A3B8),
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
