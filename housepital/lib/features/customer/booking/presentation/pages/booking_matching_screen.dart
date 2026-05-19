import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:housepital/core/services/socket_notification_service.dart';
import '../../../../../core/network/api_service.dart';
import '../../../../../core/constants/app_colors.dart';

class BookingMatchingScreen extends StatefulWidget {
  final String matchingRequestId;
  final String serviceName;
  final String patientName;
  final double patientLatitude;
  final double patientLongitude;
  final Map<String, dynamic>? retryRequestPayload;

  const BookingMatchingScreen({
    super.key,
    required this.matchingRequestId,
    required this.serviceName,
    required this.patientName,
    required this.patientLatitude,
    required this.patientLongitude,
    this.retryRequestPayload,
  });

  @override
  State<BookingMatchingScreen> createState() => _BookingMatchingScreenState();
}

class _BookingMatchingScreenState extends State<BookingMatchingScreen>
    with TickerProviderStateMixin {
  bool get isDark => Theme.of(context).brightness == Brightness.dark;
  static const double _searchZoomLevel = 14;
  static const double _terminalZoomLevel = 13;

  late AnimationController _pulseController;
  late AnimationController _bottomSheetController;
  final MapController _mapController = MapController();
  LatLng? _lastMapCenter;
  double? _lastMapZoom;
  double? _requestLatitude;
  double? _requestLongitude;
  Timer? _pollTimer;

  bool _isSubmitting = false;
  bool _isCancelling = false;
  bool _isBackgrounding = false;
  bool _isRetrying = false;
  String _statusText = 'Matching you with the best specialist nearby';
  String? _terminalError;
  late String _activeMatchingRequestId;
  double _searchRadiusKm = 15;
  int _nursesInRange = 0;
  int _nursesAccepted = 0;
  DateTime? _expiresAt;
  List<Map<String, dynamic>> _offers = [];

  @override
  void initState() {
    super.initState();

    _activeMatchingRequestId = widget.matchingRequestId;
    _requestLatitude = widget.patientLatitude;
    _requestLongitude = widget.patientLongitude;

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _bottomSheetController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();

    _startPolling();
    _scheduleMapMove(zoom: _searchZoomLevel, force: true);
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    final socket = SocketNotificationService.instance.socket;
    if (socket == null) return;

    socket.on('matching:nurse_offer_available', (_) {
      if (mounted) _pollOnce();
    });

    socket.on('matching:no_nurses_found', (_) {
      if (mounted) _pollOnce();
    });

    socket.on('matching:booking_confirmed', (_) {
      if (mounted) _pollOnce();
    });
  }

  void _removeSocketListeners() {
    final socket = SocketNotificationService.instance.socket;
    if (socket == null) return;
    
    socket.off('matching:nurse_offer_available');
    socket.off('matching:no_nurses_found');
    socket.off('matching:booking_confirmed');
  }

  double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  bool _isValidLatitude(double value) => value >= -90 && value <= 90;
  bool _isValidLongitude(double value) => value >= -180 && value <= 180;
  bool _isLikelyEgypt(double lat, double lon) {
    return lat >= 21.5 && lat <= 31.8 && lon >= 24.5 && lon <= 36.0;
  }

  String _normalizeText(dynamic value) {
    return (value ?? '').toString().trim().toLowerCase();
  }

  Map<String, dynamic>? _asStringMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return null;
  }

  bool _hasEgyptAddressHint(Map<String, dynamic>? address) {
    if (address == null) return false;
    final combined = [
      _normalizeText(address['city']),
      _normalizeText(address['state']),
      _normalizeText(address['area']),
      _normalizeText(address['street']),
      _normalizeText(address['country']),
    ].join(' ');
    if (combined.isEmpty) return false;
    const egyptTokens = [
      'egypt', 'cairo', 'giza', 'alexandria', 'aswan', 'luxor', 'assiut', 'sohag',
      'qena', 'mansoura', 'tanta', 'suez', 'ismailia', 'port said', 'fayoum',
      'beni suef', 'minya', 'damietta', 'zagazig', 'kafr', 'hurghada', 'sharm', 'sinai',
    ];
    for (final token in egyptTokens) {
      if (combined.contains(token)) return true;
    }
    return false;
  }

  Map<String, double>? _fallbackEgyptCenter(Map<String, dynamic>? address) {
    if (address == null) return null;
    final combined = [
      _normalizeText(address['city']),
      _normalizeText(address['state']),
      _normalizeText(address['area']),
      _normalizeText(address['street']),
    ].join(' ');
    if (combined.isEmpty) return null;
    const centers = <String, List<double>>{
      'aswan': [24.0889, 32.8998], 'luxor': [25.6872, 32.6396], 'cairo': [30.0444, 31.2357],
      'giza': [30.0131, 31.2089], 'alexandria': [31.2001, 29.9187], 'assiut': [27.1809, 31.1837],
      'sohag': [26.5560, 31.6948], 'qena': [26.1551, 32.7160], 'mansoura': [31.0409, 31.3785],
      'tanta': [30.7865, 31.0004], 'suez': [29.9668, 32.5498], 'ismailia': [30.5965, 32.2715],
      'port said': [31.2653, 32.3019], 'fayoum': [29.3084, 30.8428], 'beni suef': [29.0744, 31.0978],
      'minya': [28.1099, 30.7503], 'damietta': [31.4175, 31.8144], 'zagazig': [30.5877, 31.5020],
      'kafr': [31.1117, 30.9399], 'hurghada': [27.2579, 33.8116], 'sharm': [27.9158, 34.3299],
    };
    for (final entry in centers.entries) {
      if (combined.contains(entry.key)) {
        return {'latitude': entry.value[0], 'longitude': entry.value[1]};
      }
    }
    if (_hasEgyptAddressHint(address)) {
      return const {'latitude': 30.0444, 'longitude': 31.2357};
    }
    return null;
  }

  Map<String, double>? _sanitizeRequestCoordinates(
    Map<String, double>? coordinates,
    Map<String, dynamic> request,
  ) {
    final address = _asStringMap(request['address']) ?? _asStringMap(request['location']);
    if (address == null) return coordinates;
    final fallback = _fallbackEgyptCenter(address);
    if (coordinates == null) return fallback;
    final lat = coordinates['latitude'];
    final lon = coordinates['longitude'];
    if (lat == null || lon == null) return fallback ?? coordinates;
    if (_isLikelyEgypt(lat, lon)) return coordinates;
    if (_hasEgyptAddressHint(address)) return fallback ?? coordinates;
    return coordinates;
  }

  Map<String, double>? _normalizeCoordinatePair(
    double first, double second, {bool preferGeoJsonOrder = true,}
  ) {
    final geoJsonLat = second;
    final geoJsonLon = first;
    final swappedLat = first;
    final swappedLon = second;
    int score(double lat, double lon) {
      if (!_isValidLatitude(lat) || !_isValidLongitude(lon)) return -1;
      var s = 1;
      if (_isLikelyEgypt(lat, lon)) s += 2;
      return s;
    }
    final geoScore = score(geoJsonLat, geoJsonLon);
    final swappedScore = score(swappedLat, swappedLon);
    if (geoScore < 0 && swappedScore < 0) return null;
    if (geoScore > swappedScore) return {'latitude': geoJsonLat, 'longitude': geoJsonLon};
    if (swappedScore > geoScore) return {'latitude': swappedLat, 'longitude': swappedLon};
    if (preferGeoJsonOrder) return {'latitude': geoJsonLat, 'longitude': geoJsonLon};
    return {'latitude': swappedLat, 'longitude': swappedLon};
  }

  Map<String, double>? _extractLocationFromRequest(Map<String, dynamic> request) {
    Map<String, double>? candidate;
    Map<String, double>? fromLocationMap(dynamic locationData) {
      if (locationData is! Map) return null;
      final coords = locationData['coordinates'];
      if (coords is List && coords.length >= 2) {
        final first = _toDouble(coords[0]);
        final second = _toDouble(coords[1]);
        if (first != null && second != null) {
          final normalized = _normalizeCoordinatePair(first, second, preferGeoJsonOrder: true);
          if (normalized != null) return normalized;
        }
      }
      final lat = _toDouble(locationData['latitude']);
      final lon = _toDouble(locationData['longitude']);
      if (lat != null && lon != null) {
        if (_isValidLatitude(lat) && _isValidLongitude(lon)) return {'latitude': lat, 'longitude': lon};
        if (_isValidLatitude(lon) && _isValidLongitude(lat)) return {'latitude': lon, 'longitude': lat};
      }
      return null;
    }
    final fromGeo = fromLocationMap(request['locationGeo']);
    if (fromGeo != null) candidate = fromGeo;
    if (candidate == null) {
      final lat = _toDouble(request['latitude']);
      final lon = _toDouble(request['longitude']);
      if (lat != null && lon != null) {
        if (_isValidLatitude(lat) && _isValidLongitude(lon)) {
          candidate = {'latitude': lat, 'longitude': lon};
        } else if (_isValidLatitude(lon) && _isValidLongitude(lat)) {
          candidate = {'latitude': lon, 'longitude': lat};
        }
      }
    }
    if (candidate == null) {
      final fromLocation = fromLocationMap(request['location']);
      if (fromLocation != null) candidate = fromLocation;
    }
    return _sanitizeRequestCoordinates(candidate, request);
  }

  LatLng get _mapCenter {
    final lat = _requestLatitude;
    final lon = _requestLongitude;
    if (lat != null && lon != null) {
      if (_isValidLatitude(lat) && _isValidLongitude(lon)) return LatLng(lat, lon);
      if (_isValidLatitude(lon) && _isValidLongitude(lat)) return LatLng(lon, lat);
    }
    return const LatLng(30.0444, 31.2357);
  }

  bool _isSameCenter(LatLng a, LatLng b) {
    return (a.latitude - b.latitude).abs() < 0.0001 &&
        (a.longitude - b.longitude).abs() < 0.0001;
  }

  void _scheduleMapMove({required double zoom, bool force = false}) {
    final center = _mapCenter;
    final sameCenter = _lastMapCenter != null && _isSameCenter(_lastMapCenter!, center);
    final sameZoom = _lastMapZoom != null && (_lastMapZoom! - zoom).abs() < 0.01;
    if (!force && sameCenter && sameZoom) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        _mapController.move(center, zoom);
        _lastMapCenter = center;
        _lastMapZoom = zoom;
      } catch (_) {}
    });
  }

  void _recenterMap() {
    _scheduleMapMove(zoom: _searchZoomLevel, force: true);
  }

  @override
  void dispose() {
    _removeSocketListeners();
    _pollTimer?.cancel();
    _pulseController.dispose();
    _bottomSheetController.dispose();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollOnce();
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) => _pollOnce());
  }

  Future<void> _pollOnce() async {
    if (!mounted || _terminalError != null) return;
    final api = ApiService();
    try {
      final statusResponse = await api.get('/api/matching/request/$_activeMatchingRequestId');
      final request = (statusResponse['matchingRequest'] as Map<String, dynamic>?) ?? {};
      final latestLocation = _extractLocationFromRequest(request);
      final stats = (request['offerStats'] as Map<String, dynamic>?) ?? {};
      final status = request['status']?.toString() ?? 'searching';
      final expiresRaw = request['expiresAt']?.toString();
      final parsedExpiry = (expiresRaw != null && expiresRaw.isNotEmpty) ? DateTime.tryParse(expiresRaw) : null;

      if (mounted) {
        setState(() {
          if (latestLocation != null) {
            _requestLatitude = latestLocation['latitude'];
            _requestLongitude = latestLocation['longitude'];
          }
          _searchRadiusKm = (request['searchRadiusKm'] as num?)?.toDouble() ?? _searchRadiusKm;
          _nursesInRange = (stats['total'] as num?)?.toInt() ?? _nursesInRange;
          _nursesAccepted = (stats['nurseAccepted'] as num?)?.toInt() ?? _nursesAccepted;
          _expiresAt = parsedExpiry ?? _expiresAt;
        });
        _scheduleMapMove(zoom: _searchZoomLevel);
      }

      if (status == 'no_nurses_found') {
        _pollTimer?.cancel();
        setState(() {
          _terminalError = 'No nurses are available right now in your area. Please try again.';
        });
        _scheduleMapMove(zoom: _terminalZoomLevel, force: true);
        return;
      }

      if (status == 'expired' || status == 'cancelled') {
        _pollTimer?.cancel();
        setState(() {
          _terminalError = status == 'cancelled'
              ? 'This matching request was cancelled.'
              : 'This matching request has expired.';
        });
        _scheduleMapMove(zoom: _terminalZoomLevel, force: true);
        return;
      }

      if (_offers.isEmpty) {
        setState(() {
          _statusText = status == 'nurse_accepted'
              ? 'Great news! Nurses are responding. Choose your nurse below.'
              : 'Searching nearby nurses...';
        });
      }

      final offersResponse = await api.get('/api/matching/patient-offers/$_activeMatchingRequestId');
      final rawOffers = (offersResponse['offers'] as List? ?? []);
      final parsedOffers = rawOffers.whereType<Map>().map((o) => Map<String, dynamic>.from(o)).toList();

      if (!mounted) return;

      if (parsedOffers.isNotEmpty) {
        _pollTimer?.cancel();
        setState(() {
          _offers = parsedOffers;
          _statusText = 'Select the nurse you want to proceed with';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _statusText = 'Still searching...';
      });
    }
  }

  Future<void> _respondToOffer(String offerId, String response) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      final api = ApiService();
      await api.put(
        '/api/matching/patient-offers/$offerId/respond',
        body: {'response': response},
      );
      if (!mounted) return;
      if (response == 'accepted') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking confirmed successfully')),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
        return;
      }
      setState(() {
        _offers.removeWhere((offer) => offer['offerId']?.toString() == offerId);
        _isSubmitting = false;
      });
      if (_offers.isEmpty) {
        setState(() {
          _statusText = 'Searching for more nurse offers...';
        });
        _startPolling();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Action failed: $e')));
    }
  }

  Future<void> _cancelMatchingRequest() async {
    if (_isCancelling || _isSubmitting || _isRetrying) return;
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel request?'),
        content: Text('This will stop matching and notify available nurses.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Keep waiting', style: TextStyle(color: AppColors.textPrimary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.light50,
            ),
            child: Text('Cancel request'),
          ),
        ],
      ),
    ) ?? false;

    if (!shouldCancel || !mounted) return;
    setState(() => _isCancelling = true);
    _pollTimer?.cancel();

    try {
      final api = ApiService();
      await api.put('/api/matching/request/$_activeMatchingRequestId/cancel');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Matching request cancelled')));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCancelling = false);
      _startPolling();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cancel failed: $e')));
    }
  }

  Future<void> _continueInBackground() async {
    if (_isBackgrounding || _isCancelling || _isSubmitting || _isRetrying) return;
    setState(() => _isBackgrounding = true);
    _pollTimer?.cancel();
    try {
      final prefs = await SharedPreferences.getInstance();
      final center = _mapCenter;
      await prefs.setBool('active_matching_in_background', true);
      await prefs.setString('active_matching_request_id', _activeMatchingRequestId);
      await prefs.setString('active_matching_service_name', widget.serviceName);
      await prefs.setString('active_matching_patient_name', widget.patientName);
      await prefs.setDouble('active_matching_latitude', center.latitude);
      await prefs.setDouble('active_matching_longitude', center.longitude);
      await prefs.setString('active_matching_saved_at', DateTime.now().toIso8601String());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Matching continues in the background'), duration: Duration(seconds: 2)),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isBackgrounding = false);
      _startPolling();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not continue in background: $e')));
    }
  }

  Future<void> _retryMatchingRequest() async {
    if (_isRetrying || _isSubmitting || _isCancelling || _isBackgrounding) return;
    final payload = widget.retryRequestPayload;
    if (payload == null || payload.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Retry data is missing. Please book again.')));
      return;
    }
    setState(() => _isRetrying = true);
    try {
      final api = ApiService();
      final response = await api.post('/api/matching/request', body: Map<String, dynamic>.from(payload));
      final newRequest = response['matchingRequest'] as Map<String, dynamic>?;
      final newRequestId = newRequest?['id']?.toString();
      if (newRequestId == null || newRequestId.isEmpty) throw Exception('Failed to create a new matching request');
      if (!mounted) return;
      final payloadLat = _toDouble(payload['latitude']);
      final payloadLon = _toDouble(payload['longitude']);
      final payloadCenter = (payloadLat != null && payloadLon != null)
          ? _normalizeCoordinatePair(payloadLat, payloadLon, preferGeoJsonOrder: false)
          : null;
      final requestCenter = newRequest != null ? _extractLocationFromRequest(newRequest) : null;
      final nextCenter = requestCenter ?? payloadCenter;
      setState(() {
        _activeMatchingRequestId = newRequestId;
        if (nextCenter != null) {
          _requestLatitude = nextCenter['latitude'];
          _requestLongitude = nextCenter['longitude'];
        }
        _terminalError = null;
        _offers = [];
        _nursesInRange = 0;
        _nursesAccepted = 0;
        _expiresAt = null;
        _statusText = 'Searching nearby nurses...';
        _isRetrying = false;
      });
      _scheduleMapMove(zoom: _searchZoomLevel, force: true);
      _startPolling();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Started a new matching request')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isRetrying = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Retry failed: $e')));
    }
  }

  String _timeLeftText() {
    if (_expiresAt == null) return 'Estimating...';
    final diff = _expiresAt!.difference(DateTime.now());
    if (diff.isNegative) return 'Expiring now';
    final minutes = diff.inMinutes;
    final seconds = diff.inSeconds % 60;
    return '${minutes}m ${seconds}s left';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0C11) : AppColors.light200,
      body: Stack(
        children: [
          // 1. Map Layer
          _buildMap(),

          // 2. Top Gradient for readability
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 3. Top Navigation & Status
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildGlassButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () {
                        if (_offers.isNotEmpty || _terminalError == null) {
                          _cancelMatchingRequest();
                        } else {
                          Navigator.pop(context);
                        }
                      },
                    ),
                    _buildGlassStatusChip(),
                    _buildGlassButton(
                      icon: Icons.minimize_rounded,
                      onTap: _continueInBackground,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. Recenter Button
          Positioned(
            right: 16,
            bottom: MediaQuery.of(context).size.height * 0.45,
            child: _buildRecenterButton(),
          ),

          // 5. Bottom Panel
          Positioned(
            bottom: 0,
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
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _mapCenter,
            initialZoom: _searchZoomLevel,
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.housepital.staff',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: _mapCenter,
                  width: 220,
                  height: 220,
                  child: _buildPulsingLocationMarker(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPulsingLocationMarker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scaleValue = 0.95 + (_pulseController.value * 0.1);
        final fadeValue = 0.3 + (_pulseController.value * 0.5);
        final errorMode = _terminalError != null;
        final color = errorMode ? AppColors.error : AppColors.primary500;

        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 190 * scaleValue,
              height: 190 * scaleValue,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withOpacity(fadeValue * 0.55),
                  width: 2,
                ),
                color: color.withOpacity(fadeValue * 0.12),
              ),
            ),
            Container(
              width: 120 * scaleValue,
              height: 120 * scaleValue,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(fadeValue * 0.1),
              ),
            ),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? const Color(0xFF16151A) : AppColors.light50,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.25),
                    blurRadius: 16,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Icon(
                errorMode ? Icons.warning_amber_rounded : Icons.local_hospital_rounded,
                color: color,
                size: 34,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGlassButton({required IconData icon, required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: AppColors.light50.withOpacity(0.85),
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Icon(icon, color: isDark ? const Color(0xFFF2F2F5) : AppColors.dark700, size: 22),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassStatusChip() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool errorMode = _terminalError != null;
    final bool offersMode = _offers.isNotEmpty;
    final Color color = errorMode ? AppColors.error : (offersMode ? AppColors.success : AppColors.primary500);
    final String label = errorMode ? 'Ended' : (offersMode ? 'Offers Found' : 'Searching');

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AppColors.light50.withOpacity(0.85),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, _) => Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.4 + (1 - _pulseController.value) * 0.6),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 6,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
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
      backgroundColor: AppColors.light50,
      mini: true,
      elevation: 4,
      onPressed: _recenterMap,
      child: Icon(
        Icons.my_location_rounded,
        color: AppColors.dark300,
        size: 22,
      ),
    );
  }

  Widget _buildAnimatedBottomSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _bottomSheetController,
        curve: Curves.easeOutQuart,
      )),
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF16151A) : AppColors.light50,
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
                  color: AppColors.light400,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                child: _buildBottomSheetContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheetContent() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_terminalError != null) {
      return _buildErrorStateContent();
    }
    if (_offers.isNotEmpty) {
      return _buildOffersListContent();
    }
    return _buildSearchingContent();
  }

  Widget _buildErrorStateContent() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final message = _terminalError ?? 'Matching failed';
    final lowerMessage = message.toLowerCase();
    final isNoNursesState = lowerMessage.contains('no nurses');
    final isCancelledState = lowerMessage.contains('cancelled');

    final title = isNoNursesState ? 'No nurses found in your area' : isCancelledState ? 'Request cancelled' : 'Matching request ended';
    final subtitle = isNoNursesState ? 'We searched in your current range and couldn\'t find an available nurse right now.' : isCancelledState ? 'You cancelled this request successfully.' : 'The request expired before a final confirmation.';
    final accentColor = isNoNursesState ? AppColors.warning : isCancelledState ? AppColors.dark300 : AppColors.error;
    final icon = isNoNursesState ? Icons.warning_amber_rounded : isCancelledState ? Icons.cancel_outlined : Icons.timer_off_outlined;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accentColor.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF16151A) : AppColors.light50,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: accentColor.withOpacity(0.15), blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: Icon(icon, color: accentColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: accentColor)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFFA19EAB) : AppColors.dark200, height: 1.4)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  side: const BorderSide(color: AppColors.light400),
                ),
                child: Text('Back Home', style: TextStyle(color: AppColors.dark600, fontWeight: FontWeight.w600)),
              ),
            ),
            if (isNoNursesState) ...[
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isRetrying ? null : _retryMatchingRequest,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: AppColors.primary500,
                    foregroundColor: AppColors.light50,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isRetrying
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.light50)))
                      : Text('Try Again', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildSearchingContent() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary500.withOpacity(0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary500.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF16151A) : AppColors.light50,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppColors.primary500.withOpacity(0.15), blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: Icon(Icons.search_rounded, color: AppColors.primary500, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_statusText, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary500)),
                    const SizedBox(height: 4),
                    Text('Scanning within ${_searchRadiusKm.toStringAsFixed(0)} km for ${widget.serviceName}', style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFFA19EAB) : AppColors.dark200, height: 1.4)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildMetricCard(label: 'Nurses viewing request', value: '$_nursesInRange', icon: Icons.people_outline)),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard(label: 'Time left', value: _timeLeftText(), icon: Icons.timer_outlined, isHighlight: true)),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({required String label, required String value, required IconData icon, bool isHighlight = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isHighlight ? AppColors.warning : AppColors.dark600;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.light100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.light400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFFA19EAB) : AppColors.dark200),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildOffersListContent() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Available Nurses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: isDark ? const Color(0xFFF2F2F5) : AppColors.dark700)),
        const SizedBox(height: 4),
        Text(_statusText, style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFFA19EAB) : AppColors.dark200)),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
          child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: _offers.length,
            itemBuilder: (context, index) => _buildOfferCard(_offers[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildOfferCard(Map<String, dynamic> offer) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nurse = (offer['nurse'] as Map<String, dynamic>?) ?? {};
    final pricing = (offer['pricing'] as Map<String, dynamic>?) ?? {};
    final offerId = offer['offerId']?.toString() ?? '';

    final nurseName = nurse['name']?.toString() ?? 'Nurse';
    final rating = (nurse['rating'] ?? 0).toString();
    final years = (nurse['yearsOfExperience'] ?? 0).toString();
    final totalPrice = (pricing['totalPrice'] ?? 0).toString();
    final eta = (offer['estimatedArrivalMinutes'] ?? '--').toString();
    final distance = (offer['distanceKm'] ?? '--').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16151A) : AppColors.light50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.light400),
        boxShadow: [
          BoxShadow(color: isDark ? const Color(0xFFF2F2F5) : AppColors.dark700.withOpacity(0.04), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary100),
                ),
                child: Icon(Icons.person_rounded, color: AppColors.primary500, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nurseName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? const Color(0xFFF2F2F5) : AppColors.dark700)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, size: 14, color: AppColors.warning),
                        const SizedBox(width: 4),
                        Text(rating, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.dark300)),
                        const SizedBox(width: 8),
                        Container(width: 4, height: 4, decoration: BoxDecoration(color: AppColors.light600, shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Text('$years yrs exp', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFFA19EAB) : AppColors.dark200)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: AppColors.success50, borderRadius: BorderRadius.circular(10)),
                child: Text('EGP $totalPrice', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.success800, fontSize: 14)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: AppColors.light100, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Icon(Icons.directions_car_rounded, size: 14, color: AppColors.dark300),
                const SizedBox(width: 6),
                Text('ETA $eta min', style: TextStyle(color: AppColors.dark600, fontSize: 13, fontWeight: FontWeight.w600)),
                const Spacer(),
                Icon(Icons.location_on_rounded, size: 14, color: AppColors.dark300),
                const SizedBox(width: 6),
                Text('$distance km away', style: TextStyle(color: AppColors.dark600, fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSubmitting ? null : () => _respondToOffer(offerId, 'declined'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    side: const BorderSide(color: AppColors.light400),
                  ),
                  child: Text('Decline', style: TextStyle(color: AppColors.dark600, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : () => _respondToOffer(offerId, 'accepted'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: AppColors.primary500,
                    foregroundColor: AppColors.light50,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text('Accept', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
