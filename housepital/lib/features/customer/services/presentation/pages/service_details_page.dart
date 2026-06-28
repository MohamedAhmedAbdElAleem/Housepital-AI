import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../booking/presentation/pages/booking_step1_select_patient.dart';
import '../../../../../core/network/api_constants.dart';
import '../../../../../core/network/api_service.dart';
import '../../../../../generated/l10n/app_localizations.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 DESIGN SYSTEM
// ═══════════════════════════════════════════════════════════════════════════

class _ServiceDesign {
  static Color surface(bool isDark) => isDark ? const Color(0xFF0D0C11) : const Color(0xFFF8FAFC);
  static Color cardBg(bool isDark) => isDark ? const Color(0xFF16151A) : Colors.white;
  static Color textPrimary(bool isDark) => isDark ? Colors.white : const Color(0xFF1E293B);
  static Color textSecondary(bool isDark) => isDark ? const Color(0xFFA19EAB) : const Color(0xFF64748B);
  static Color textMuted(bool isDark) => isDark ? const Color(0xFF555263) : const Color(0xFF94A3B8);
  static Color divider(bool isDark) => isDark ? const Color(0xFF2A2831) : const Color(0xFFE2E8F0);
  static const starColor = Color(0xFFF59E0B);
  static const successGreen = Color(0xFF00B870);
  static const infoBlue = Color(0xFF3B82F6);

  static BoxShadow cardShadow(bool isDark) => BoxShadow(
    color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
    blurRadius: 20,
    offset: const Offset(0, 8),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// 📱 MAIN PAGE
// ═══════════════════════════════════════════════════════════════════════════

class ServiceDetailsPage extends StatefulWidget {
  final String title;
  final String? englishTitle; // Always English — used for API matching
  final String? serviceId;
  final String? serviceRoute;
  final String price;
  final String duration;
  final IconData icon;
  final Color iconColor;
  final String description;
  final List<String> includes;

  const ServiceDetailsPage({
    super.key,
    required this.title,
    this.englishTitle,
    this.serviceId,
    this.serviceRoute,
    required this.price,
    required this.duration,
    required this.icon,
    required this.iconColor,
    required this.description,
    required this.includes,
  });

  @override
  State<ServiceDetailsPage> createState() => _ServiceDetailsPageState();
}

class _ServiceDetailsPageState extends State<ServiceDetailsPage>
    with SingleTickerProviderStateMixin {
  bool get isDark => Theme.of(context).brightness == Brightness.dark;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isFavorite = false;
  int _selectedTab = 0;
  bool _isResolvingServiceId = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double get _priceValue {
    return double.tryParse(widget.price.replaceAll(RegExp(r'[^0-9.]'), '')) ??
        0.0;
  }

  bool _isObjectId(String value) =>
      RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(value);

  String _slugFromTitle(String value) {
    return value
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }

  Future<String?> _resolveServiceIdFromApi() async {
    final apiService = ApiService();
    final response = await apiService.get(
      ApiConstants.publicHomeNursingServices,
    );
    final services =
        (response is Map<String, dynamic>)
            ? (response['data'] as List? ?? const [])
            : const [];

    if (services.isEmpty) return null;

    // Use the stable English title if available; otherwise fall back to widget.title.
    // This ensures Arabic locale never breaks API matching.
    final englishName = (widget.englishTitle ?? widget.title).toLowerCase().trim();
    final routeToken = (widget.serviceRoute ?? '').toLowerCase().trim();
    final titleSlug = _slugFromTitle(widget.englishTitle ?? widget.title);

    String? pickId(dynamic item) {
      if (item is! Map) return null;

      final id = item['_id']?.toString() ?? '';
      final category = item['category']?.toString().toLowerCase().trim() ?? '';
      final name = item['name']?.toString().toLowerCase().trim() ?? '';

      if (id.isEmpty) return null;
      // 1. Match by stable English category slug (most reliable)
      if (routeToken.isNotEmpty && category == routeToken) return id;
      // 2. Match by English name slug vs category
      if (titleSlug.isNotEmpty && category == titleSlug) return id;
      // 3. Direct English name match
      if (name.isNotEmpty && name == englishName) return id;
      return null;
    }

    for (final item in services) {
      final id = pickId(item);
      if (id != null) return id;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: _ServiceDesign.surface(isDark),
      body: Stack(
        children: [
          // Animated Background gradient
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            height: 380,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.iconColor,
                  widget.iconColor.withOpacity(0.85),
                  widget.iconColor.withOpacity(0.7),
                ],
              ),
            ),
          ),

          // Decorative circles
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(l10n),
              SliverToBoxAdapter(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        _buildHeroCard(l10n),
                        _buildQuickStats(l10n),
                        _buildServiceHighlights(l10n),
                        _buildTabSelector(l10n),
                        _buildTabContent(l10n),
                        _buildNursePreview(l10n),
                        _buildGuaranteeCard(l10n),
                        _buildBottomSpacing(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Floating Book Button
          _buildFloatingBookButton(l10n),
        ],
      ),
    );
  }

  Widget _buildAppBar(AppLocalizations l10n) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      stretch: true,
      backgroundColor: widget.iconColor,
      leading: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Icon(Icons.arrow_back_rounded, color: isDark ? const Color(0xFF16151A) : Colors.white),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.share_rounded, color: isDark ? const Color(0xFF16151A) : Colors.white),
                    const SizedBox(width: 12),
                    Text(l10n.shareComingSoon),
                  ],
                ),
                backgroundColor: widget.iconColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Icon(
              Icons.share_rounded,
              color: isDark ? const Color(0xFF16151A) : Colors.white,
              size: 22,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            setState(() => _isFavorite = !_isFavorite);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _isFavorite ? Colors.white : Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color:
                    _isFavorite
                        ? Colors.transparent
                        : Colors.white.withOpacity(0.1),
              ),
              boxShadow:
                  _isFavorite
                      ? [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                      : null,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                key: ValueKey(_isFavorite),
                color: _isFavorite ? const Color(0xFFEF4444) : Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.fadeTitle],
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.iconColor,
                widget.iconColor.withOpacity(0.85),
                widget.iconColor.withOpacity(0.7),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 35),
                Hero(
                  tag: 'service_icon_${widget.title}',
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Icon(widget.icon, size: 40, color: isDark ? const Color(0xFF16151A) : Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFF16151A) : Colors.white,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        color: isDark ? const Color(0xFF16151A) : Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        l10n.professionalService,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.95),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _ServiceDesign.cardBg(isDark),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Rating and Reviews
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isDark ? Colors.amber.withOpacity(0.15) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: Color(0xFFF59E0B),
                      size: 18,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '4.9',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.reviewsCount(2847),
                style: TextStyle(fontSize: 14, color: isDark ? const Color(0xFFA19EAB) : Colors.grey[550]),
              ),
              const SizedBox(width: 12),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF555263) : Colors.grey[400],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.bookingsCount(5200),
                style: TextStyle(fontSize: 14, color: isDark ? const Color(0xFFA19EAB) : Colors.grey[550]),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Description
          Text(
            widget.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: _ServiceDesign.textSecondary(isDark),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.payments_rounded,
              label: l10n.price,
              value: widget.price,
              color: const Color(0xFF00B870),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.schedule_rounded,
              label: l10n.duration,
              value: widget.duration,
              color: const Color(0xFF3B82F6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.bolt_rounded,
              label: l10n.response,
              value: l10n.lessThan5Min,
              color: const Color(0xFFF59E0B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _ServiceDesign.cardBg(isDark),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(isDark ? 0.15 : 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFFA19EAB) : Colors.grey[500],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceHighlights(AppLocalizations l10n) {
    final highlights = [
      {
        'icon': Icons.verified_user_rounded,
        'title': l10n.highlightCertified,
        'subtitle': l10n.highlightCertifiedDesc,
      },
      {
        'icon': Icons.schedule_rounded,
        'title': l10n.highlightOnTime,
        'subtitle': l10n.highlightOnTimeDesc,
      },
      {
        'icon': Icons.thumb_up_rounded,
        'title': l10n.highlightTrusted,
        'subtitle': l10n.highlightTrustedDesc,
      },
      {
        'icon': Icons.support_agent_rounded,
        'title': l10n.highlightSupport,
        'subtitle': l10n.highlightSupportDesc,
      },
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children:
            highlights.map((item) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    right:
                        highlights.indexOf(item) < highlights.length - 1
                            ? 10
                            : 0,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: _ServiceDesign.cardBg(isDark),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        color: widget.iconColor,
                        size: 22,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['title'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _ServiceDesign.textPrimary(isDark),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['subtitle'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          color: _ServiceDesign.textMuted(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildTabSelector(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1C24) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _ServiceDesign.divider(isDark).withOpacity(0.5)),
      ),
      child: Row(
        children: [
          _buildTab(0, l10n.tabIncludes, Icons.check_circle_outline_rounded),
          _buildTab(1, l10n.tabReviews, Icons.star_outline_rounded),
          _buildTab(2, l10n.tabFaq, Icons.help_outline_rounded),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label, IconData icon) {
    final isSelected = _selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedTab = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? (isDark ? const Color(0xFF2C2A35) : Colors.white) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: widget.iconColor.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? widget.iconColor : _ServiceDesign.textMuted(isDark),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color:
                      isSelected ? widget.iconColor : _ServiceDesign.textMuted(isDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(AppLocalizations l10n) {
    switch (_selectedTab) {
      case 0:
        return _buildIncludesContent(l10n);
      case 1:
        return _buildReviewsContent(l10n);
      case 2:
        return _buildFAQContent(l10n);
      default:
        return _buildIncludesContent(l10n);
    }
  }

  Widget _buildIncludesContent(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _ServiceDesign.cardBg(isDark),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.checklist_rounded,
                  color: widget.iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.whatsIncluded,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _ServiceDesign.textPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...widget.includes.asMap().entries.map((entry) {
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 300 + (entry.key * 100)),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(20 * (1 - value), 0),
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            widget.iconColor,
                            widget.iconColor.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.check,
                        color: isDark ? const Color(0xFF16151A) : Colors.white,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildReviewsContent(AppLocalizations l10n) {
    final reviews = [
      {
        'name': l10n.review1Name,
        'rating': 5,
        'comment': l10n.review1Comment,
        'date': l10n.timeAgo2Days,
      },
      {
        'name': l10n.review2Name,
        'rating': 5,
        'comment': l10n.review2Comment,
        'date': l10n.timeAgo1Week,
      },
      {
        'name': l10n.review3Name,
        'rating': 4,
        'comment': l10n.review3Comment,
        'date': l10n.timeAgo2Weeks,
      },
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        children:
            reviews.map((review) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _ServiceDesign.cardBg(isDark),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: widget.iconColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              review['name'].toString()[0],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: widget.iconColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review['name'] as String,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _ServiceDesign.textPrimary(isDark),
                                ),
                              ),
                              Row(
                                children: List.generate(5, (i) {
                                  return Icon(
                                    i < (review['rating'] as int)
                                        ? Icons.star_rounded
                                        : Icons.star_border_rounded,
                                    size: 14,
                                    color: const Color(0xFFF59E0B),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          review['date'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF555263) : Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      review['comment'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? const Color(0xFFA19EAB) : Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildFAQContent(AppLocalizations l10n) {
    final faqs = [
      {
        'q': l10n.faq1Q,
        'a': l10n.faq1A,
      },
      {
        'q': l10n.faq2Q,
        'a': l10n.faq2A,
      },
      {
        'q': l10n.faq3Q,
        'a': l10n.faq3A,
      },
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        children:
            faqs.asMap().entries.map((entry) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: _ServiceDesign.cardBg(isDark),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.help_outline,
                      color: widget.iconColor,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    entry.value['q']!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _ServiceDesign.textPrimary(isDark),
                    ),
                  ),
                  children: [
                    Text(
                      entry.value['a']!,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? const Color(0xFFA19EAB) : Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildNursePreview(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.iconColor.withOpacity(0.12),
            widget.iconColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.iconColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _ServiceDesign.cardBg(isDark),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: widget.iconColor.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.verified_user_rounded,
              color: widget.iconColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.verifiedNursesOnly,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _ServiceDesign.textPrimary(isDark),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.verifiedNursesDesc,
                  style: TextStyle(
                    fontSize: 13,
                    color: _ServiceDesign.textSecondary(isDark),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: widget.iconColor.withOpacity(0.6),
          ),
        ],
      ),
    );
  }

  Widget _buildGuaranteeCard(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _ServiceDesign.cardBg(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _ServiceDesign.divider(isDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1B3B2B) : const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.shield_rounded,
                  color: isDark ? const Color(0xFF2ECC71) : const Color(0xFF16A34A),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.satisfactionGuarantee,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _ServiceDesign.textPrimary(isDark),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.satisfactionGuaranteeDesc,
                      style: TextStyle(
                        fontSize: 12,
                        color: _ServiceDesign.textSecondary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildGuaranteeItem(Icons.access_time_rounded, l10n.freeReschedule),
              const SizedBox(width: 12),
              _buildGuaranteeItem(Icons.replay_rounded, l10n.easyRefund),
              const SizedBox(width: 12),
              _buildGuaranteeItem(Icons.headset_mic_rounded, l10n.support247),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGuaranteeItem(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: _ServiceDesign.surface(isDark),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: widget.iconColor),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: _ServiceDesign.textSecondary(isDark),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSpacing() {
    return const SizedBox(height: 140);
  }

  Widget _buildFloatingBookButton(AppLocalizations l10n) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        decoration: BoxDecoration(
          color: _ServiceDesign.cardBg(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: 25,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Price Section
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.totalPrice,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _ServiceDesign.textMuted(isDark),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          widget.price,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: widget.iconColor,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            l10n.perVisit,
                            style: TextStyle(
                              fontSize: 12,
                              color: _ServiceDesign.textMuted(isDark),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Book Button
              Expanded(
                flex: 3,
                child: GestureDetector(
                  onTap:
                      _isResolvingServiceId
                          ? null
                          : () {
                            HapticFeedback.mediumImpact();
                            _navigateToBooking(l10n);
                          },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.iconColor,
                          widget.iconColor.withOpacity(0.85),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: widget.iconColor.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.calendar_today_rounded,
                            color: isDark ? const Color(0xFF16151A) : Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        _isResolvingServiceId
                            ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : Text(
                              l10n.bookNow,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: isDark ? const Color(0xFF16151A) : Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToBooking(AppLocalizations l10n) async {
    if (_isResolvingServiceId) return;

    setState(() => _isResolvingServiceId = true);

    String resolvedServiceId = widget.serviceId?.trim() ?? '';

    try {
      if (!_isObjectId(resolvedServiceId)) {
        resolvedServiceId =
            await _resolveServiceIdFromApi() ?? resolvedServiceId;
      }
    } catch (_) {
      // Fallback to known route/title slug if the lookup request fails.
    }

    if (!_isObjectId(resolvedServiceId)) {
      if (mounted) {
        setState(() => _isResolvingServiceId = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.serviceUnavailable,
            ),
          ),
        );
      }
      return;
    }

    if (!mounted) return;

    setState(() => _isResolvingServiceId = false);

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (_, __, ___) => BookingStep1SelectPatient(
              serviceName: widget.title,
              serviceId: resolvedServiceId,
              servicePrice: _priceValue,
            ),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 1.0),
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
