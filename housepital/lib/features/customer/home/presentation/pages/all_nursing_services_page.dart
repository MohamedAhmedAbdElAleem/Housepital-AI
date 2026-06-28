import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../../generated/l10n/app_localizations.dart';
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

  static String _getCategoryNameStatic(String cat, AppLocalizations l10n) {
    switch (cat) {
      case 'All':
        return l10n.categoryAll;
      case 'Popular':
        return l10n.categoryPopular;
      case 'Quick':
        return l10n.categoryQuick;
      case 'Specialized':
        return l10n.categorySpecialized;
      case 'Long-term':
        return l10n.categoryLongTerm;
      default:
        return cat;
    }
  }

  String _getSortName(String sort, AppLocalizations l10n) {
    switch (sort) {
      case 'Recommended':
        return l10n.sortRecommended;
      case 'Price: Low to High':
        return l10n.sortPriceLowToHigh;
      case 'Price: High to Low':
        return l10n.sortPriceHighToLow;
      case 'Highest Rated':
        return l10n.sortHighestRated;
      default:
        return sort;
    }
  }

  List<_ServiceData> _getServices(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      _ServiceData(
        id: '1',
        title: l10n.serviceWoundCareTitle,
        price: 150,
        duration: l10n.serviceWoundCareDuration,
        icon: Icons.healing_rounded,
        iconColor: const Color(0xFFEF4444),
        category: 'Popular',
        rating: 4.9,
        reviewCount: 312,
        description: l10n.serviceWoundCareDesc,
        includes: [
          l10n.serviceWoundCareInc1,
          l10n.serviceWoundCareInc2,
          l10n.serviceWoundCareInc3,
          l10n.serviceWoundCareInc4,
          l10n.serviceWoundCareInc5,
        ],
      ),
      _ServiceData(
        id: '2',
        title: l10n.serviceInjectionsTitle,
        price: 50,
        duration: l10n.serviceInjectionsDuration,
        icon: Icons.medication_liquid_rounded,
        iconColor: const Color(0xFF3B82F6),
        category: 'Quick',
        rating: 4.8,
        reviewCount: 548,
        description: l10n.serviceInjectionsDesc,
        includes: [
          l10n.serviceInjectionsInc1,
          l10n.serviceInjectionsInc2,
          l10n.serviceInjectionsInc3,
          l10n.serviceInjectionsInc4,
        ],
      ),
      _ServiceData(
        id: '3',
        title: l10n.serviceElderlyCareTitle,
        price: 200,
        duration: l10n.serviceElderlyCareDuration,
        icon: Icons.elderly_rounded,
        iconColor: const Color(0xFF8B5CF6),
        category: 'Long-term',
        rating: 4.9,
        reviewCount: 187,
        description: l10n.serviceElderlyCareDesc,
        includes: [
          l10n.serviceElderlyCareInc1,
          l10n.serviceElderlyCareInc2,
          l10n.serviceElderlyCareInc3,
          l10n.serviceElderlyCareInc4,
        ],
      ),
      _ServiceData(
        id: '4',
        title: l10n.servicePostOpCareTitle,
        price: 300,
        duration: l10n.servicePostOpCareDuration,
        icon: Icons.monitor_heart_rounded,
        iconColor: const Color(0xFF10B981),
        category: 'Specialized',
        rating: 4.9,
        reviewCount: 203,
        description: l10n.servicePostOpCareDesc,
        includes: [
          l10n.servicePostOpCareInc1,
          l10n.servicePostOpCareInc2,
          l10n.servicePostOpCareInc3,
          l10n.servicePostOpCareInc4,
        ],
      ),
      _ServiceData(
        id: '5',
        title: l10n.serviceBabyCareTitle,
        price: 180,
        duration: l10n.serviceBabyCareDuration,
        icon: Icons.child_care_rounded,
        iconColor: const Color(0xFFF59E0B),
        category: 'Specialized',
        rating: 4.8,
        reviewCount: 156,
        description: l10n.serviceBabyCareDesc,
        includes: [
          l10n.serviceBabyCareInc1,
          l10n.serviceBabyCareInc2,
          l10n.serviceBabyCareInc3,
          l10n.serviceBabyCareInc4,
        ],
      ),
      _ServiceData(
        id: '6',
        title: l10n.serviceIvTherapyTitle,
        price: 250,
        duration: l10n.serviceIvTherapyDuration,
        icon: Icons.water_drop_rounded,
        iconColor: const Color(0xFFEC4899),
        category: 'Popular',
        rating: 4.7,
        reviewCount: 421,
        description: l10n.serviceIvTherapyDesc,
        includes: [
          l10n.serviceIvTherapyInc1,
          l10n.serviceIvTherapyInc2,
          l10n.serviceIvTherapyInc3,
          l10n.serviceIvTherapyInc4,
        ],
      ),
      _ServiceData(
        id: '7',
        title: l10n.serviceCatheterCareTitle,
        price: 120,
        duration: l10n.serviceCatheterCareDuration,
        icon: Icons.medical_services_rounded,
        iconColor: const Color(0xFF06B6D4),
        category: 'Specialized',
        rating: 4.8,
        reviewCount: 98,
        description: l10n.serviceCatheterCareDesc,
        includes: [
          l10n.serviceCatheterCareInc1,
          l10n.serviceCatheterCareInc2,
          l10n.serviceCatheterCareInc3,
          l10n.serviceCatheterCareInc4,
        ],
      ),
      _ServiceData(
        id: '8',
        title: l10n.serviceVitalSignsTitle,
        price: 80,
        duration: l10n.serviceVitalSignsDuration,
        icon: Icons.favorite_rounded,
        iconColor: const Color(0xFF84CC16),
        category: 'Quick',
        rating: 4.9,
        reviewCount: 672,
        description: l10n.serviceVitalSignsDesc,
        includes: [
          l10n.serviceVitalSignsInc1,
          l10n.serviceVitalSignsInc2,
          l10n.serviceVitalSignsInc3,
          l10n.serviceVitalSignsInc4,
          l10n.serviceVitalSignsInc5,
        ],
      ),
      _ServiceData(
        id: '9',
        title: l10n.serviceBloodDrawTitle,
        price: 100,
        duration: l10n.serviceBloodDrawDuration,
        icon: Icons.bloodtype_rounded,
        iconColor: const Color(0xFFDC2626),
        category: 'Quick',
        rating: 4.8,
        reviewCount: 389,
        description: l10n.serviceBloodDrawDesc,
        includes: [
          l10n.serviceBloodDrawInc1,
          l10n.serviceBloodDrawInc2,
          l10n.serviceBloodDrawInc3,
          l10n.serviceBloodDrawInc4,
        ],
      ),
      _ServiceData(
        id: '10',
        title: l10n.servicePhysiotherapyTitle,
        price: 350,
        duration: l10n.servicePhysiotherapyDuration,
        icon: Icons.accessibility_new_rounded,
        iconColor: const Color(0xFF7C3AED),
        category: 'Long-term',
        rating: 4.9,
        reviewCount: 234,
        description: l10n.servicePhysiotherapyDesc,
        includes: [
          l10n.servicePhysiotherapyInc1,
          l10n.servicePhysiotherapyInc2,
          l10n.servicePhysiotherapyInc3,
          l10n.servicePhysiotherapyInc4,
        ],
      ),
    ];
  }

  List<_ServiceData> get _allServices => _getServices(context);

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
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A202C);
    final textMuted = isDark ? const Color(0xFFA19EAB) : const Color(0xFF718096);
    final surfaceColor = isDark ? const Color(0xFF0D0C11) : const Color(0xFFF0F4F8);
    final cardBg = isDark ? const Color(0xFF16151A) : Colors.white;
    final searchBorder = isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(10);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    final services = _filteredServices;
    const primary = Color(0xFF2ECC71);

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
                  _showFilterBottomSheet(isDark, l10n);
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
                            Text(
                              l10n.nursingServicesHeader,
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
                              l10n.nursingServicesSubtitle(_allServices.length),
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
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: searchBorder),
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (val) => setState(() => _searchQuery = val),
                                    style: TextStyle(color: textPrimary, fontFamily: 'Inter', fontSize: 15),
                                    decoration: InputDecoration(
                                      hintText: l10n.searchTreatments,
                                      hintStyle: TextStyle(color: textMuted, fontSize: 15),
                                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF2ECC71), size: 22),
                                      suffixIcon: _searchQuery.isNotEmpty
                                          ? IconButton(
                                              icon: Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withAlpha(10),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(Icons.close_rounded, color: textMuted, size: 14),
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
              isDark: isDark,
              categories: _categories,
              selectedCategory: _selectedCategory,
              onSelect: (val) {
                HapticFeedback.selectionClick();
                setState(() => _selectedCategory = val);
              },
              l10n: l10n,
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
                    Text(
                      l10n.noServicesFound,
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.tryDifferentSearch,
                      style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: textMuted),
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
                      category: _getCategoryNameStatic(service.category, l10n),
                      duration: service.duration,
                      rating: service.rating,
                      reviewCount: service.reviewCount,
                      price: service.price,
                      icon: service.icon,
                      iconColor: service.iconColor,
                      onTap: () => _navigateToDetails(service, l10n),
                    ),
                  );
                }, childCount: services.length),
              ),
            ),
        ],
      ),
    );
  }

  void _navigateToDetails(_ServiceData service, AppLocalizations l10n) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ServiceDetailsPage(
          title: service.title,
          price: l10n.priceEgp(service.price),
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

  void _showFilterBottomSheet(bool isDark, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16151A) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
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
                      color: isDark ? const Color(0xFF2A2831) : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.filterServices,
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
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
                      child: Text(l10n.reset, style: const TextStyle(color: Color(0xFF2ECC71), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(l10n.sortBy, style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildFilterChip(_getSortName('Recommended', l10n), _selectedSort == 'Recommended', isDark, () {
                      setModalState(() => _selectedSort = 'Recommended');
                    }),
                    _buildFilterChip(_getSortName('Price: Low to High', l10n), _selectedSort == 'Price: Low to High', isDark, () {
                      setModalState(() => _selectedSort = 'Price: Low to High');
                    }),
                    _buildFilterChip(_getSortName('Price: High to Low', l10n), _selectedSort == 'Price: High to Low', isDark, () {
                      setModalState(() => _selectedSort = 'Price: High to Low');
                    }),
                    _buildFilterChip(_getSortName('Highest Rated', l10n), _selectedSort == 'Highest Rated', isDark, () {
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
                    child: Text(l10n.applyFilters, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

  Widget _buildFilterChip(String label, bool isSelected, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2ECC71).withAlpha(20) : (isDark ? const Color(0xFF1E1C24) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF2ECC71) : (isDark ? const Color(0xFF2A2831) : Colors.grey.shade300),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? const Color(0xFF2ECC71) : (isDark ? Colors.white : Colors.black87),
          ),
        ),
      ),
    );
  }
}

class _StickyCategoryDelegate extends SliverPersistentHeaderDelegate {
  final bool isDark;
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onSelect;
  final AppLocalizations l10n;

  _StickyCategoryDelegate({
    required this.isDark,
    required this.categories,
    required this.selectedCategory,
    required this.onSelect,
    required this.l10n,
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
        color: isScrolled ? (isDark ? const Color(0xFF0D0C11).withAlpha(240) : const Color(0xFFF0F4F8).withAlpha(240)) : (isDark ? const Color(0xFF0D0C11) : const Color(0xFFF0F4F8)),
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
              final categoryName = _AllNursingServicesPageState._getCategoryNameStatic(category, l10n);

              return GestureDetector(
                onTap: () => onSelect(category),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? (isDark ? Colors.white : const Color(0xFF1A202C)) : (isDark ? const Color(0xFF1E1C24) : Colors.white),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: isSelected ? Colors.transparent : Colors.black.withAlpha(10)),
                    boxShadow: isSelected
                        ? [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 10, offset: const Offset(0, 4))]
                        : [],
                  ),
                  child: Text(
                    categoryName,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? (isDark ? Colors.black : Colors.white) : (isDark ? const Color(0xFFA19EAB) : const Color(0xFF718096)),
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
