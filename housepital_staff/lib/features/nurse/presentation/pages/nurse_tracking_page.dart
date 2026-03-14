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
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/token_manager.dart';
import 'pin_verification_page.dart';

class NurseTrackingPage extends StatefulWidget {
  final NurseBooking booking;

  const NurseTrackingPage({super.key, required this.booking});

  @override
  State<NurseTrackingPage> createState() => _NurseTrackingPageState();
}

class _NurseTrackingPageState extends State<NurseTrackingPage> {
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

  String _formatDuration(double seconds) {
    int minutes = (seconds / 60).ceil();
    if (minutes < 60) return '$minutes mins';
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

    // Listen to continuous position updates with high accuracy
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 1, // Wakes up if moved 1 meter
      ),
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });
        // We can optionally animate map here
      }
    });

    // Update database and ETA every 5 seconds
    _trackingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_currentLocation != null) {
        await _fetchRoute(); // Updates distance and ETA from OSRM
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
          '${ApiConstants.baseUrl}/api/bookings/${widget.booking.id}/location';
      await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'latitude': lat, 'longitude': lng}),
      );
    } catch (e) {
      print('Failed to update location on server: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _patientLocation = LatLng(
      widget.booking.address?.lat ?? 30.0444,
      widget.booking.address?.lng ?? 31.2357,
    );
    _initLocation();
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

      // Auto-fit map to show both markers
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
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
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

    // Check if arrived to show pin bottom sheet or navigate
    if (newStatus == 'arrived') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PinVerificationPage(booking: widget.booking),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NurseBookingCubit, NurseBookingState>(
      builder: (context, state) {
        // Find the current booking from state
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
          appBar: AppBar(
            title: const Text('Track Visit'),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          body: Column(
            children: [
              Expanded(
                child:
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter:
                                _currentLocation ?? _patientLocation!,
                            initialZoom: 14.0,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.housepital.staff',
                            ),
                            if (_routePoints.isNotEmpty)
                              PolylineLayer(
                                polylines: [
                                  Polyline(
                                    points: _routePoints,
                                    color: AppColors.primary,
                                    strokeWidth: 5.0,
                                  ),
                                ],
                              ),
                            MarkerLayer(
                              markers: [
                                if (_currentLocation != null)
                                  Marker(
                                    point: _currentLocation!,
                                    width: 80,
                                    height: 80,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.primary50.withValues(
                                          alpha: 0.9,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary500
                                                .withValues(alpha: 0.3),
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
                                if (_patientLocation != null)
                                  Marker(
                                    point: _patientLocation!,
                                    width: 100,
                                    height: 100,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(
                                              alpha: 0.7,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Text(
                                            'Patient',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.person_pin_circle,
                                          color: AppColors.warning,
                                          size: 35,
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
              ),

              // Bottom Info Panel
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_distance != null && _duration != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.timer_outlined,
                                  color: AppColors.primary500,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _formatDuration(_duration!),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.primary500,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 1,
                              height: 24,
                              color: AppColors.primary200,
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.route_outlined,
                                  color: AppColors.primary500,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _formatDistance(_distance!),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.primary500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Patient: ${currentBooking.patientName}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Customer: ${currentBooking.customerName}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Service: ${currentBooking.serviceName}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (currentBooking.patientPhone != null &&
                            currentBooking.patientPhone!.isNotEmpty)
                          IconButton(
                            onPressed: () async {
                              final Uri uri = Uri(
                                scheme: 'tel',
                                path: currentBooking.patientPhone,
                              );
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              } else {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Could not launch phone dialer',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            icon: const Icon(
                              Icons.call,
                              color: AppColors.primary500,
                              size: 30,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.primary50,
                              padding: const EdgeInsets.all(12),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Status: ${status.toUpperCase()}',
                      style: TextStyle(
                        color:
                            status == 'arrived'
                                ? AppColors.success500
                                : AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (status == 'assigned')
                      ElevatedButton(
                        onPressed: () => _updateStatus('on-the-way'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text(
                          'Start Journey',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      )
                    else if (status == 'on-the-way')
                      ElevatedButton(
                        onPressed: () => _updateStatus('arrived'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text(
                          'I\'ve Arrived',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      )
                    else if (status == 'arrived')
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => PinVerificationPage(
                                    booking: widget.booking,
                                  ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success500,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text(
                          'Enter Patient PIN',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
