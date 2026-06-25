import 'package:flutter/material.dart';

import '../../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../../auth/data/datasources/auth_remote_datasource.dart';
import '../../../../../core/network/api_service.dart';
import '../../../../auth/data/models/user_model.dart';

import 'home_background_widget.dart';
import 'home_floating_app_bar.dart';
import 'home_header_widget.dart';
import 'home_news_offers_carousel.dart';
import 'home_wallet_card.dart';
import 'home_quick_actions.dart';
import 'home_ai_card.dart';
import 'home_upcoming_booking.dart';
import 'home_search_bar.dart';

class HomeTabView extends StatefulWidget {
  final VoidCallback? onProfileTap;

  const HomeTabView({
    super.key,
    this.onProfileTap,
  });

  @override
  State<HomeTabView> createState() => _HomeTabViewState();
}

class _HomeTabViewState extends State<HomeTabView> with TickerProviderStateMixin {
  UserModel? _user;
  bool _isLoading = true;
  bool _hasActiveBooking = false;
  Map<String, dynamic>? _activeBooking;

  late AnimationController _mainController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initScrollListener();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadUserData(),
      _fetchActiveBooking(),
    ]);
  }

  void _initAnimations() {
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

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
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final authRepository = AuthRepositoryImpl(
        remoteDataSource: AuthRemoteDataSourceImpl(apiService: ApiService()),
      );

      final response = await authRepository.getCurrentUser();
      if (mounted) {
        setState(() {
          _user = response.user; // Always use latest to get updated wallet balance
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchActiveBooking() async {
    try {
      final apiService = ApiService();
      final bookingResponse = await apiService.get('/api/bookings/my-bookings');
      
      final fetchedBookings = bookingResponse is List 
          ? bookingResponse 
          : (bookingResponse['bookings'] ?? []) as List;

      final active = fetchedBookings.firstWhere(
        (b) {
          final status = (b['status'] ?? '').toString().toLowerCase();
          return ['in-progress', 'confirmed', 'on-the-way'].contains(status);
        },
        orElse: () => null,
      );

      if (mounted) {
        setState(() {
          if (active != null) {
            _activeBooking = Map<String, dynamic>.from(active);
            _hasActiveBooking = true;
          } else {
            _hasActiveBooking = false;
          }
        });
      }
    } catch (e) {
      // Fallback to mock if needed or just silent fail
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        // 1. Background
        const HomeBackgroundWidget(),

        // 2. Main Content
        RefreshIndicator(
          onRefresh: _loadData,
          color: theme.colorScheme.primary,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeIn,
                  child: SlideTransition(
                    position: _slideUp,
                    child: Stack(
                      children: [
                        // 1. The Canopy (Background Header)
                        Container(
                          height: 280, // Fixed height for overlap effect
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF16151A) : null,
                            gradient: isDark ? null : LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.secondary,
                              ],
                            ),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(40),
                              bottomRight: Radius.circular(40),
                            ),
                            boxShadow: isDark 
                              ? [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withAlpha(20),
                                    blurRadius: 60,
                                    spreadRadius: 20,
                                    offset: const Offset(0, -20),
                                  )
                                ]
                              : null,
                          ),
                          child: Stack(
                            children: [
                              // Decorative background elements for "spirit"
                              Positioned(
                                top: -50,
                                right: -30,
                                child: Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withAlpha(isDark ? 10 : 20),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: -60,
                                left: -40,
                                child: Container(
                                  width: 240,
                                  height: 240,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withAlpha(isDark ? 5 : 15),
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  HomeHeaderWidget(
                                    user: _user,
                                    isLoading: _isLoading,
                                    onProfileTap: widget.onProfileTap,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // 2. The Overlapping Grid Body
                        Padding(
                          padding: const EdgeInsets.only(top: 140), // Push content down below the 280px header
                          child: Transform.translate(
                            offset: const Offset(0, -20), // Pull up slightly for depth
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const HomeSearchBar(),
                                const SizedBox(height: 16),
                                HomeUpcomingBooking(
                                  hasActiveBooking: _hasActiveBooking,
                                  booking: _activeBooking,
                                ),
                                HomeWalletCard(user: _user),
                                const HomeQuickActions(),
                                const SizedBox(height: 20),
                                const HomeAICard(),
                                const HomeNewsOffersCarousel(),
                                const SizedBox(height: 100), // Bottom padding for nav bar
                              ],
                            ),
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

        // 3. Floating App Bar (appears on scroll)
        HomeFloatingAppBar(
          isScrolled: _isScrolled,
          user: _user,
        ),
      ],
    );
  }
}
