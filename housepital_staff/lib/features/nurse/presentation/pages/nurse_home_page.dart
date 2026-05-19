import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/data/repositories/auth_repository.dart';
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
import '../../../../l10n/app_localizations.dart';

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
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });

        try {
          _mapController.move(_currentLocation!, 15.0);
        } catch (e) {
          debugPrint('Map not ready for initial move');
        }

        _syncSocketPresence();
      }

      _locationStream?.cancel();
      _locationStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 0,
        ),
      ).listen((Position pos) {
        if (mounted) {
          final newLoc = LatLng(pos.latitude, pos.longitude);
          setState(() {
            _currentLocation = newLoc;
          });

          try {
            _mapController.move(newLoc, _mapController.camera.zoom);
          } catch (e) {
            debugPrint('Map not ready for stream move');
          }

          _syncSocketPresence();
        }
      });
    } catch (e) {
      debugPrint('Location stream error: $e');
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
      _syncSocketPresence();
      _refreshBookings('socket:connect');
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

    context.read<NurseBookingCubit>().fetchBookings();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<NurseProfileCubit>().loadProfile();
    context.read<NurseBookingCubit>().fetchBookings();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _initSocket();
    _startFallbackPolling();
    _startPresenceSyncTimer();
    _fetchCurrentLocation();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    final user = context.select((AuthCubit cubit) {
      if (cubit.state is AuthAuthenticated) {
        return (cubit.state as AuthAuthenticated).user;
      }
      return null;
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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

          return BlocConsumer<NurseBookingCubit, NurseBookingState>(
            listener: (context, bookingState) {
              if (bookingState is NurseBookingError) {
                if (!bookingState.message.toLowerCase().contains('not found')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(bookingState.message),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              } else if (bookingState is NurseBookingActive) {
                if (!_isNavigatingToPin) {
                  _isNavigatingToPin = true;
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
                    context.read<NurseBookingCubit>().fetchBookings();
                  });
                }
              } else if (bookingState is NurseBookingCompleted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Visit completed successfully! 🎉'),
                    backgroundColor: AppColors.primary500,
                  ),
                );
              }
            },
            builder: (context, bookingState) {
              final bool hasActiveVisit =
                  bookingState is NurseBookingInProgress;
              final NurseBooking? activeBooking =
                  bookingState is NurseBookingActive
                      ? bookingState.booking
                      : null;

              return Stack(
                children: [
                  const NurseHomeBackground(),
                  RefreshIndicator(
                    onRefresh: () async {
                      context.read<NurseProfileCubit>().loadProfile();
                      context.read<NurseBookingCubit>().fetchBookings();
                    },
                    color: AppColors.primary500,
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Stack(
                            children: [
                              // Canopy
                              Container(
                                height: 280,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.primary500,
                                      AppColors.secondary500,
                                    ],
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(40),
                                    bottomRight: Radius.circular(40),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      top: -50,
                                      right: -30,
                                      child: Container(
                                        width: 180,
                                        height: 180,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white.withAlpha(20),
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
                                          color: Colors.white.withAlpha(15),
                                        ),
                                      ),
                                    ),
                                    NurseHomeHeader(
                                      user: user,
                                      profile: profile,
                                      onProfileTap:
                                          () => Navigator.pushNamed(
                                            context,
                                            AppRoutes.nurseProfile,
                                          ),
                                    ),
                                  ],
                                ),
                              ),

                              // Content
                              Padding(
                                padding: const EdgeInsets.only(top: 140),
                                child: Transform.translate(
                                  offset: const Offset(0, -20),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (activeBooking != null)
                                          _buildActiveBookingBanner(
                                            context,
                                            activeBooking,
                                          ),

                                        if (!hasActiveVisit) ...[
                                          ProfileStatusBanner(
                                            profile: profile!,
                                            onTap:
                                                () => Navigator.pushNamed(
                                                  context,
                                                  AppRoutes
                                                      .nurseProfileCompletion,
                                                ),
                                          ),
                                          _buildAvailabilityCard(
                                            isOnline,
                                            isApproved,
                                          ),
                                          WorkZoneSnapshot(
                                            workZone: profile.workZone,
                                            onEdit: () {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        l10n.mapEditingSoon,
                                                      ),
                                                    ),
                                                  );
                                            },
                                          ),
                                          const SizedBox(height: 16),
                                        ],

                                        Container(
                                          height: 500,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.surface,
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withAlpha(
                                                  isDark ? 40 : 5,
                                                ),
                                                blurRadius: 20,
                                                offset: const Offset(0, 10),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            child: _buildDynamicContent(
                                              isOnline,
                                              isApproved,
                                              bookingState,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 100),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (!hasActiveVisit)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: QuickAccessDock(
                        onProfileTap:
                            () => Navigator.pushNamed(
                              context,
                              AppRoutes.nurseProfile,
                            ),
                        onWalletTap:
                            () => Navigator.pushNamed(
                              context,
                              AppRoutes.nurseWallet,
                            ),
                        onHistoryTap:
                            () => Navigator.pushNamed(
                              context,
                              AppRoutes.nurseHistory,
                            ),
                        onSettingsTap:
                            () => Navigator.pushNamed(
                              context,
                              AppRoutes.nurseSettings,
                            ),
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
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isNotFound ? Icons.person_add_disabled : Icons.cloud_off_outlined,
              size: 80,
              color: theme.colorScheme.onSurface.withAlpha(50),
            ),
            const SizedBox(height: 24),
            Text(
              isNotFound ? 'Profile Incomplete' : 'Could Not Load Profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isNotFound
                  ? 'Please complete your professional profile to start receiving bookings.'
                  : errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface.withAlpha(150)),
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
        return _buildIncomingRequestView(bookingState.pendingBookings.first);
      }
    }

    if (bookingState is NurseBookingWaitingForPatient) {
      return _buildWaitingForPatientView(bookingState.booking);
    }

    if (bookingState is NurseBookingCompleted) {
      final theme = Theme.of(context);
      final l10n = AppLocalizations.of(context)!;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary50.withAlpha(theme.brightness == Brightness.dark ? 20 : 255),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.primary500,
                size: 80,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.visitCompleted,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Returning to home...',
              style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(150)),
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
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.secondary500, AppColors.secondary700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary500.withAlpha(80),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(40),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                isOnTheWay
                    ? Icons.navigation_rounded
                    : Icons.medical_services_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isOnTheWay ? 'On the Way' : 'Active Booking',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    booking.patientName,
                    style: TextStyle(
                      color: Colors.white.withAlpha(200),
                      fontSize: 12,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityCard(bool isOnline, bool isApproved) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isOnline
                  ? [AppColors.primary500, AppColors.primary700]
                  : [theme.colorScheme.surface, isDark ? AppColors.dark700 : AppColors.light100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: isOnline ? null : Border.all(color: theme.colorScheme.outline.withAlpha(isDark ? 50 : 100)),
        boxShadow: [
          BoxShadow(
            color:
                isOnline
                    ? AppColors.primary500.withAlpha(60)
                    : Colors.black.withAlpha(isDark ? 20 : 5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isOnline ? l10n.online : l10n.offline,
                style: TextStyle(
                  color: isOnline ? Colors.white : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: 'Poppins',
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isOnline ? l10n.visibleToPatients : l10n.goOnlineToStart,
                style: TextStyle(
                  color:
                      isOnline
                          ? Colors.white.withAlpha(200)
                          : theme.colorScheme.onSurface.withAlpha(150),
                  fontSize: 13,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          Switch(
            value: isOnline,
            onChanged:
                isApproved
                    ? (val) {
                      context.read<NurseProfileCubit>().toggleOnlineStatus(val);
                      _syncSocketPresence(isOnlineOverride: val);
                      if (val) {
                        context.read<NurseBookingCubit>().fetchBookings();
                      }
                    }
                    : null,
            activeColor: isOnline ? Colors.white : AppColors.primary500,
            activeTrackColor: isOnline ? Colors.white.withAlpha(60) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildRadarView() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
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
              urlTemplate:
                  isDark 
                    ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'
                    : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
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
                                  color: AppColors.primary500.withAlpha(
                                    (opacity * 0.5 * 255).toInt(),
                                  ),
                                  width: 2,
                                ),
                                color: AppColors.primary500.withAlpha(
                                  (opacity * 0.1 * 255).toInt(),
                                ),
                              ),
                            );
                          },
                        );
                      }),
                      FadeTransition(
                        opacity: _pulseController,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? AppColors.dark600 : AppColors.primary50,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary500.withAlpha(75),
                                blurRadius: 15,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.local_hospital,
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
                  color: theme.colorScheme.surface.withAlpha(240),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(isDark ? 60 : 25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      l10n.scanningPatients,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.requestsAppearAuto,
                      style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(150), fontSize: 12),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Stack(
        children: [
          const NurseHomeBackground(),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.newRequest,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary600,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    l10n.patientWaiting,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withAlpha(150),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  
                  // Concise Card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary900.withAlpha(isDark ? 80 : 20),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primary500,
                                    width: 2,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: theme.colorScheme.primaryContainer.withAlpha(isDark ? 50 : 255),
                                  child: Icon(
                                    Icons.person_rounded,
                                    size: 35,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      booking.patientName,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    Text(
                                      booking.serviceName,
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        color: AppColors.primary600,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _showBookingDetails(booking),
                              icon: const Icon(Icons.info_outline_rounded, size: 18),
                              label: Text(
                                l10n.viewVisitDetails,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: theme.colorScheme.primary,
                                side: BorderSide(color: theme.colorScheme.primary.withAlpha(100)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () {
                                    context.read<NurseBookingCubit>().declineBooking(
                                      booking.id,
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    foregroundColor: AppColors.error,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  child: Text(
                                    l10n.decline,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    gradient: const LinearGradient(
                                      colors: [AppColors.primary600, AppColors.primary400],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary500.withAlpha(60),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      context.read<NurseBookingCubit>().acceptBooking(
                                        booking.id,
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      shadowColor: Colors.transparent,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 18),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ),
                                    child: Text(
                                      l10n.accept,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingDetails(NurseBooking booking) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withAlpha(100),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.visitInfo,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailTile(
              Icons.medical_information_rounded,
              l10n.serviceRequested,
              booking.serviceName,
              AppColors.primary500,
            ),
            const SizedBox(height: 16),
            _buildDetailTile(
              Icons.access_time_filled_rounded,
              l10n.timing,
              booking.isAsap ? l10n.asapRequest : l10n.scheduledVisit,
              AppColors.warning500,
            ),
            if (booking.address != null) ...[
              const SizedBox(height: 16),
              _buildDetailTile(
                Icons.location_on_rounded,
                l10n.location,
                booking.address!.fullAddress,
                AppColors.secondary500,
              ),
            ],
            if (booking.notes != null && booking.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildDetailTile(
                Icons.notes_rounded,
                l10n.patientNotes,
                booking.notes!,
                Colors.blueGrey,
              ),
            ],
            const SizedBox(height: 16),
            _buildDetailTile(
              Icons.payments_rounded,
              l10n.totalEarning,
              '${l10n.egp} ${booking.servicePrice.toStringAsFixed(0)}',
              AppColors.success500,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.onSurface,
                  foregroundColor: theme.colorScheme.surface,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  l10n.close,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile(IconData icon, String label, String value, Color iconColor) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(isDark ? 100 : 255),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withAlpha(isDark ? 50 : 100)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface.withAlpha(150),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingForPatientView(NurseBooking booking) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      color: theme.scaffoldBackgroundColor,
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
              Text(
                l10n.offerAccepted,
                style: const TextStyle(
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
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(isDark ? 40 : 20),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      l10n.waitingPatientConfirm,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.colorScheme.onSurface.withAlpha(200),
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
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
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
                            style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(180)),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
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
              color: AppColors.primary50.withAlpha(isDark ? 40 : 255),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_hospital, color: AppColors.primary600),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.visitInProgress,
                    style: const TextStyle(
                      color: AppColors.primary700,
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
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${duration.inMinutes}m ${duration.inSeconds % 60}s',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.colorScheme.outline.withAlpha(isDark ? 40 : 100)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: theme.colorScheme.primaryContainer.withAlpha(isDark ? 50 : 255),
                      child: Icon(
                        Icons.person,
                        size: 35,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.patientName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            booking.serviceName,
                            style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(150)),
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
                        onPressed: () {},
                      ),
                  ],
                ),
                if (booking.address != null) ...[
                  Divider(height: 24, color: theme.colorScheme.outline.withAlpha(50)),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: theme.colorScheme.onSurface.withAlpha(100),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          booking.address!.fullAddress,
                          style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(150)),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _showCompleteVisitDialog(booking);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(
                l10n.completeVisit,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCompleteVisitDialog(NurseBooking booking) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: theme.colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            title: Text(l10n.confirmCompleteTitle),
            content: Text(l10n.confirmCompleteSub),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.goBack),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.read<NurseBookingCubit>().completeVisit(booking.id);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary600,
                  foregroundColor: Colors.white,
                ),
                child: Text(l10n.accept),
              ),
            ],
          ),
    );
  }

  Widget _buildOfflineView(bool isApproved, bool isOnline) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withAlpha(isDark ? 100 : 255),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.coffee, size: 80, color: theme.colorScheme.onSurface.withAlpha(50)),
          ),
          const SizedBox(height: 24),
          Text(
            isApproved ? 'Resting Mode' : 'Profile Incomplete', // Localization needed? Added to ARB later if needed
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              isApproved
                  ? l10n.goOnlineToStart
                  : 'Please complete your profile verification to start working.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withAlpha(150),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
