import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/nurse_profile_cubit.dart';
import '../cubit/nurse_booking_cubit.dart';
import '../../data/models/nurse_profile_model.dart';
import '../../data/models/booking_model.dart';
import '../widgets/nurse_home_widgets.dart';
import 'pin_verification_page.dart';

class NurseHomePage extends StatefulWidget {
  const NurseHomePage({super.key});

  @override
  State<NurseHomePage> createState() => _NurseHomePageState();
}

class _NurseHomePageState extends State<NurseHomePage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rippleController;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    context.read<NurseProfileCubit>().loadProfile();

    // Fetch bookings
    context.read<NurseBookingCubit>().fetchBookings();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Start polling for new bookings every 10 seconds when online
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      final profile = context.read<NurseProfileCubit>().currentProfile;
      if (profile?.isOnline == true) {
        context.read<NurseBookingCubit>().fetchBookings();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rippleController.dispose();
    _pollingTimer?.cancel();
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
        builder: (context, profileState) {
          if (profileState is NurseProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          NurseProfile? profile;
          if (profileState is NurseProfileLoaded)
            profile = profileState.profile;
          else if (profileState is NurseProfileUpdated)
            profile = profileState.profile;
          else
            profile = context.read<NurseProfileCubit>().currentProfile;

          if (profile == null) {
            return _buildErrorView();
          }

          final bool isApproved = profile.profileStatus == 'approved';
          final bool isOnline = profile.isOnline;

          // Debug: Print profile status
          print(
            '🔍 Profile Status: ${profile.profileStatus}, isApproved: $isApproved',
          );

          return BlocConsumer<NurseBookingCubit, NurseBookingState>(
            listener: (context, bookingState) {
              if (bookingState is NurseBookingError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(bookingState.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              } else if (bookingState is NurseBookingActive &&
                  bookingState.needsPinVerification) {
                // Navigate to PIN verification
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            PinVerificationPage(booking: bookingState.booking),
                  ),
                );
              } else if (bookingState is NurseBookingCompleted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Visit completed successfully! 🎉'),
                    backgroundColor: AppColors.success500,
                  ),
                );
              }
            },
            builder: (context, bookingState) {
              final bool hasActiveVisit =
                  bookingState is NurseBookingInProgress;

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

                        // Availability (Hide during active visit)
                        if (!hasActiveVisit)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                if (!isApproved)
                                  ProfileStatusBanner(
                                    profile: profile!,
                                    onTap:
                                        () => Navigator.pushNamed(
                                          context,
                                          AppRoutes.nurseProfileCompletion,
                                        ),
                                  ),
                                const SizedBox(height: 10),
                                _buildAvailabilityCard(isOnline, isApproved),
                              ],
                            ),
                          ),

                        if (!hasActiveVisit) const SizedBox(height: 10),

                        if (!hasActiveVisit)
                          WorkZoneSnapshot(
                            workZone: profile!.workZone ?? WorkZone(),
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
                              child: _buildDynamicContent(
                                isOnline,
                                isApproved,
                                bookingState,
                              ),
                            ),
                          ),
                        ),

                        // Bottom Dock (Hide if Active Visit)
                        if (!hasActiveVisit) _buildBottomDock(context),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            const Text(
              'Could Not Load Profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Unable to connect to the server',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                context.read<NurseProfileCubit>().loadProfile();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry Connection'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary500,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicContent(
    bool isOnline,
    bool isApproved,
    NurseBookingState bookingState,
  ) {
    if (!isOnline) return _buildOfflineView(isApproved);

    if (bookingState is NurseBookingLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (bookingState is NurseBookingIdle) {
      if (bookingState.pendingBookings.isEmpty) {
        return _buildRadarView();
      } else {
        // Show incoming request
        return _buildIncomingRequestView(bookingState.pendingBookings.first);
      }
    }

    if (bookingState is NurseBookingInProgress) {
      return _buildActiveVisitView(bookingState.booking);
    }

    return _buildRadarView();
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

  Widget _buildAvailabilityCard(bool isOnline, bool isApproved) {
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
                  isApproved
                      ? (val) {
                        context.read<NurseProfileCubit>().toggleOnlineStatus(
                          val,
                        );
                        print(
                          '🔄 Toggle switch clicked: $val, isApproved: $isApproved',
                        );
                        if (val) {
                          context.read<NurseBookingCubit>().fetchBookings();
                        }
                      }
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
              const SizedBox(height: 8),
              Text(
                'Requests will appear automatically',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIncomingRequestView(NurseBooking booking) {
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
                      radius: 30,
                      child: const Icon(
                        Icons.person,
                        color: Colors.grey,
                        size: 35,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      booking.patientName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (booking.patientPhone != null)
                      Text(
                        booking.patientPhone!,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    const Divider(height: 24),
                    _infoRow(Icons.medical_services, booking.serviceName),
                    const SizedBox(height: 10),
                    _infoRow(
                      Icons.access_time,
                      booking.isAsap ? 'ASAP Request' : 'Scheduled',
                    ),
                    if (booking.address != null) ...[
                      const SizedBox(height: 10),
                      _infoRow(Icons.location_on, booking.address!.fullAddress),
                    ],
                    if (booking.notes != null && booking.notes!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _infoRow(Icons.message, booking.notes!),
                    ],
                    const SizedBox(height: 10),
                    _infoRow(
                      Icons.attach_money,
                      'EGP ${booking.servicePrice.toStringAsFixed(0)}',
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              context
                                  .read<NurseBookingCubit>()
                                  .declineBooking();
                            },
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
                            onPressed: () {
                              context.read<NurseBookingCubit>().acceptBooking(
                                booking.id,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: AppColors.primary500,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Accept'),
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
      ),
    );
  }

  Widget _buildActiveVisitView(NurseBooking booking) {
    final duration =
        booking.visitStartedAt != null
            ? DateTime.now().difference(booking.visitStartedAt!)
            : Duration.zero;

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
            child: Row(
              children: [
                const Icon(Icons.local_hospital, color: AppColors.success600),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Visit In Progress',
                    style: TextStyle(
                      color: AppColors.success700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${duration.inMinutes}m ${duration.inSeconds % 60}s',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.success700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Patient Info
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primary50,
                      child: const Icon(
                        Icons.person,
                        size: 35,
                        color: AppColors.primary500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.patientName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            booking.serviceName,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    if (booking.patientPhone != null)
                      IconButton(
                        icon: const Icon(
                          Icons.phone,
                          color: AppColors.primary500,
                        ),
                        onPressed: () {
                          // TODO: Call patient
                        },
                      ),
                  ],
                ),
                if (booking.address != null) ...[
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          booking.address!.fullAddress,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const Spacer(),

          // Complete Visit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _showCompleteVisitDialog(booking);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success500,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Complete Visit',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCompleteVisitDialog(NurseBooking booking) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Complete Visit?'),
            content: const Text(
              'Are you sure you want to mark this visit as complete? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.read<NurseBookingCubit>().completeVisit(booking.id);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success500,
                ),
                child: const Text('Complete'),
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
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
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
