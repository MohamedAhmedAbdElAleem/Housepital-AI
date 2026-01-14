import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../booking/presentation/pages/bookings_page.dart';
import '../../../../chatbot/presentation/pages/chatbot_page.dart';
import '../../../services/presentation/pages/service_details_page.dart';
import '../../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../../auth/data/datasources/auth_remote_datasource.dart';
import '../../../../../core/network/api_service.dart';
import '../../../../../core/utils/token_manager.dart';
import '../../../../auth/data/models/user_model.dart';
import '../pages/all_nursing_services_page.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  UserModel? _user;
  bool _isLoading = true;
  bool _hasActiveBooking = true; // TODO: Get from API

  late AnimationController _mainController;
  late AnimationController _pulseController;

  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  // ═══════════════════════════════════════════════════════════════════════════
  // 🎨 DESIGN SYSTEM
  // ═══════════════════════════════════════════════════════════════════════════

  static const _primary = Color(0xFF00C853);

  static const _surface = Color(0xFFFAFBFC);
  static const _card = Colors.white;

  static const _textPrimary = Color(0xFF0F172A);
  static const _textSecondary = Color(0xFF475569);
  static const _textMuted = Color(0xFF94A3B8);

  static const _gradient1 = [Color(0xFF00C853), Color(0xFF69F0AE)];
  static const _gradient2 = [Color(0xFF667EEA), Color(0xFF764BA2)];
  static const _gradientDark = [Color(0xFF1E293B), Color(0xFF0F172A)];

  // ═══════════════════════════════════════════════════════════════════════════
  // 📦 DATA
  // ═══════════════════════════════════════════════════════════════════════════

  final List<_ServiceItem> _services = [
    _ServiceItem(
      icon: Icons.healing_rounded,
      label: 'Wound Care',
      color: const Color(0xFFE53935),
      bgColor: const Color(0xFFFFEBEE),
      price: 150,
      unit: 'EGP',
      popular: true,
    ),
    _ServiceItem(
      icon: Icons.water_drop_rounded,
      label: 'IV Therapy',
      color: const Color(0xFF1E88E5),
      bgColor: const Color(0xFFE3F2FD),
      price: 200,
      unit: 'EGP',
      popular: false,
    ),
    _ServiceItem(
      icon: Icons.vaccines_rounded,
      label: 'Injections',
      color: const Color(0xFF43A047),
      bgColor: const Color(0xFFE8F5E9),
      price: 50,
      unit: 'EGP',
      popular: true,
    ),
    _ServiceItem(
      icon: Icons.elderly_rounded,
      label: 'Elderly Care',
      color: const Color(0xFF7B1FA2),
      bgColor: const Color(0xFFF3E5F5),
      price: 200,
      unit: '/hr',
      popular: false,
    ),
    _ServiceItem(
      icon: Icons.child_care_rounded,
      label: 'Baby Care',
      color: const Color(0xFFEC407A),
      bgColor: const Color(0xFFFCE4EC),
      price: 180,
      unit: 'EGP',
      popular: false,
    ),
    _ServiceItem(
      icon: Icons.monitor_heart_rounded,
      label: 'Post-Op',
      color: const Color(0xFFFFA726),
      bgColor: const Color(0xFFFFF3E0),
      price: 300,
      unit: 'EGP',
      popular: true,
    ),
  ];

  final List<_NurseItem> _nurses = [
    _NurseItem(
      name: 'Sarah Ahmed',
      specialty: 'Wound Care',
      rating: 4.9,
      reviews: 127,
      isAvailable: true,
      color: const Color(0xFF00C853),
    ),
    _NurseItem(
      name: 'Fatima Hassan',
      specialty: 'Elderly Care',
      rating: 4.8,
      reviews: 98,
      isAvailable: true,
      color: const Color(0xFF9C27B0),
    ),
    _NurseItem(
      name: 'Mona Ibrahim',
      specialty: 'IV Therapy',
      rating: 4.9,
      reviews: 156,
      isAvailable: false,
      color: const Color(0xFF2196F3),
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔄 LIFECYCLE
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initScrollListener();
    _loadUserData();
  }

  void _initAnimations() {
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _fadeIn = CurvedAnimation(parent: _mainController, curve: Curves.easeOut);

    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeOutCubic),
    );

    _mainController.forward();
  }

  void _initScrollListener() {
    _scrollController.addListener(() {
      final scrolled = _scrollController.offset > 50;
      if (scrolled != _isScrolled) {
        setState(() => _isScrolled = scrolled);
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final apiService = ApiService();
      final remoteDataSource = AuthRemoteDataSourceImpl(apiService: apiService);
      final repository = AuthRepositoryImpl(remoteDataSource: remoteDataSource);
      final response = await repository.getCurrentUser();

      if (mounted) {
        setState(() {
          _user = response.user;
          _isLoading = false;
        });

        if (_user?.id != null && _user!.id.isNotEmpty) {
          final storedUserId = await TokenManager.getUserId();
          if (storedUserId == null || storedUserId.isEmpty) {
            await TokenManager.saveUserId(_user!.id);
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Home: Error loading user data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String get _greetingIcon {
    final hour = DateTime.now().hour;
    if (hour < 12) return '☀️';
    if (hour < 17) return '🌤️';
    return '🌙';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🏗️ BUILD
  // ═══════════════════════════════════════════════════════════════════════════

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
          // Background gradient
          _buildBackground(),

          // Main content
          RefreshIndicator(
            onRefresh: _loadUserData,
            color: _primary,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // Header
                SliverToBoxAdapter(child: _buildHeader()),

                // Search Bar
                SliverToBoxAdapter(child: _buildSearchBar()),

                // AI Card
                SliverToBoxAdapter(child: _buildAICard()),

                // Active Booking (conditional)
                if (_hasActiveBooking)
                  SliverToBoxAdapter(child: _buildActiveBooking()),

                // Services Section
                SliverToBoxAdapter(child: _buildServicesHeader()),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: _buildServicesGrid(),
                ),

                // Nurses Section
                SliverToBoxAdapter(child: _buildNursesHeader()),
                SliverToBoxAdapter(child: _buildNursesList()),

                // Premium Card
                SliverToBoxAdapter(child: _buildPremiumCard()),

                // Bottom spacing
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),

          // Floating App Bar (when scrolled)
          if (_isScrolled) _buildFloatingAppBar(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🎨 BACKGROUND
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildBackground() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            // Top gradient blob
            Positioned(
              top: -120,
              right: -80,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, _) {
                  return Transform.scale(
                    scale: 1 + (_pulseController.value * 0.05),
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _primary.withAlpha(25),
                            _primary.withAlpha(0),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Bottom accent
            Positioned(
              bottom: 150,
              left: -60,
              child: Container(
                width: 180,
                height: 180,
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

  // ═══════════════════════════════════════════════════════════════════════════
  // 📱 FLOATING APP BAR
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildFloatingAppBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        opacity: _isScrolled ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            20,
            MediaQuery.of(context).padding.top + 8,
            20,
            12,
          ),
          decoration: BoxDecoration(
            color: _card,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildMiniAvatar(),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Hi, ${_user?.name.split(' ').first ?? 'there'}!',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildHeaderAction(Icons.notifications_outlined, badge: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: _gradient1),
      ),
      child: Center(
        child:
            _user?.name != null
                ? Text(
                  _user!.name[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
                : const Icon(Icons.person, color: Colors.white, size: 18),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🏠 HEADER
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildHeader() {
    return SlideTransition(
      position: _slideUp,
      child: FadeTransition(
        opacity: _fadeIn,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            MediaQuery.of(context).padding.top + 20,
            20,
            16,
          ),
          child: Row(
            children: [
              // Avatar
              _buildAvatar(),
              const SizedBox(width: 14),

              // Greeting
              Expanded(child: _buildGreeting()),

              // Actions
              _buildHeaderAction(Icons.notifications_outlined, badge: 3),
              const SizedBox(width: 10),
              _buildHeaderAction(Icons.location_on_outlined),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return GestureDetector(
      onTap: () => _navigateToProfile(),
      child: Hero(
        tag: 'user_avatar',
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _gradient1,
            ),
            boxShadow: [
              BoxShadow(
                color: _primary.withAlpha(60),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 26,
            backgroundColor: _card,
            child:
                _isLoading
                    ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: _primary,
                      ),
                    )
                    : _user?.name != null
                    ? Text(
                      _user!.name[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _primary,
                      ),
                    )
                    : const Icon(
                      Icons.person_rounded,
                      color: _primary,
                      size: 28,
                    ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _greeting,
              style: const TextStyle(
                fontSize: 14,
                color: _textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Text(_greetingIcon, style: const TextStyle(fontSize: 16)),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          _user?.name.split(' ').first ?? 'Welcome',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: _textPrimary,
            letterSpacing: -0.3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildHeaderAction(IconData icon, {int? badge}) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
      },
      child: Container(
        width: 46,
        height: 46,
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
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: _textSecondary, size: 22),
            if (badge != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF5252), Color(0xFFFF1744)],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: _card, width: 2),
                  ),
                  child: const Center(
                    child: Text(
                      '3',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔍 SEARCH BAR
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: _primary.withAlpha(15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // Search Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_primary.withAlpha(25), _primary.withAlpha(10)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  color: _primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),

              // Text
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Search for services',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Nurses, doctors, tests...',
                      style: TextStyle(fontSize: 12, color: _textMuted),
                    ),
                  ],
                ),
              ),

              // Filter
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: _textSecondary,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🤖 AI CARD
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildAICard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatbotPage()),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _gradient2,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667EEA).withAlpha(80),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              // AI Icon
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(
                        (40 + (_pulseController.value * 20)).toInt(),
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.psychology_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Flexible(
                          child: Text(
                            'AI Health Assistant',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(50),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'NEW',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Get instant health advice',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withAlpha(200),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Arrow
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFF667EEA),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📅 ACTIVE BOOKING
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildActiveBooking() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _primary.withAlpha(50), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: _primary.withAlpha(20),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // Status indicator
              Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, _) {
                      return Container(
                        width: 52 + (_pulseController.value * 6),
                        height: 52 + (_pulseController.value * 6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _primary.withAlpha(
                            (25 * (1 - _pulseController.value)).toInt(),
                          ),
                        ),
                      );
                    },
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: _gradient1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.directions_walk_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _primary.withAlpha(25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'IN PROGRESS',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: _primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Wound Care Service',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: 14,
                          color: _textMuted,
                        ),
                        SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Nurse Sarah • 15 min away',
                            style: TextStyle(fontSize: 12, color: _textMuted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Arrow
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🏥 SERVICES
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildServicesHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Quick Services',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _textPrimary,
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AllNursingServicesPage(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _primary.withAlpha(20),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _primary,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, size: 14, color: _primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesGrid() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildServiceCard(_services[index], index),
        childCount: _services.length,
      ),
    );
  }

  Widget _buildServiceCard(_ServiceItem service, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 80)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 15 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => ServiceDetailsPage(
                    title: service.label,
                    price: '${service.price} ${service.unit}',
                    duration: '30 min',
                    icon: service.icon,
                    iconColor: service.color,
                    description:
                        'Professional ${service.label} service by certified professionals.',
                    includes: const [
                      'Expert care',
                      'Quality equipment',
                      'Follow-up',
                    ],
                  ),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: service.color.withAlpha(15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Popular badge
              if (service.popular)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5252),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF5252).withAlpha(100),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),

              // Content
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: service.bgColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(service.icon, color: service.color, size: 22),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      service.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${service.price}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: service.color,
                            ),
                          ),
                          TextSpan(
                            text: ' ${service.unit}',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color: service.color.withAlpha(180),
                            ),
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

  // ═══════════════════════════════════════════════════════════════════════════
  // 👩‍⚕️ NURSES
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildNursesHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Top Nurses',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _textPrimary,
            ),
          ),
          GestureDetector(
            onTap: () => HapticFeedback.selectionClick(),
            child: const Text(
              'See All',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNursesList() {
    return SizedBox(
      height: 175,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        itemCount: _nurses.length,
        itemBuilder: (context, index) => _buildNurseCard(_nurses[index], index),
      ),
    );
  }

  Widget _buildNurseCard(_NurseItem nurse, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(20 * (1 - value), 0),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: () => HapticFeedback.lightImpact(),
        child: Container(
          width: 130,
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: nurse.color.withAlpha(20),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [nurse.color, nurse.color.withAlpha(150)],
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: _card,
                      child: Icon(
                        Icons.person_rounded,
                        color: nurse.color,
                        size: 24,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: nurse.isAvailable ? _primary : Colors.grey,
                        shape: BoxShape.circle,
                        border: Border.all(color: _card, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Name
              Text(
                nurse.name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Specialty
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: nurse.color.withAlpha(25),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  nurse.specialty,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: nurse.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 6),

              // Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFFFC107),
                    size: 14,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${nurse.rating}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _textPrimary,
                    ),
                  ),
                  Text(
                    ' (${nurse.reviews})',
                    style: const TextStyle(fontSize: 9, color: _textMuted),
                  ),
                ],
              ),

              const Spacer(),

              // Book button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color:
                      nurse.isAvailable ? nurse.color.withAlpha(25) : _surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  nurse.isAvailable ? 'Book' : 'Busy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: nurse.isAvailable ? nurse.color : _textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 💎 PREMIUM CARD
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildPremiumCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: GestureDetector(
        onTap: () => HapticFeedback.mediumImpact(),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _gradientDark,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E293B).withAlpha(100),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.workspace_premium_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'PREMIUM',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Title
                    const Text(
                      'Upgrade to Premium',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Features
                    Text(
                      '• 20% off all services\n• Priority booking',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withAlpha(180),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // CTA
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: _gradient1),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: _primary.withAlpha(100),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Upgrade Now',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Diamond
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, _) {
                  return Transform.rotate(
                    angle: _pulseController.value * 0.08,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFFD700).withAlpha(50),
                            const Color(0xFFFFA000).withAlpha(25),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.diamond_rounded,
                        color: Color(0xFFFFD700),
                        size: 32,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔽 BOTTOM NAV
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildBottomNav() {
    return CustomBottomNavBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        HapticFeedback.selectionClick();
        setState(() => _currentIndex = index);

        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BookingsPage()),
          ).then((_) => setState(() => _currentIndex = 0));
        }
        if (index == 4) {
          _navigateToProfile();
        }
      },
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfilePage()),
    ).then((_) => setState(() => _currentIndex = 0));
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// 📦 DATA CLASSES
// ═══════════════════════════════════════════════════════════════════════════════

class _ServiceItem {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final int price;
  final String unit;
  final bool popular;

  const _ServiceItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.price,
    required this.unit,
    required this.popular,
  });
}

class _NurseItem {
  final String name;
  final String specialty;
  final double rating;
  final int reviews;
  final bool isAvailable;
  final Color color;

  const _NurseItem({
    required this.name,
    required this.specialty,
    required this.rating,
    required this.reviews,
    required this.isAvailable,
    required this.color,
  });
}
