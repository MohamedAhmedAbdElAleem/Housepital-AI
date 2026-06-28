import 'package:flutter/material.dart';
import '../../../../../generated/l10n/app_localizations.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../../core/services/socket_notification_service.dart';
import '../../../../../core/network/api_service.dart';
import '../../../../../core/constants/app_colors.dart';
import 'booking_invoice_page.dart';

/// Patient-side tracking page.
///
/// Shows a real map with the nurse's live location, status updates,
/// the visit PIN, and nurse info pulled from the actual booking data.
class BookingTrackingPage extends StatefulWidget {
  final Map<String, dynamic> booking;

  const BookingTrackingPage({super.key, required this.booking});

  @override
  State<BookingTrackingPage> createState() => _BookingTrackingPageState();
}

class _BookingTrackingPageState extends State<BookingTrackingPage>
    with TickerProviderStateMixin {
  bool get isDark => Theme.of(context).brightness == Brightness.dark;
  late AnimationController _pulseController;
  late AnimationController _bottomSheetController;
  late MapController _mapController;
  final ApiService _apiService = ApiService();

  Timer? _pollTimer;
  Timer? _routeRefreshTimer;
  Map<String, dynamic> _booking = {};

  // Nurse location for map marker
  LatLng? _nurseLocation;

  // Route data
  List<LatLng> _routePoints = [];
  double? _routeDistance; // meters
  double? _routeDuration; // seconds
  LatLng? _patientLocation;

  bool _userHasInteracted = false;
  bool _hideOverlayCards = false;

  @override
  void initState() {
    super.initState();
    _booking = Map<String, dynamic>.from(widget.booking);

    _mapController = MapController();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: false);

    _bottomSheetController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();

    // Parse patient location from booking address
    _parsePatientLocation();

    // Parse initial nurse location from booking
    _parseNurseLocation(_booking);

    // Listen for real-time nurse location updates
    _setupSocketListeners();

    // Poll booking status every 8 seconds for status changes
    _pollTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      _refreshBooking();
    });

    // Periodically refresh route every 10 seconds (in case nurse location updates)
    _routeRefreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (_nurseLocation != null && _patientLocation != null) {
        _fetchRoute();
      }
    });

    // Initial route fetch after a short delay to let everything settle
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _fetchRoute();
    });
  }

  void _parsePatientLocation() {
    try {
      final address = _booking['address'];
      debugPrint('🗺️ ROUTE DEBUG: _parsePatientLocation called');
      debugPrint('🗺️ ROUTE DEBUG: address = $address');
      if (address != null && address['coordinates'] != null) {
        final coords = address['coordinates']['coordinates'];
        debugPrint('🗺️ ROUTE DEBUG: coords = $coords');
        if (coords is List && coords.length >= 2) {
          _patientLocation = LatLng(
            (coords[1] as num).toDouble(),
            (coords[0] as num).toDouble(),
          );
          debugPrint(
            '🗺️ ROUTE DEBUG: Patient location parsed: $_patientLocation',
          );
        }
      }
    } catch (e) {
      debugPrint('🗺️ ROUTE DEBUG: Error parsing patient location: $e');
    }
    // Default Cairo if no location
    _patientLocation ??= const LatLng(30.0444, 31.2357);
    debugPrint('🗺️ ROUTE DEBUG: Final patient location: $_patientLocation');
  }

  void _parseNurseLocation(Map<String, dynamic> booking) {
    try {
      final nurseLoc = booking['nurseLocation'];
      debugPrint(
        '🗺️ ROUTE DEBUG: _parseNurseLocation called, nurseLoc = $nurseLoc',
      );
      if (nurseLoc != null &&
          nurseLoc['latitude'] != null &&
          nurseLoc['longitude'] != null) {
        final newLoc = LatLng(
          (nurseLoc['latitude'] as num).toDouble(),
          (nurseLoc['longitude'] as num).toDouble(),
        );
        debugPrint('🗺️ ROUTE DEBUG: Nurse location parsed: $newLoc');
        if (_nurseLocation != newLoc) {
          _nurseLocation = newLoc;
          _fetchRoute();
        }
      } else {
        debugPrint('🗺️ ROUTE DEBUG: No nurse location in booking data');
      }
    } catch (e) {
      debugPrint('🗺️ ROUTE DEBUG: Error parsing nurse location: $e');
    }
  }

  void _setupSocketListeners() {
    final socket = SocketNotificationService.instance.socket;
    if (socket == null) return;

    socket.on('nurse_location_update', (data) {
      if (!mounted) return;
      if (data is Map) {
        final lat = data['latitude'] ?? data['lat'];
        final lng = data['longitude'] ?? data['lng'];
        if (lat != null && lng != null) {
          final newLoc = LatLng(
            (lat as num).toDouble(),
            (lng as num).toDouble(),
          );
          setState(() {
            _nurseLocation = newLoc;
          });
          _fetchRoute();
        }
      }
    });

    // Listen for status updates
    socket.on('booking_status_updated', (data) {
      if (!mounted) return;
      _refreshBooking();
    });
  }

  void _removeSocketListeners() {
    final socket = SocketNotificationService.instance.socket;
    if (socket == null) return;
    socket.off('nurse_location_update');
    socket.off('booking_status_updated');
  }

  Future<void> _refreshBooking() async {
    try {
      final bookingId = _booking['_id'] ?? _booking['id'] ?? '';
      if (bookingId.isEmpty) return;

      final response = await _apiService.get('/api/bookings/$bookingId');
      if (response != null && response['booking'] != null && mounted) {
        setState(() {
          _booking = Map<String, dynamic>.from(response['booking']);
          _parseNurseLocation(_booking);
          _fetchRoute();
        });

        // Auto-navigate to invoice when completed
        if (_booking['status'] == 'completed') {
          _pollTimer?.cancel();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => BookingInvoicePage(booking: _booking),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error refreshing booking: $e');
    }
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final latTween = Tween<double>(
      begin: _mapController.camera.center.latitude,
      end: destLocation.latitude,
    );
    final lngTween = Tween<double>(
      begin: _mapController.camera.center.longitude,
      end: destLocation.longitude,
    );
    final zoomTween = Tween<double>(
      begin: _mapController.camera.zoom,
      end: destZoom,
    );

    final controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    final Animation<double> animation = CurvedAnimation(
      parent: controller,
      curve: Curves.fastOutSlowIn,
    );

    controller.addListener(() {
      if (mounted) {
        _mapController.move(
          LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
          zoomTween.evaluate(animation),
        );
      }
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  // --- Route Fetching ---
  Future<void> _fetchRoute() async {
    debugPrint('🗺️ ROUTE DEBUG: _fetchRoute called');
    debugPrint(
      '🗺️ ROUTE DEBUG: nurseLocation=$_nurseLocation, patientLocation=$_patientLocation',
    );
    if (_nurseLocation == null || _patientLocation == null) {
      debugPrint(
        '🗺️ ROUTE DEBUG: SKIPPING - nurse or patient location is null',
      );
      return;
    }
    try {
      final url =
          'https://router.project-osrm.org/route/v1/driving/'
          '${_nurseLocation!.longitude},${_nurseLocation!.latitude};'
          '${_patientLocation!.longitude},${_patientLocation!.latitude}'
          '?geometries=geojson';
      debugPrint('🗺️ ROUTE DEBUG: OSRM URL = $url');
      final response = await http.get(Uri.parse(url));
      debugPrint(
        '🗺️ ROUTE DEBUG: OSRM response status = ${response.statusCode}',
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && (data['routes'] as List).isNotEmpty) {
          final route = data['routes'][0];
          final coords = route['geometry']['coordinates'] as List;
          debugPrint(
            '🗺️ ROUTE DEBUG: Got ${coords.length} route points, distance=${route['distance']}, duration=${route['duration']}',
          );
          if (mounted) {
            setState(() {
              _routePoints =
                  coords.map<LatLng>((c) => LatLng(c[1], c[0])).toList();
              _routeDistance = (route['distance'] as num?)?.toDouble();
              _routeDuration = (route['duration'] as num?)?.toDouble();
            });
            _fitBounds();
          }
        } else {
          debugPrint(
            '🗺️ ROUTE DEBUG: No routes in OSRM response: ${response.body.substring(0, 200)}',
          );
        }
      } else {
        debugPrint(
          '🗺️ ROUTE DEBUG: OSRM error response: ${response.body.substring(0, 200)}',
        );
      }
    } catch (e) {
      debugPrint('🗺️ ROUTE DEBUG ERROR: $e');
    }
  }

  void _fitBounds() {
    if (_userHasInteracted) return;
    if (_nurseLocation != null && _patientLocation != null) {
      final bounds = LatLngBounds.fromPoints([
        _nurseLocation!,
        _patientLocation!,
      ]);
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(80)),
      );
    }
  }

  String _formatDuration(double seconds) {
    final l10n = AppLocalizations.of(context)!;
    int minutes = (seconds / 60).ceil();
    if (minutes < 60) return '$minutes ${l10n.unitMinutes}';
    int hours = minutes ~/ 60;
    int rem = minutes % 60;
    return '${hours}${l10n.unitHours} ${rem}${l10n.unitMinutes}';
  }

  String _formatDistance(double meters) {
    final l10n = AppLocalizations.of(context)!;
    if (meters < 1000) return '${meters.round()} ${l10n.unitMeters}';
    return '${(meters / 1000).toStringAsFixed(1)} ${l10n.unitKilometers}';
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bottomSheetController.dispose();
    _pollTimer?.cancel();
    _routeRefreshTimer?.cancel();
    _removeSocketListeners();
    super.dispose();
  }

  // --- Data Extraction Helpers ---
  String get _status {
    final s = _booking['status'] ?? 'confirmed';
    return s == 'in_progress' ? 'in-progress' : s;
  }

  String get _nurseName => _booking['nurseName'] ?? 'Nurse';
  double get _nurseRating => (_booking['nurseRating'] ?? 0.0).toDouble();
  String? get _nursePhone => _booking['nursePhone'];
  String get _visitPin => _booking['visitPin'] ?? '----';
  String get _serviceName => _booking['serviceName'] ?? 'Service';

  String get _statusLabel {
    final l10n = AppLocalizations.of(context)!;
    switch (_status) {
      case 'assigned':
        return l10n.nurseAssigned;
      case 'on-the-way':
        return l10n.nurseOnTheWay;
      case 'arrived':
        return l10n.nurseHasArrived;
      case 'in-progress':
        return l10n.serviceInProgress;
      default:
        return l10n.trackingTitle;
    }
  }

  String get _statusSubtext {
    final l10n = AppLocalizations.of(context)!;
    switch (_status) {
      case 'assigned':
        return l10n.waitingNurseDesc;
      case 'on-the-way':
        return l10n.nurseHeadingDesc;
      case 'arrived':
        return l10n.nurseOutsideDesc;
      case 'in-progress':
        return l10n.nurseProvidingDesc;
      default:
        return l10n.trackingDesc;
    }
  }

  Color get _statusColor {
    switch (_status) {
      case 'assigned':
        return AppColors.secondary500; // Indigo
      case 'on-the-way':
        return AppColors.info400; // Sky
      case 'arrived':
        return AppColors.warning500; // Amber
      case 'in-progress':
        return AppColors.primary500; // Emerald
      default:
        return AppColors.info500; // Blue
    }
  }

  IconData get _statusIcon {
    switch (_status) {
      case 'assigned':
        return Icons.assignment_ind_rounded;
      case 'on-the-way':
        return Icons.directions_car_rounded;
      case 'arrived':
        return Icons.location_on_rounded;
      case 'in-progress':
        return Icons.medical_services_rounded;
      default:
        return Icons.schedule_rounded;
    }
  }

  void _recenterMap() {
    setState(() {
      _userHasInteracted = false;
    });
    if (_nurseLocation != null && _patientLocation != null) {
      _fitBounds();
    } else {
      final center =
          _nurseLocation ?? _patientLocation ?? const LatLng(30.0444, 31.2357);
      _animatedMapMove(center, 15.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0D0C11) : AppColors.light200, // Slate 50
      body: Stack(
        children: [
          // 1. Map Layer
          _buildMap(),

          // 2. Top Gradient for readability
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: _hideOverlayCards ? -150 : 0,
            left: 0,
            right: 0,
            height: 120,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                ),
              ),
            ),
          ),

          // 3. Top Navigation & Status
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: _hideOverlayCards ? -150 : 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildGlassButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.pop(context),
                    ),
                    _buildGlassStatusChip(),
                    _buildGlassButton(
                      icon: Icons.refresh_rounded,
                      onTap: _refreshBooking,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. Recenter Button
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            right: _hideOverlayCards ? -100 : 16,
            bottom: 340, // Above the bottom sheet
            child: _buildRecenterButton(),
          ),

          // 5. Bottom Tracking Panel
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: _hideOverlayCards ? -600 : 0,
            left: 0,
            right: 0,
            child: _buildAnimatedBottomSheet(),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final center =
        _nurseLocation ?? _patientLocation ?? const LatLng(30.0444, 31.2357);

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: 15,
            onTap: (tapPosition, point) {
              setState(() {
                _hideOverlayCards = !_hideOverlayCards;
              });
            },
            onPositionChanged: (position, hasGesture) {
              if (hasGesture && !_userHasInteracted) {
                setState(() {
                  _userHasInteracted = true;
                });
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: isDark
                  ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'
                  : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.housepital.app',
            ),
            // Route polyline
            if (_routePoints.isNotEmpty)
              PolylineLayer(
                polylines: <Polyline<Object>>[
                  Polyline(
                    points: _routePoints,
                    color: _statusColor.withOpacity(0.8),
                    strokeWidth: 5.0,
                    strokeJoin: StrokeJoin.round,
                    strokeCap: StrokeCap.round,
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                // Patient location marker
                if (_patientLocation != null)
                  Marker(
                    point: _patientLocation!,
                    width: 70,
                    height: 70,
                    child: _buildPatientMarker(),
                  ),
                // Nurse location marker (real-time)
                if (_nurseLocation != null)
                  Marker(
                    point: _nurseLocation!,
                    width: 80,
                    height: 80,
                    child: _buildNurseMarker(),
                  ),
              ],
            ),
          ],
        ),
        // Trip stats overlay
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          top: (_hideOverlayCards || _routeDistance == null || _routeDuration == null || _status != 'on-the-way')
              ? -150
              : MediaQuery.of(context).padding.top + 60,
          left: 16,
          right: 16,
          child: (_routeDistance != null && _routeDuration != null)
              ? _buildTripStats()
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildTripStats() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // ETA
              Icon(
                Icons.access_time_filled_rounded,
                color: _statusColor,
                size: 22,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatDuration(_routeDuration!),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _statusColor,
                    ),
                  ),
                  Text(
                    l10n.estArrival,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.dark400,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Divider
              Container(width: 1, height: 36, color: AppColors.light400),
              const Spacer(),
              // Distance
              Icon(Icons.route_rounded, color: _statusColor, size: 22),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatDistance(_routeDistance!),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _statusColor,
                    ),
                  ),
                  Text(
                    l10n.distance,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.dark400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientMarker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary500,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary500.withOpacity(0.4),
                blurRadius: 12,
                spreadRadius: 2,
                offset: Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: isDark ? const Color(0xFF16151A) : Colors.white,
              width: 2,
            ),
          ),
          child: Icon(
            Icons.home_rounded,
            color: isDark ? const Color(0xFF16151A) : Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF16151A) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            l10n.youLabel,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.dark600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNurseMarker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 1.0 + (_pulseController.value * 0.4);
        final opacity = 1.0 - _pulseController.value;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer pulse
            Transform.scale(
              scale: scale,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _statusColor.withOpacity(opacity * 0.5),
                ),
              ),
            ),
            // Inner circle
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _statusColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? const Color(0xFF16151A) : Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _statusColor.withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.local_hospital_rounded,
                color: isDark ? const Color(0xFF16151A) : Colors.white,
                size: 18,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: isDark ? AppColors.dark700 : Colors.white.withOpacity(0.85),
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Icon(
                icon,
                color: isDark ? const Color(0xFFF2F2F5) : AppColors.dark700,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassStatusChip() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color:
              isDark ? AppColors.dark700 : Colors.white.withOpacity(0.85),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder:
                    (context, _) => Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            _statusColor.withOpacity(
                                  0.4 + (1 - _pulseController.value) * 0.6,
                                ),
                        boxShadow: [
                          BoxShadow(
                            color: _statusColor.withOpacity(0.4),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
              ),
              const SizedBox(width: 8),
              Text(
                _statusLabel,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _statusColor,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecenterButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FloatingActionButton(
      heroTag: 'recenter_btn',
      backgroundColor: isDark ? AppColors.customerColor : Colors.white,
      mini: true,
      elevation: 4,
      onPressed: _recenterMap,
      child: Icon(
        Icons.my_location_rounded,
        color: AppColors.dark300, // Slate 600
        size: 22,
      ),
    );
  }

  Widget _buildAnimatedBottomSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SlideTransition(
      position: Tween<Offset>(begin: Offset(0, 1), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _bottomSheetController,
          curve: Curves.easeOutQuart,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF16151A) : Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 24,
              spreadRadius: 0,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Drag Indicator (Cosmetic)
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.light400, // Slate 200
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                child: Column(
                  children: [
                    // Status Header Card
                    _buildStatusHeaderCard(),

                    const SizedBox(height: 20),

                    // Dynamic Section (PIN or In-Progress Notice)
                    if (_status != 'in-progress')
                      _buildPinCard()
                    else
                      _buildInProgressNotice(),

                    const SizedBox(height: 20),

                    // Divider
                    Container(
                      height: 1,
                      color: AppColors.light200, // Slate 100
                    ),

                    const SizedBox(height: 20),

                    // Nurse Info Section
                    _buildNurseInfoSection(),

                    const SizedBox(height: 20),

                    // SOS & Report Buttons
                    _buildActionButtonsRow(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusHeaderCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _statusColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _statusColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16151A) : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _statusColor.withOpacity(0.15),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(_statusIcon, color: _statusColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _statusLabel,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _statusColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _statusSubtext,
                  style: TextStyle(
                    fontSize: 13,
                    color:
                        isDark
                            ? const Color(0xFFA19EAB)
                            : AppColors.dark200, // Slate 500
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color:
            isDark ? const Color(0xFF16151A) : AppColors.light100, // Slate 50
        border: Border.all(
          color:
              isDark
                  ? const Color(0xFF27272A)
                  : AppColors.light400, // Slate 200
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.security_rounded,
                    size: 16,
                    color: isDark ? const Color(0xFFF2F2F5) : AppColors.dark700,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.visitStartCode,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color:
                          isDark
                              ? const Color(0xFFF2F2F5)
                              : AppColors.dark700, // Slate 900
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                l10n.provideStartCodeDesc,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? const Color(0xFFA19EAB) : AppColors.dark200,
                  height: 1.3,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              // gradient: LinearGradient(
              //   colors: [
              //     isDark ? AppColors.light100 : AppColors.light100,
              //     AppColors.light100  ,
              //   ],
              //   begin: Alignment.topLeft,
              //   end: Alignment.bottomRight,
              // ),
              color: AppColors.customerColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color:
                      isDark
                          ? AppColors.customerColor
                          : AppColors.dark700.withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              _visitPin,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
                fontFamily: 'monospace',
                letterSpacing: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInProgressNotice() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.success500,
            boxShadow: [
              BoxShadow(
                color: AppColors.success500.withOpacity(0.4),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF16151A) : Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.favorite_rounded,
                  color: AppColors.success500,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.serviceInProgress,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFF16151A) : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.serviceInProgressDesc(_serviceName),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.4,
                      ),
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

  Widget _buildNurseInfoSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        // Nurse Avatar
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_statusColor, _statusColor.withOpacity(0.6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: _statusColor.withOpacity(0.3),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              _nurseName.isNotEmpty ? _nurseName[0].toUpperCase() : 'N',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF16151A),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Nurse Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _nurseName,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color:
                      isDark
                          ? const Color(0xFFF2F2F5)
                          : AppColors.dark700, // Slate 900
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (_nurseRating > 0) ...[
                    Icon(
                      Icons.star_rounded,
                      size: 18,
                      color: AppColors.warning500, // Amber 500
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _nurseRating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.dark300, // Slate 600
                      ),
                    ),
                  ],
                  if (_nurseRating == 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.light400,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        l10n.newTag,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dark300,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.light600,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.registeredNurse,
                    style: TextStyle(
                      fontSize: 13,
                      color:
                          isDark ? const Color(0xFFA19EAB) : AppColors.dark200,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Call Button
        if (_nursePhone != null && _nursePhone!.isNotEmpty) ...[
          const SizedBox(width: 12),
          Material(
            color:
                isDark ? AppColors.doctorColor : AppColors.light100, // Slate 50
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.callingNurse(_nursePhone!))),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.doctorColor),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.phone_rounded,
                  color:
                      isDark ? const Color(0xFFF2F2F5) : AppColors.doctorColor,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtonsRow() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.callingEmergency),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error500,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.emergency, size: 20),
                label: Text(
                  l10n.sosLabel,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.filingReport)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.light300,
                  foregroundColor: AppColors.dark700,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                icon: Icon(Icons.flag, size: 20, color: AppColors.warning500),
                label: Text(
                  l10n.reportLabel,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
