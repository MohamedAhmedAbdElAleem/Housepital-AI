import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../services/presentation/pages/service_details_page.dart';
import '../widgets/nursing_service_card.dart';

class AllNursingServicesPage extends StatefulWidget {
  const AllNursingServicesPage({super.key});

  @override
  State<AllNursingServicesPage> createState() => _AllNursingServicesPageState();
}

class _AllNursingServicesPageState extends State<AllNursingServicesPage> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  String _selectedSort = 'Recommended';
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
      description: 'Professional wound care and dressing services provided by certified nurses.',
      includes: ['Professional wound assessment', 'Sterile dressing', 'Wound cleaning', 'Follow-up visits', 'Progress monitoring'],
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
      includes: ['All types of injections', 'Proper sterilization', 'Medication administration', 'Post-injection care'],
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
      description: 'Comprehensive care for elderly patients including assistance with daily activities.',
      includes: ['Daily activity assistance', 'Medication management', 'Vital signs monitoring', 'Companionship'],
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
      description: 'Post-operative care services to ensure smooth recovery after surgery.',
      includes: ['Surgical wound care', 'Pain management', 'Medication administration', 'Vital signs monitoring'],
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
      includes: ['Newborn monitoring', 'Feeding assistance', 'Bathing', 'Development assessment'],
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
      description: 'Intravenous fluid and medication therapy administered safely at home.',
      includes: ['IV line insertion', 'Medication administration', 'Fluid therapy', 'Monitoring'],
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
      description: 'Professional catheter insertion, maintenance, and care services.',
      includes: ['Catheter insertion', 'Regular maintenance', 'Infection prevention', 'Patient education'],
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
      includes: ['Blood pressure', 'Temperature', 'Heart rate', 'Oxygen saturation', 'Health report'],
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
      includes: ['Blood sample collection', 'Proper labeling', 'Lab delivery', 'Results coordination'],
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
      description: 'Home physiotherapy sessions for rehabilitation and mobility.',
      includes: ['Assessment', 'Exercise therapy', 'Mobility training', 'Progress tracking'],
    ),
  ];

  List<_ServiceData> get _filteredServices {
    var filtered = _allServices.where((service) {
      final matchesCategory = _selectedCategory == 'All' || service.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty || service.title.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    switch (_selectedSort) {
      case 'Price: Low to High':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price: High to Low':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Highest Rated':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Recommended':
      default:
        // Keep original order
        break;
    }
    return filtered;
  }

  @override
  void dispose() {
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

    final services = _filteredServices;
    const primary = Color(0xFF2ECC71);
    const surfaceColor = Color(0xFFF0F4F8);

    return Scaffold(
      backgroundColor: surfaceColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Radical Dynamic Header
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            stretch: true,
            backgroundColor: primary,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(50),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withAlpha(80)),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(50),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withAlpha(80)),
                  ),
                  child: const Icon(Icons.tune_rounded, color: Colors.white, size: 18),
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _showFilterBottomSheet();
                },
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2ECC71), Color(0xFF27AE60), Color(0xFF1E8449)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Icon(Icons.medical_services_rounded, size: 250, color: Colors.white.withAlpha(15)),
                    ),
                    Positioned(
                      bottom: -20,
                      left: -20,
                      child: Container(
                        width: 150, height: 150,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withAlpha(10)),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text(
                              'Nursing\nServices',
                              style: TextStyle(
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
                              'Explore ${_allServices.length} premium at-home treatments.',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color: Colors.white.withAlpha(220),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Floating Search Bar inside Header
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.black.withAlpha(10)),
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (val) => setState(() => _searchQuery = val),
                                    style: const TextStyle(color: Color(0xFF1A202C), fontFamily: 'Inter', fontSize: 15),
                                    decoration: InputDecoration(
                                      hintText: 'Search treatments...',
                                      hintStyle: const TextStyle(color: Color(0xFF718096), fontSize: 15),
                                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF2ECC71), size: 22),
                                      suffixIcon: _searchQuery.isNotEmpty
                                          ? IconButton(
                                              icon: Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withAlpha(10),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(Icons.close_rounded, color: Color(0xFF718096), size: 14),
                                              ),
                                              onPressed: () {
                                                _searchController.clear();
                                                setState(() => _searchQuery = '');
                                              },
                                            )
                                          : null,
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    ),
                                  ),
                                ),
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

          // Sticky Category Tabs
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyCategoryDelegate(
              categories: _categories,
              selectedCategory: _selectedCategory,
              onSelect: (val) {
                HapticFeedback.selectionClick();
                setState(() => _selectedCategory = val);
              },
            ),
          ),

          // Service List
          if (services.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.withAlpha(100)),
                    const SizedBox(height: 16),
                    const Text(
                      'No services found',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A202C)),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Try a different search or category',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Color(0xFF718096)),
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
                  final service = services[index];
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 300 + (index * 50).clamp(0, 500)),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Opacity(opacity: value, child: child),
                      );
                    },
                    child: NursingServiceCard(
                      title: service.title,
                      category: service.category,
                      duration: service.duration,
                      rating: service.rating,
                      reviewCount: service.reviewCount,
                      price: service.price,
                      icon: service.icon,
                      iconColor: service.iconColor,
                      onTap: () => _navigateToDetails(service),
                    ),
                  );
                }, childCount: services.length),
              ),
            ),
        ],
      ),
    );
  }

  void _navigateToDetails(_ServiceData service) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ServiceDetailsPage(
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
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filter Services',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        setModalState(() {
                          _selectedSort = 'Recommended';
                        });
                        setState(() {
                          _selectedCategory = 'All';
                          _searchQuery = '';
                          _searchController.clear();
                          _selectedSort = 'Recommended';
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Reset', style: TextStyle(color: Color(0xFF2ECC71), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Sort By', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildFilterChip('Recommended', _selectedSort == 'Recommended', () {
                      setModalState(() => _selectedSort = 'Recommended');
                    }),
                    _buildFilterChip('Price: Low to High', _selectedSort == 'Price: Low to High', () {
                      setModalState(() => _selectedSort = 'Price: Low to High');
                    }),
                    _buildFilterChip('Price: High to Low', _selectedSort == 'Price: High to Low', () {
                      setModalState(() => _selectedSort = 'Price: High to Low');
                    }),
                    _buildFilterChip('Highest Rated', _selectedSort == 'Highest Rated', () {
                      setModalState(() => _selectedSort = 'Highest Rated');
                    }),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      setState(() {}); // Trigger main page rebuild to apply sort
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2ECC71),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('Apply Filters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2ECC71).withAlpha(20) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF2ECC71) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? const Color(0xFF2ECC71) : Colors.black87,
          ),
        ),
      ),
    );
  }
}

class _StickyCategoryDelegate extends SliverPersistentHeaderDelegate {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onSelect;

  _StickyCategoryDelegate({
    required this.categories,
    required this.selectedCategory,
    required this.onSelect,
  });

  @override
  double get minExtent => 70;
  @override
  double get maxExtent => 70;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final isScrolled = shrinkOffset > 0 || overlapsContent;
    
    return Container(
      decoration: BoxDecoration(
        color: isScrolled ? const Color(0xFFF0F4F8).withAlpha(240) : const Color(0xFFF0F4F8),
        boxShadow: isScrolled
            ? [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, 4))]
            : [],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: isScrolled ? 10 : 0, sigmaY: isScrolled ? 10 : 0),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            physics: const BouncingScrollPhysics(),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = selectedCategory == category;

              return GestureDetector(
                onTap: () => onSelect(category),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF1A202C) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: isSelected ? Colors.transparent : Colors.black.withAlpha(10)),
                    boxShadow: isSelected
                        ? [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 10, offset: const Offset(0, 4))]
                        : [],
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF718096),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _StickyCategoryDelegate oldDelegate) {
    return oldDelegate.selectedCategory != selectedCategory;
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
