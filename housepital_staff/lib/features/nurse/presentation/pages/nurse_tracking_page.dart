import 'dart:async';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../../../../core/constants/app_colors.dart';
import '../../data/models/booking_model.dart';
import '../cubit/nurse_booking_cubit.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/token_manager.dart';
import 'pin_verification_page.dart';

class NurseTrackingPage extends StatefulWidget {
  final NurseBooking booking;

  const NurseTrackingPage({super.key, required this.booking});

  @override
  State<NurseTrackingPage> createState() => _NurseTrackingPageState();
}

class _NurseTrackingPageState extends State<NurseTrackingPage>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();

  LatLng? _currentLocation;
  LatLng? _patientLocation;
  Timer? _trackingTimer;
  StreamSubscription<Position>? _positionStream;
  bool _isTrackingStarted = false;

  List<LatLng> _routePoints = [];
  bool _isLoading = true;
  double? _distance;
  double? _duration;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _patientLocation = LatLng(
      widget.booking.address?.lat ?? 30.0444,
      widget.booking.address?.lng ?? 31.2357,
    );
    _initLocation();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _stopLiveTracking();
    super.dispose();
  }

  String _formatDuration(double seconds) {
    int minutes = (seconds / 60).ceil();
    if (minutes < 60) return '$minutes min';
    int hours = minutes ~/ 60;
    int remainingMinutes = minutes % 60;
    return '${hours}h ${remainingMinutes}m';
  }

  String _formatDistance(double meters) {
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  void _startLiveTracking() async {
    if (_isTrackingStarted) return;
    _isTrackingStarted = true;

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 1,
      ),
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });
      }
    });

    _trackingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_currentLocation != null) {
        await _fetchRoute();
        await _updateLocationOnServer(
          _currentLocation!.latitude,
          _currentLocation!.longitude,
        );
      }
    });
  }

  void _stopLiveTracking() {
    _isTrackingStarted = false;
    _positionStream?.cancel();
    _trackingTimer?.cancel();
  }

  Future<void> _updateLocationOnServer(double lat, double lng) async {
    try {
      final token = await TokenManager.getToken();
      if (token == null) return;

      final url =
          '${ApiConstants.baseUrl}/bookings/${widget.booking.id}/location';
      await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'latitude': lat, 'longitude': lng}),
      );
    } catch (e) {
      debugPrint('Failed to update location on server: $e');
    }
  }

  Future<void> _initLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

      await _fetchRoute();

      setState(() {
        _isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fitBounds();
      });
    }
  }

  Future<void> _fetchRoute() async {
    if (_currentLocation != null && _patientLocation != null) {
      final url =
          'https://router.project-osrm.org/route/v1/driving/${_currentLocation!.longitude},${_currentLocation!.latitude};${_patientLocation!.longitude},${_patientLocation!.latitude}?geometries=geojson';
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['routes'] != null && data['routes'].isNotEmpty) {
            final route = data['routes'][0];
            final geometry = route['geometry'];
            final coords = geometry['coordinates'] as List;
            if (mounted) {
              setState(() {
                _routePoints = coords.map((c) => LatLng(c[1], c[0])).toList();
                _distance = (route['distance'] as num?)?.toDouble();
                _duration = (route['duration'] as num?)?.toDouble();
              });
            }
          }
        }
      } catch (e) {
        debugPrint('Error fetching route: $e');
      }
    }
  }

  void _fitBounds() {
    if (_currentLocation != null && _patientLocation != null) {
      final bounds = LatLngBounds.fromPoints([
        _currentLocation!,
        _patientLocation!,
      ]);
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(80)),
      );
    }
  }

  void _updateStatus(String newStatus) {
    if (newStatus == 'on-the-way') {
      _startLiveTracking();
    } else if (newStatus == 'arrived') {
      _stopLiveTracking();
    }
    context.read<NurseBookingCubit>().updateBookingStatus(
      widget.booking.id,
      newStatus,
    );
    // Navigation to PIN page is handled by NurseHomePage's BlocConsumer
    // when it sees NurseBookingActive with needsPinVerification: true.
    // Do NOT push here to avoid double-navigation.
  }

  Widget _buildActionButton(String status) {
    String text;
    Color color;
    VoidCallback onPressed;
    IconData icon;

    if (status == 'assigned') {
      text = 'Start Journey';
      color = AppColors.primary;
      icon = Icons.navigation_rounded;
      onPressed = () => _updateStatus('on-the-way');
    } else if (status == 'on-the-way') {
      text = 'I\'ve Arrived';
      color = AppColors.warning;
      icon = Icons.location_on_rounded;
      onPressed = () => _updateStatus('arrived');
    } else {
      text = 'Enter Patient PIN';
      color = AppColors.success;
      icon = Icons.pin_rounded;
      onPressed = () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PinVerificationPage(booking: widget.booking),
          ),
        );
      };
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NurseBookingCubit, NurseBookingState>(
      builder: (context, state) {
        NurseBooking currentBooking = widget.booking;
        if (state is NurseBookingActive &&
            state.booking.id == widget.booking.id) {
          currentBooking = state.booking;
        } else if (state is NurseBookingInProgress &&
            state.booking.id == widget.booking.id) {
          currentBooking = state.booking;
        }

        final status = currentBooking.status;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              if (_currentLocation != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.my_location, color: AppColors.primary),
                      onPressed: _fitBounds,
                    ),
                  ),
                ),
            ],
          ),
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : Stack(
                  children: [
                    // Map Layer
                    Positioned.fill(
                      bottom: 0, 
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _currentLocation ?? _patientLocation!,
                          initialZoom: 15.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.housepital.staff',
                          ),
                          if (_routePoints.isNotEmpty)
                            PolylineLayer(
                              polylines: <Polyline<Object>>[
                                Polyline(
                                  points: _routePoints,
                                  color: AppColors.primary,
                                  strokeWidth: 5.0,
                                  strokeJoin: StrokeJoin.round,
                                  strokeCap: StrokeCap.round,
                                ),
                              ],
                            ),
                          MarkerLayer(
                            markers: [
                              // Patient Marker
                              if (_patientLocation != null)
                                Marker(
                                  point: _patientLocation!,
                                  width: 120,
                                  height: 120,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: AppColors.textPrimary,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.1),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: const Text(
                                          'Patient',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Icon(
                                        Icons.location_on,
                                        color: AppColors.warning,
                                        size: 40,
                                      ),
                                    ],
                                  ),
                                ),
                              // Nurse Marker
                              if (_currentLocation != null)
                                Marker(
                                  point: _currentLocation!,
                                  width: 60,
                                  height: 60,
                                  child: AnimatedBuilder(
                                    animation: _pulseAnimation,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: _pulseAnimation.value,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.primary
                                                .withValues(alpha: 0.2),
                                            border: Border.all(
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.5),
                                              width: 2,
                                            ),
                                          ),
                                          child: Center(
                                            child: Container(
                                              width: 20,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppColors.primary,
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 3,
                                                ),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: AppColors.primary,
                                                    blurRadius: 8,
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Bottom Panel Layer
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(32),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 24,
                              offset: const Offset(0, -8),
                            ),
                          ],
                        ),
                        child: SafeArea(
                          top: false,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Drag Handle Indicator
                                Container(
                                  width: 48,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: AppColors.light600,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Trip Stats
                                if (_distance != null && _duration != null)
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary50,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppColors.primary.withValues(alpha: 0.1),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _buildStatItem(
                                          Icons.access_time_filled,
                                          _formatDuration(_duration!),
                                          'Est. Time',
                                        ),
                                        Container(
                                          width: 1,
                                          height: 40,
                                          color: AppColors.primary.withValues(alpha: 0.2),
                                        ),
                                        _buildStatItem(
                                          Icons.route,
                                          _formatDistance(_distance!),
                                          'Distance',
                                        ),
                                      ],
                                    ),
                                  ),

                                if (_distance != null && _duration != null)
                                  const SizedBox(height: 24),

                                // Patient Information
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundColor: AppColors.secondary50,
                                      child: Text(
                                        currentBooking.patientName.isNotEmpty
                                            ? currentBooking.patientName[0]
                                                .toUpperCase()
                                            : 'P',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.secondary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            currentBooking.patientName,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            currentBooking.serviceName,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              color: AppColors.textSecondary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (currentBooking.patientPhone != null &&
                                        currentBooking.patientPhone!.isNotEmpty)
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.success50,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: AppColors.success
                                                  .withValues(alpha: 0.2)),
                                        ),
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.phone_in_talk,
                                            color: AppColors.success,
                                          ),
                                          onPressed: () async {
                                            final Uri uri = Uri(
                                              scheme: 'tel',
                                              path: currentBooking.patientPhone,
                                            );
                                            if (await canLaunchUrl(uri)) {
                                              await launchUrl(uri);
                                            } else {
                                              if (mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Could not launch phone dialer'),
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                  ],
                                ),

                                const SizedBox(height: 32),

                                // Action Button
                                SizedBox(
                                  width: double.infinity,
                                  child: _buildActionButton(status),
                                ),
                              ],
                            ),
                          ),

                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
