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
import 'nurse_tracking_page.dart';
import 'nurse_history_page.dart';
import 'visit_in_progress_page.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../../core/utils/token_manager.dart';
import '../../../../core/constants/api_constants.dart';

class NurseHomePage extends StatefulWidget {
  const NurseHomePage({super.key});

  @override
  State<NurseHomePage> createState() => _NurseHomePageState();
}

class _NurseHomePageState extends State<NurseHomePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _pulseController;
  late AnimationController _rippleController;
  Timer? _pollingTimer;
  Timer? _presenceSyncTimer;
  static const Duration _fallbackPollInterval = Duration(seconds: 10);
  static const Duration _presenceSyncInterval = Duration(seconds: 15);

  bool _isNavigatingToPin = false;
  LatLng? _currentLocation;
  final MapController _mapController = MapController();
  IO.Socket? _socket;
  StreamSubscription<Position>? _locationStream;

  Future<void> _fetchCurrentLocation() async {
    try {
      debugPrint('📍 === LOCATION DEBUG: Starting _fetchCurrentLocation ===');
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      debugPrint('📍 LOCATION DEBUG: Service enabled: $serviceEnabled');
      if (!serviceEnabled) {
        debugPrint('📍 LOCATION DEBUG: Failing because service not enabled');
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('📍 LOCATION DEBUG: Permission status: $permission');
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        debugPrint('📍 LOCATION DEBUG: Requested permission: $permission');
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      // Get initial position
      debugPrint('📍 LOCATION DEBUG: Awaiting initial position...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy:
            LocationAccuracy
                .high, // Changed to high for better emulator response
      );
      debugPrint(
        '📍 LOCATION DEBUG: Initial Position received: ${position.latitude}, ${position.longitude}',
      );
      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });

        try {
          _mapController.move(_currentLocation!, 15.0);
        } catch (e) {
          debugPrint(
            '📍 LOCATION DEBUG: Map not ready yet for initial move, ignoring.',
          );
        }

        _syncSocketPresence();
      }

      // Start continuous GPS stream so location stays fresh
      debugPrint('📍 LOCATION DEBUG: Starting position stream...');
      _locationStream?.cancel();
      _locationStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best, // Changed to best for debugging
          distanceFilter: 0, // Force every update
        ),
      ).listen((Position pos) {
        debugPrint(
          '📍 LOCATION DEBUG: Stream fired! New location: ${pos.latitude}, ${pos.longitude}',
        );
        if (mounted) {
          final newLoc = LatLng(pos.latitude, pos.longitude);
          debugPrint('📍 LOCATION DEBUG: Updating state and MapCenter...');
          setState(() {
            _currentLocation = newLoc;
          });

          try {
            // Also move the map center
            _mapController.move(newLoc, _mapController.camera.zoom);
          } catch (e) {
            debugPrint(
              '📍 LOCATION DEBUG: Map not ready for stream move, ignoring.',
            );
          }

          _syncSocketPresence(); // Push new location to server
        }
      });
    } catch (e) {
      debugPrint('📍 LOCATION DEBUG ERROR: $e');
    }
  }

  void _syncSocketPresence({bool? isOnlineOverride}) {
    if (!mounted || _socket == null || _socket!.connected != true) return;

    final profile = context.read<NurseProfileCubit>().currentProfile;
    final isOnline = isOnlineOverride ?? profile?.isOnline ?? false;

    _socket?.emit('nurse:set_online', isOnline);

    if (isOnline && _currentLocation != null) {
      _socket?.emit('nurse:update_location', {
        'latitude': _currentLocation!.latitude,
        'longitude': _currentLocation!.longitude,
      });
    }
  }

  Future<void> _initSocket() async {
    final token = await TokenManager.getToken();
    if (token == null) return;

    final socketUrl = ApiConstants.baseUrl.replaceAll('/api', '');
    debugPrint('🔌 Nurse socket connecting to $socketUrl');

    _socket = IO.io(
      socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(3000)
          .setAuth({'token': token})
          .build(),
    );

    _socket?.connect();

    _socket?.onConnect((_) {
      debugPrint('✅ Nurse Socket Connected!');
      _syncSocketPresence();
      _refreshBookings('socket:connect');
    });

    _socket?.onDisconnect((_) {
      debugPrint('🔌 Nurse Socket Disconnected');
    });

    _socket?.onConnectError((error) {
      debugPrint('⚠️ Nurse Socket Connect Error: $error');
    });

    _socket?.on('new_booking_request', (data) {
      _refreshBookings('socket:new_booking_request');
    });

    _socket?.on('matching:new_offer', (data) {
      _refreshBookings('socket:matching_new_offer');
    });

    _socket?.on('matching:offer_cancelled', (data) {
      _refreshBookings('socket:matching_offer_cancelled');
    });

    _socket?.on('matching:booking_confirmed', (data) {
      _refreshBookings('socket:matching_booking_confirmed');
    });
  }

  void _startFallbackPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(_fallbackPollInterval, (_) {
      _refreshBookings('polling:fallback');
    });
  }

  void _startPresenceSyncTimer() {
    _presenceSyncTimer?.cancel();
    _presenceSyncTimer = Timer.periodic(_presenceSyncInterval, (_) {
      _syncSocketPresence();
    });
  }

  void _refreshBookings(String source) {
    if (!mounted) return;

    final profile = context.read<NurseProfileCubit>().currentProfile;
    if (profile?.isOnline != true) return;

    debugPrint('Refreshing nurse bookings from $source');
    context.read<NurseBookingCubit>().fetchBookings();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    _initSocket();
    _startFallbackPolling();
    _startPresenceSyncTimer();
    _fetchCurrentLocation();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Reload profile when app resumes (e.g., returning from profile completion page)
    if (state == AppLifecycleState.resumed) {
      if (mounted) {
        context.read<NurseProfileCubit>().loadProfile();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseController.dispose();
    _rippleController.dispose();
    _pollingTimer?.cancel();
    _presenceSyncTimer?.cancel();
    _locationStream?.cancel();
    _socket?.disconnect();
    _socket?.dispose();
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
          } else if (state is NurseProfileLoaded) {
            _syncSocketPresence();
          } else if (state is NurseProfileUpdated) {
            _syncSocketPresence();
          }
        },
        builder: (context, profileState) {
          if (profileState is NurseProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          NurseProfile? profile;
          if (profileState is NurseProfileLoaded) {
            profile = profileState.profile;
          } else if (profileState is NurseProfileUpdated) {
            profile = profileState.profile;
          } else {
            profile = context.read<NurseProfileCubit>().currentProfile;
          }

          if (profile == null) {
            String errorMsg =
                profileState is NurseProfileError
                    ? profileState.message
                    : 'Unable to connect to the server';
            return _buildErrorView(errorMsg);
          }
          final bool isApproved =
              profile.profileStatus == 'approved' ||
              profile.verificationStatus == 'approved';
          final bool isOnline = profile.isOnline;

          // Debug: Print profile status
          debugPrint(
            '🔍 Profile Status: ${profile.profileStatus}, isApproved: $isApproved',
          );

          return BlocConsumer<NurseBookingCubit, NurseBookingState>(
            listener: (context, bookingState) {
              if (bookingState is NurseBookingError) {
                // Do not show an error snackbar if the profile is not found
                if (!bookingState.message.toLowerCase().contains('not found')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(bookingState.message),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              } else if (bookingState is NurseBookingActive) {
                // Prevents multiple pages from opening sequentially
                if (!_isNavigatingToPin) {
                  _isNavigatingToPin = true;
                  // Always go to the tracking page — the tracking page shows
                  // the PIN entry button when status == 'arrived'.
                  // We do NOT push PinVerificationPage from here to avoid
                  // double-navigation (tracking page would also push it).
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              NurseTrackingPage(booking: bookingState.booking),
                    ),
                  ).then((_) {
                    if (mounted) setState(() => _isNavigatingToPin = false);
                  });
                }
              } else if (bookingState is NurseBookingInProgress) {
                // Visit is in progress (e.g. app restarted during visit)
                if (!_isNavigatingToPin) {
                  _isNavigatingToPin = true;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => VisitInProgressPage(
                            booking: bookingState.booking,
                          ),
                    ),
                  ).then((_) {
                    if (!mounted) return;
                    setState(() => _isNavigatingToPin = false);
                    // Refresh bookings after returning from visit
                    context.read<NurseBookingCubit>().fetchBookings();
                  });
                }
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
              // Active = assigned/on-the-way booking nurse can resume
              final NurseBooking? activeBooking =
                  bookingState is NurseBookingActive
                      ? bookingState.booking
                      : null;

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
                        color: AppColors.primary100.withValues(alpha: 0.3),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 100,
                            color: AppColors.primary100.withValues(alpha: 0.2),
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

                        // ── Active booking banner (nurse pressed back from map) ──
                        if (activeBooking != null)
                          _buildActiveBookingBanner(context, activeBooking),

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
                                  color: Colors.grey.withValues(alpha: 0.05),
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

  Widget _buildErrorView(String errorMessage) {
    final bool isNotFound = errorMessage.toLowerCase().contains('not found');
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isNotFound ? Icons.person_add_disabled : Icons.cloud_off_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              isNotFound ? 'Profile Incomplete' : 'Could Not Load Profile',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isNotFound
                  ? 'Please complete your professional profile to start receiving bookings.'
                  : errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                if (isNotFound) {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.nurseProfileCompletion,
                  );
                } else {
                  context.read<NurseProfileCubit>().loadProfile();
                }
              },
              icon: Icon(isNotFound ? Icons.edit_document : Icons.refresh),
              label: Text(isNotFound ? 'Complete Profile' : 'Retry Connection'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary500,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                context.read<AuthCubit>().logout();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: const Text(
                'Logout',
                style: TextStyle(color: AppColors.error),
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
    if (!isOnline) return _buildOfflineView(isApproved, isOnline);

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

    if (bookingState is NurseBookingWaitingForPatient) {
      return _buildWaitingForPatientView(bookingState.booking);
    }

    if (bookingState is NurseBookingCompleted) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.success50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.success500,
                size: 80,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Visit Completed! 🎉',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Great work! Returning to home...',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (bookingState is NurseBookingInProgress) {
      return _buildActiveVisitView(bookingState.booking);
    }

    return _buildRadarView();
  }

  // ── Active booking banner shown when nurse presses back ─────────────────

  Widget _buildActiveBookingBanner(BuildContext context, NurseBooking booking) {
    final bool isOnTheWay = booking.status == 'on-the-way';
    return GestureDetector(
      onTap: () {
        if (!_isNavigatingToPin) {
          _isNavigatingToPin = true;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NurseTrackingPage(booking: booking),
            ),
          ).then((_) {
            if (mounted) setState(() => _isNavigatingToPin = false);
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2664EC), Color(0xFF113AA8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2664EC).withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                isOnTheWay
                    ? Icons.navigation_rounded
                    : Icons.medical_services_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isOnTheWay ? 'On the Way' : 'Active Booking',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    booking.patientName,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Resume →',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
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
                isOnline
                    ? AppColors.primary200
                    : Colors.grey.withValues(alpha: 0.1),
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
                          ? Colors.white.withValues(alpha: 0.9)
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
                        _syncSocketPresence(isOnlineOverride: val);
                        debugPrint(
                          '🔄 Toggle switch clicked: $val, isApproved: $isApproved',
                        );
                        if (val) {
                          context.read<NurseBookingCubit>().fetchBookings();
                        }
                      }
                      : null,
              activeColor: Colors.white,
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.grey.shade200,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadarView() {
    final profileCubitState = context.read<NurseProfileCubit>().state;
    double centerLat = 30.0444;
    double centerLng = 31.2357;

    if (_currentLocation != null) {
      centerLat = _currentLocation!.latitude;
      centerLng = _currentLocation!.longitude;
    } else if (profileCubitState is NurseProfileLoaded) {
      final workZone = profileCubitState.profile.workZone;
      if (workZone != null && workZone.latitude != 0.0) {
        centerLat = workZone.latitude;
        centerLng = workZone.longitude;
      }
    }

    return Stack(
      children: [
        // Map Background
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: LatLng(centerLat, centerLng),
            initialZoom: 15.0,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              // Minimal light map without 3D buildings
              urlTemplate:
                  'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.housepital.staff',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(centerLat, centerLng),
                  width: 300,
                  height: 300,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Pulsing Rings
                      ...List.generate(3, (index) {
                        return AnimatedBuilder(
                          animation: _rippleController,
                          builder: (context, child) {
                            double progress =
                                (_rippleController.value + (index * 0.33)) %
                                1.0;
                            double size = 50 + (progress * 250);
                            double opacity = (1.0 - progress).clamp(0.0, 1.0);
                            return Container(
                              width: size,
                              height: size,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary500.withValues(
                                    alpha: opacity * 0.5,
                                  ),
                                  width: 2,
                                ),
                                color: AppColors.primary500.withValues(
                                  alpha: opacity * 0.1,
                                ),
                              ),
                            );
                          },
                        );
                      }),
                      // Center Pin
                      FadeTransition(
                        opacity: _pulseController,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary50.withValues(alpha: 0.9),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary500.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 15,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons
                                .local_hospital, // Updated shape for map marker
                            size: 40,
                            color: AppColors.primary500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        // Overlay scanning text
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Scanning for patients nearby...',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Requests will appear automatically',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
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
                              context.read<NurseBookingCubit>().declineBooking(
                                booking.id,
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: AppColors.error),
                              foregroundColor: AppColors.error,
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
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              backgroundColor: AppColors.primary500,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
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

  Widget _buildWaitingForPatientView(NurseBooking booking) {
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
              const SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primary500,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'OFFER ACCEPTED',
                style: TextStyle(
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary600,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Waiting for patient confirmation...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.person,
                          color: AppColors.primary500,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            booking.patientName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.medical_services,
                          color: AppColors.primary500,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            booking.serviceName,
                            style: TextStyle(color: Colors.grey[800]),
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.success50,
              borderRadius: BorderRadius.circular(20),
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
                  borderRadius: BorderRadius.circular(24),
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

  Widget _buildOfflineView(bool isApproved, bool isOnline) {
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
                  ? 'Toggle the switch above to go online and start receiving requests.'
                  : 'Please complete your profile verification to start working.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
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
            Icons.history_rounded,
            'History',
            false,
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NurseHistoryPage()),
                ),
          ),
          _dockItem(
            Icons.account_balance_wallet_outlined,
            'Earnings',
            false,
            onTap: () => Navigator.pushNamed(context, AppRoutes.nurseWallet),
          ),
          _dockItem(
            Icons.person_rounded,
            'Profile',
            false,
            onTap: () => Navigator.pushNamed(context, AppRoutes.nurseProfile),
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
      borderRadius: BorderRadius.circular(20),
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
