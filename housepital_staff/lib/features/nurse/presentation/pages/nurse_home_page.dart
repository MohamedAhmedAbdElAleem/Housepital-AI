import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/nurse_profile_cubit.dart';
import '../../data/models/nurse_profile_model.dart';
import '../widgets/nurse_home_widgets.dart';

enum NurseHomeTestState { idle, incoming, active }

class NurseHomePage extends StatefulWidget {
  const NurseHomePage({super.key});

  @override
  State<NurseHomePage> createState() => _NurseHomePageState();
}

class _NurseHomePageState extends State<NurseHomePage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rippleController;

  // TESTING STATE
  NurseHomeTestState _testState = NurseHomeTestState.idle;

  @override
  void initState() {
    super.initState();
    context.read<NurseProfileCubit>().loadProfile();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthCubit cubit) {
      if (cubit.state is AuthAuthenticated) {
        return (cubit.state as AuthAuthenticated).user;
      }
      return null;
    });

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: BlocConsumer<NurseProfileCubit, NurseProfileState>(
        listener: (context, state) {
          if (state is NurseProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is NurseProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          NurseProfile? profile;
          if (state is NurseProfileLoaded)
            profile = state.profile;
          else if (state is NurseProfileUpdated)
            profile = state.profile;
          else
            profile = context.read<NurseProfileCubit>().currentProfile;

          if (profile == null) {
            return const Center(child: Text('Could not load profile.'));
          }

          final bool isApproved =
              true; // profile.profileStatus == 'approved'; // TEST MODE
          final bool isOnline = profile.isOnline;
          final bool isSwitchEnabled =
              isApproved && _testState == NurseHomeTestState.idle;

          // If user goes offline, reset test state
          if (!isOnline && _testState != NurseHomeTestState.idle) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _testState = NurseHomeTestState.idle);
            });
          }

          return Stack(
            children: [
              // Background
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary100.withOpacity(0.3),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 100,
                        color: AppColors.primary100.withOpacity(0.2),
                      ),
                    ],
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    // Header
                    _buildHeader(context, user?.name ?? 'Nurse'),

                    // Availability (Only show if NOT in active visit to save space)
                    if (_testState != NurseHomeTestState.active)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            // BANNER HIDDEN IN TEST MODE (Since isApproved is forced true)
                            if (!isApproved)
                              ProfileStatusBanner(
                                profile: profile,
                                onTap:
                                    () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.nurseProfileCompletion,
                                    ),
                              ),
                            const SizedBox(height: 10),
                            _buildAvailabilityCard(isOnline, isSwitchEnabled),
                          ],
                        ),
                      ),

                    if (_testState != NurseHomeTestState.active)
                      const SizedBox(height: 10),

                    if (_testState != NurseHomeTestState.active)
                      WorkZoneSnapshot(
                        workZone: profile.workZone ?? WorkZone(),
                        onEdit: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Map Editing Coming Soon'),
                            ),
                          );
                        },
                      ),

                    // Dynamic Workspace
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(top: 20),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, -5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                          child: _buildDynamicContent(isOnline, isApproved),
                        ),
                      ),
                    ),

                    // Bottom Dock (Hide if Active Visit)
                    if (_testState != NurseHomeTestState.active)
                      _buildBottomDock(context),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDynamicContent(bool isOnline, bool isApproved) {
    if (!isOnline) return _buildOfflineView(isApproved);

    // Online Logic
    switch (_testState) {
      case NurseHomeTestState.idle:
        return _buildRadarView();
      case NurseHomeTestState.incoming:
        return _buildIncomingRequestView();
      case NurseHomeTestState.active:
        return _buildActiveVisitView();
    }
  }

  // --- WIDGETS ---

  Widget _buildHeader(BuildContext context, String name) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, ${name.split(' ')[0]} 👋',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Text(
                'Let\'s help some patients today.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityCard(bool isOnline, bool isEnabled) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isOnline
                  ? [AppColors.primary500, AppColors.primary400]
                  : [Colors.white, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color:
                isOnline ? AppColors.primary200 : Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: !isOnline ? Border.all(color: Colors.grey.shade200) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isOnline ? 'YOU ARE ONLINE' : 'YOU ARE OFFLINE',
                style: TextStyle(
                  color: isOnline ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isOnline ? 'Receiving requests...' : 'Go online to start',
                style: TextStyle(
                  color:
                      isOnline
                          ? Colors.white.withOpacity(0.9)
                          : AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          Transform.scale(
            scale: 1.2,
            child: Switch(
              value: isOnline,
              onChanged:
                  isEnabled
                      ? (val) => context
                          .read<NurseProfileCubit>()
                          .toggleOnlineStatus(val)
                      : null,
              activeColor: Colors.white,
              activeTrackColor: Colors.white.withOpacity(0.3),
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.grey.shade200,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadarView() {
    return Stack(
      alignment: Alignment.center,
      children: [
        ...List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _rippleController,
            builder: (context, child) {
              double progress =
                  (_rippleController.value + (index * 0.33)) % 1.0;
              double size = 150 + (progress * 200);
              double opacity = (1.0 - progress).clamp(0.0, 1.0);
              return Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary500.withOpacity(opacity * 0.5),
                    width: 2,
                  ),
                ),
              );
            },
          );
        }),
        FadeTransition(
          opacity: _pulseController,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary50.withOpacity(0.5),
            ),
            child: const Icon(
              Icons.radar,
              size: 60,
              color: AppColors.primary500,
            ),
          ),
        ),
        Positioned(
          bottom: 40,
          child: Column(
            children: [
              const Text(
                'Scanning for patients nearby...',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed:
                    () => setState(
                      () => _testState = NurseHomeTestState.incoming,
                    ),
                icon: const Icon(Icons.bug_report, size: 16),
                label: const Text('Simulate Incoming Request (Test)'),
                style: TextButton.styleFrom(backgroundColor: Colors.grey[100]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIncomingRequestView() {
    return Container(
      color: AppColors.primary50,
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'INCOMING REQUEST',
                style: TextStyle(
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary600,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey[200],
                      radius: 25,
                      child: const Icon(
                        Icons.person,
                        color: Colors.grey,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Sarah Johnson',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      '4.8 ⭐ (12 visits)',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const Divider(height: 20),
                    _infoRow(Icons.location_on, '2.5 km away (10 mins)'),
                    const SizedBox(height: 10),
                    _infoRow(
                      Icons.medical_services,
                      'Wound Dressing & Injection',
                    ),
                    const SizedBox(height: 10),
                    _infoRow(
                      Icons.message,
                      'I need help with post-surgery dressing.',
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed:
                                () => setState(
                                  () => _testState = NurseHomeTestState.idle,
                                ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Colors.red),
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Decline'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                () => setState(
                                  () => _testState = NurseHomeTestState.active,
                                ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: AppColors.primary500,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Accept Visit'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              LinearPercentIndicator(
                animation: true,
                lineHeight: 4.0,
                animationDuration: 30000,
                percent: 1.0,
                progressColor: AppColors.primary500,
                onAnimationEnd: () {},
              ),
              const SizedBox(height: 8),
              const Text(
                'Accept within 30s',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveVisitView() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.directions_car, color: AppColors.success600),
                SizedBox(width: 10),
                Text(
                  'En Route to Patient',
                  style: TextStyle(
                    color: AppColors.success700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map_outlined, size: 50, color: Colors.grey[400]),
                    const SizedBox(height: 10),
                    const Text(
                      'Map View Simulation',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Patient Address', style: TextStyle(color: Colors.grey)),
          const Text(
            '123 Al-Noor St, Cairo',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed:
                () => setState(() => _testState = NurseHomeTestState.idle),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary600,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(56),
            ),
            child: const Text('Complete Visit'),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildOfflineView(bool isApproved) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.coffee, size: 80, color: Colors.grey[300]),
          ),
          const SizedBox(height: 24),
          Text(
            isApproved ? 'Resting Mode' : 'Profile Incomplete',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              isApproved
                  ? 'You are currently offline. Switch on above when you are ready to work.'
                  : 'Please complete your profile verification to start working.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomDock(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _dockItem(Icons.grid_view_rounded, 'Home', true),
          _dockItem(
            Icons.person_outline_rounded,
            'Profile',
            false,
            onTap:
                () => Navigator.pushNamed(
                  context,
                  AppRoutes.nurseProfileCompletion,
                ),
          ),
          _dockItem(Icons.account_balance_wallet_outlined, 'Earnings', false),
          _dockItem(
            Icons.settings_outlined,
            'Settings',
            false,
            onTap: () {
              context.read<AuthCubit>().logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (r) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _dockItem(
    IconData icon,
    String label,
    bool isActive, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary500 : Colors.grey[400],
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? AppColors.primary500 : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
