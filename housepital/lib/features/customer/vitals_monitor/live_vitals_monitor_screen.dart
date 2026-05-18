import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/api_service.dart';
import '../../../core/services/vitals_socket_service.dart';
import '../../../core/services/ble_vitals_service.dart'; // Added BLE Service

// ═══════════════════════════════════════════════════════════════════════════════
//  LIVE VITALS MONITORING SCREEN
//  Shows real-time vital signs from the ESP32 device during a booking visit.
//  Uses polling (with Socket.IO upgrade path) for real-time updates.
// ═══════════════════════════════════════════════════════════════════════════════

class LiveVitalsMonitorScreen extends StatefulWidget {
  final String bookingId;
  final String patientName;

  const LiveVitalsMonitorScreen({
    super.key,
    required this.bookingId,
    required this.patientName,
  });

  @override
  State<LiveVitalsMonitorScreen> createState() =>
      _LiveVitalsMonitorScreenState();
}

class _LiveVitalsMonitorScreenState extends State<LiveVitalsMonitorScreen>
    with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  Timer? _pollingTimer;
  late VitalsSocketService _vitalsSocket;
  late BleVitalsService _bleVitalsService; // Add BLE Service instance

  StreamSubscription? _vitalsSubscription;
  StreamSubscription? _criticalSubscription;
  StreamSubscription? _sosSubscription;

  // BLE Subscriptions
  StreamSubscription? _bleVitalsSubscription;
  StreamSubscription? _bleConnectionSubscription;

  // Vitals state
  double? _temperature;
  int? _heartRate;
  int? _oxygenSaturation;
  bool _fingerDetected = false;
  bool _sensorFault = false;
  bool _isOnline = false;
  bool _sos = false;
  String _connectionType = 'none';
  String _deviceId = '';
  DateTime? _lastUpdate;
  bool _isLoading = true;
  String? _error;
  bool _isSocketLive = false; // true when receiving via Socket.IO

  // Classification
  String _tempStatus = 'normal';
  String _hrStatus = 'normal';
  String _spo2Status = 'normal';

  // History for charts
  final List<_VitalReading> _tempHistory = [];
  final List<_VitalReading> _hrHistory = [];
  final List<_VitalReading> _spo2History = [];

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _sosController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _sosController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    // 1. Initialize BLE as an absolute fallback
    _initBLE();

    // 2. Connect to Socket.IO for real-time updates
    _initSocketIO();

    // 3. Initial HTTP fetch to get current state immediately
    _fetchLiveVitals();

    // 4. Polling as fallback — slower interval since Socket.IO/BLE are primary
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _fetchLiveVitals(),
    );
  }

  void _initBLE() {
    _bleVitalsService = BleVitalsService();
    _bleVitalsService.startBLEScanAndConnect();

    _bleConnectionSubscription = _bleVitalsService.onConnectionChanged.listen((
      isConnected,
    ) {
      if (!mounted) return;
      if (isConnected) {
        setState(() {
          _isOnline = true;
          _connectionType = 'Bluetooth';
        });
      }
    });

    _bleVitalsSubscription = _bleVitalsService.onVitalsUpdate.listen((update) {
      if (!mounted) return;

      // Override Socket/HTTP if BLE is actively providing data
      DateTime now = DateTime.now();
      if (_lastUpdate != null &&
          now.difference(_lastUpdate!).inSeconds < 5 &&
          _connectionType != 'Bluetooth') {
        // If Socket/HTTP is super responsive right now, we can prefer it,
        // but since we are specifically testing BLE, we'll let BLE win.
      }

      setState(() {
        _isOnline = true;
        _connectionType = 'Bluetooth';
        _temperature = update.temperature;
        _heartRate = update.heartRate;
        _oxygenSaturation = update.oxygenSaturation;
        _fingerDetected = update.fingerDetected;
        _sensorFault = update.sensorFault;
        _sos = update.sos;
        _lastUpdate = update.timestamp;
        _isLoading = false;
        _error = null;

        _tempStatus = _classifyTemp(_temperature);
        _hrStatus = _classifyHR(_heartRate);
        _spo2Status = _classifySpO2(_oxygenSaturation);
      });

      if (_heartRate != null && _heartRate! > 0 && _fingerDetected) {
        _pulseController.forward(from: 0);
      }

      _appendHistory();
    });
  }

  void _initSocketIO() {
    _vitalsSocket = VitalsSocketService(bookingId: widget.bookingId);
    _vitalsSocket.subscribe();

    // Listen for real-time vitals updates
    _vitalsSubscription = _vitalsSocket.onVitalsUpdate.listen((update) {
      if (!mounted) return;
      _applyVitalsUpdate(update);
    });

    // Listen for critical alerts
    _criticalSubscription = _vitalsSocket.onCriticalAlert.listen((alert) {
      if (!mounted) return;
      debugPrint('🚨 Critical alert: ${alert.alerts}');
    });

    // Listen for SOS events
    _sosSubscription = _vitalsSocket.onSosEvent.listen((event) {
      if (!mounted) return;
      setState(() {
        _sos = event.active;
      });
    });
  }

  /// Apply a real-time VitalsUpdate from Socket.IO
  void _applyVitalsUpdate(VitalsUpdate update) {
    setState(() {
      _deviceId = update.deviceId;
      _isOnline = true;
      _isSocketLive = true;
      _connectionType = update.connectionType;
      _temperature = update.temperature;
      _heartRate = update.heartRate;
      _oxygenSaturation = update.oxygenSaturation;
      _fingerDetected = update.fingerDetected;
      _sensorFault = update.sensorFault;
      _sos = update.sos;
      _lastUpdate = update.timestamp;
      _isLoading = false;
      _error = null;

      // Use server-side classification if available
      _tempStatus = update.temperatureStatus ?? _classifyTemp(_temperature);
      _hrStatus = update.heartRateStatus ?? _classifyHR(_heartRate);
      _spo2Status =
          update.oxygenSaturationStatus ?? _classifySpO2(_oxygenSaturation);
    });

    // Trigger pulse animation on heartbeat
    if (_heartRate != null && _heartRate! > 0 && _fingerDetected) {
      _pulseController.forward(from: 0);
    }

    // Add to history
    _appendHistory();
  }

  void _appendHistory() {
    final now = DateTime.now();
    if (_temperature != null) {
      _tempHistory.add(_VitalReading(now, _temperature!));
      if (_tempHistory.length > 30) _tempHistory.removeAt(0);
    }
    if (_heartRate != null) {
      _hrHistory.add(_VitalReading(now, _heartRate!.toDouble()));
      if (_hrHistory.length > 30) _hrHistory.removeAt(0);
    }
    if (_oxygenSaturation != null) {
      _spo2History.add(_VitalReading(now, _oxygenSaturation!.toDouble()));
      if (_spo2History.length > 30) _spo2History.removeAt(0);
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _pulseController.dispose();
    _sosController.dispose();
    _vitalsSubscription?.cancel();
    _criticalSubscription?.cancel();
    _sosSubscription?.cancel();
    _vitalsSocket.dispose();

    // Clean up BLE
    _bleVitalsSubscription?.cancel();
    _bleConnectionSubscription?.cancel();
    _bleVitalsService.dispose();

    super.dispose();
  }

  Future<void> _fetchLiveVitals() async {
    try {
      final response = await _apiService.get(
        ApiConstants.deviceLiveVitals(widget.bookingId),
      );

      if (response != null && response['success'] == true) {
        final data = response['data'];
        final vitals = data['vitals'] ?? {};

        setState(() {
          _deviceId = data['deviceId'] ?? '';
          _isOnline = data['isOnline'] ?? false;
          _connectionType = data['connectionType'] ?? 'none';
          _temperature = vitals['temperature']?.toDouble();
          _heartRate = vitals['heartRate']?.toInt();
          _oxygenSaturation = vitals['oxygenSaturation']?.toInt();
          _fingerDetected = vitals['fingerDetected'] ?? false;
          _sensorFault = vitals['sensorFault'] ?? false;
          _lastUpdate =
              vitals['receivedAt'] != null
                  ? DateTime.parse(vitals['receivedAt'])
                  : null;
          _isLoading = false;
          _error = null;
          // Mark as not socket-live since this came from HTTP
          if (!_vitalsSocket.isSubscribed) {
            _isSocketLive = false;
          }
        });

        // Update classification
        _tempStatus = _classifyTemp(_temperature);
        _hrStatus = _classifyHR(_heartRate);
        _spo2Status = _classifySpO2(_oxygenSaturation);

        // Trigger pulse animation on heartbeat
        if (_heartRate != null && _heartRate! > 0 && _fingerDetected) {
          _pulseController.forward(from: 0);
        }

        // Add to history
        _appendHistory();
      }
    } catch (e) {
      if (_isLoading) {
        setState(() {
          _isLoading = false;
          _error = 'No device assigned to this booking yet';
        });
      }
    }
  }

  String _classifyTemp(double? temp) {
    if (temp == null) return 'normal';
    if (temp < 35 || temp > 39.5) return 'critical';
    if (temp < 36.1) return 'low';
    if (temp > 37.5) return 'high';
    return 'normal';
  }

  String _classifyHR(int? hr) {
    if (hr == null) return 'normal';
    if (hr < 40 || hr > 150) return 'critical';
    if (hr < 60) return 'low';
    if (hr > 100) return 'high';
    return 'normal';
  }

  String _classifySpO2(int? spo2) {
    if (spo2 == null) return 'normal';
    if (spo2 < 90) return 'critical';
    if (spo2 < 95) return 'low';
    return 'normal';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'critical':
        return const Color(0xFFE53935);
      case 'high':
        return const Color(0xFFFB8A00);
      case 'low':
        return const Color(0xFF42A5F5);
      default:
        return const Color(0xFF2ECC71);
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'critical':
        return Icons.warning_rounded;
      case 'high':
        return Icons.arrow_upward_rounded;
      case 'low':
        return Icons.arrow_downward_rounded;
      default:
        return Icons.check_circle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child:
            _isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF2ECC71)),
                )
                : _error != null
                ? _buildErrorState()
                : _buildMonitorContent(),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sensors_off_rounded,
              size: 80,
              color: Colors.white.withAlpha(100),
            ),
            const SizedBox(height: 24),
            Text(
              _error ?? 'Error loading vitals',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _fetchLiveVitals();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2ECC71),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonitorContent() {
    return CustomScrollView(
      slivers: [
        // ── Header ──────────────────────────────────────────────────
        SliverToBoxAdapter(child: _buildHeader()),
        // ── SOS Banner ──────────────────────────────────────────────
        if (_sos) SliverToBoxAdapter(child: _buildSOSBanner()),
        // ── Vital Cards Grid ────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: SliverGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: [
              _buildVitalCard(
                title: 'Temperature',
                value:
                    _temperature != null
                        ? '${_temperature!.toStringAsFixed(1)}°'
                        : '--',
                unit: 'C',
                icon: Icons.thermostat_rounded,
                status: _tempStatus,
                gradient: const [Color(0xFFFF6B35), Color(0xFFFF9A76)],
              ),
              _buildVitalCard(
                title: 'Heart Rate',
                value:
                    _heartRate != null && _heartRate! > 0
                        ? '$_heartRate'
                        : '--',
                unit: 'bpm',
                icon: Icons.favorite_rounded,
                status: _hrStatus,
                gradient: const [Color(0xFFE53935), Color(0xFFEF5350)],
                isPulsing:
                    _fingerDetected && _heartRate != null && _heartRate! > 0,
              ),
              _buildVitalCard(
                title: 'SpO2',
                value:
                    _oxygenSaturation != null && _oxygenSaturation! > 0
                        ? '$_oxygenSaturation'
                        : '--',
                unit: '%',
                icon: Icons.air_rounded,
                status: _spo2Status,
                gradient: const [Color(0xFF1E88E5), Color(0xFF42A5F5)],
              ),
              _buildDeviceStatusCard(),
            ],
          ),
        ),
        // ── Sensor Status ───────────────────────────────────────────
        SliverToBoxAdapter(child: _buildSensorStatusBar()),
        // ── Mini Chart ──────────────────────────────────────────────
        SliverToBoxAdapter(child: _buildMiniChart()),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Patient Monitor',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.patientName,
                      style: TextStyle(
                        color: Colors.white.withAlpha(180),
                        fontSize: 14,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              _buildConnectionBadge(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionBadge() {
    final isConnected = _isOnline;
    final isLive = _isSocketLive && _vitalsSocket.isSubscribed;
    final color =
        isConnected ? const Color(0xFF2ECC71) : const Color(0xFFE53935);
    final text =
        isConnected
            ? _connectionType == 'ble'
                ? 'BLE'
                : 'WiFi'
            : 'Offline';
    final icon =
        isConnected
            ? _connectionType == 'ble'
                ? Icons.bluetooth_connected_rounded
                : Icons.wifi_rounded
            : Icons.wifi_off_rounded;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Live indicator
        if (isLive)
          Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE53935).withAlpha(30),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE53935).withAlpha(80)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFE53935),
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Color(0xFFE53935),
                    fontSize: 10,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withAlpha(80)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                text,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSOSBanner() {
    return AnimatedBuilder(
      animation: _sosController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.lerp(
                  const Color(0xFFE53935),
                  const Color(0xFFFF1744),
                  _sosController.value,
                )!,
                const Color(0xFFD32F2F),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFFE53935,
                ).withAlpha((100 * _sosController.value).toInt()),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.emergency_rounded,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'SOS EMERGENCY ALERT!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVitalCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required String status,
    required List<Color> gradient,
    bool isPulsing = false,
  }) {
    final color = _statusColor(status);
    final statusIconData = _statusIcon(status);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF191919), const Color(0xFF1E1E2E)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gradient[0].withAlpha(60), width: 1),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withAlpha(30),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Watermark icon
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(icon, size: 80, color: gradient[0].withAlpha(20)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: gradient),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(statusIconData, color: color, size: 16),
                  ],
                ),
                const Spacer(),
                // Value
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final scale =
                        isPulsing ? 1.0 + (_pulseController.value * 0.05) : 1.0;
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        value,
                        style: TextStyle(
                          color:
                              _fingerDetected || value != '--'
                                  ? Colors.white
                                  : Colors.white38,
                          fontSize: 32,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (value != '--') ...[
                        const SizedBox(width: 4),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            unit,
                            style: TextStyle(
                              color: Colors.white.withAlpha(120),
                              fontSize: 14,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                // Status label
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceStatusCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF191919), Color(0xFF1E1E2E)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF667EEA).withAlpha(60),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              Icons.developer_board_rounded,
              size: 80,
              color: const Color(0xFF667EEA).withAlpha(20),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.developer_board_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Device',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  _deviceId.isNotEmpty ? _deviceId : '--',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (_lastUpdate != null)
                  Text(
                    _formatTimeSince(_lastUpdate!),
                    style: TextStyle(
                      color: Colors.white.withAlpha(100),
                      fontSize: 11,
                      fontFamily: 'Inter',
                    ),
                  ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color:
                        _isOnline
                            ? const Color(0xFF2ECC71).withAlpha(25)
                            : const Color(0xFFE53935).withAlpha(25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _isOnline ? 'ONLINE' : 'OFFLINE',
                    style: TextStyle(
                      color:
                          _isOnline
                              ? const Color(0xFF2ECC71)
                              : const Color(0xFFE53935),
                      fontSize: 10,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorStatusBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF191919),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withAlpha(10)),
      ),
      child: Row(
        children: [
          Icon(
            _sensorFault
                ? Icons.error_rounded
                : _fingerDetected
                ? Icons.sensors_rounded
                : Icons.pan_tool_alt_rounded,
            color:
                _sensorFault
                    ? const Color(0xFFFB8A00)
                    : _fingerDetected
                    ? const Color(0xFF2ECC71)
                    : const Color(0xFF42A5F5),
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            _sensorFault
                ? 'Sensor Error — Check device connection'
                : _fingerDetected
                ? 'System Stable — Monitoring active'
                : 'Ready — Place finger on sensor',
            style: TextStyle(
              color: Colors.white.withAlpha(180),
              fontSize: 13,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniChart() {
    if (_hrHistory.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF191919),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Heart Rate Timeline',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: CustomPaint(
              size: Size.infinite,
              painter: _MiniChartPainter(
                data: _hrHistory.map((e) => e.value).toList(),
                color: const Color(0xFFE53935),
                minValue: 40,
                maxValue: 120,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeSince(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 10) return 'Just now';
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}

// ─── Data Classes ────────────────────────────────────────────────────────────

class _VitalReading {
  final DateTime time;
  final double value;
  _VitalReading(this.time, this.value);
}

// ─── Mini Chart Painter ──────────────────────────────────────────────────────

class _MiniChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final double minValue;
  final double maxValue;

  _MiniChartPainter({
    required this.data,
    required this.color,
    this.minValue = 0,
    this.maxValue = 100,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    final gradientPaint =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withAlpha(80), color.withAlpha(0)],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
          ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final range = maxValue - minValue;
    final stepX = size.width / (data.length - 1).clamp(1, double.infinity);

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final normalized = ((data[i] - minValue) / range).clamp(0.0, 1.0);
      final y = size.height - (normalized * size.height);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, gradientPaint);
    canvas.drawPath(path, paint);

    // Draw last point dot
    if (data.isNotEmpty) {
      final lastX = (data.length - 1) * stepX;
      final lastNormalized = ((data.last - minValue) / range).clamp(0.0, 1.0);
      final lastY = size.height - (lastNormalized * size.height);

      canvas.drawCircle(Offset(lastX, lastY), 4, Paint()..color = color);
      canvas.drawCircle(
        Offset(lastX, lastY),
        6,
        Paint()
          ..color = color.withAlpha(60)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MiniChartPainter oldDelegate) {
    return data != oldDelegate.data;
  }
}
