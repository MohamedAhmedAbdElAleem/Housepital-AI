import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';

// ═══════════════════════════════════════════════════════════════════════════════
//  NURSE DEVICE MANAGEMENT SCREEN
//  Allows nurses to assign/release ESP32 monitoring devices to active bookings.
//  - Lists available (idle) devices from the pool
//  - Provides one-tap assign to current booking
//  - Shows live device status and release button
// ═══════════════════════════════════════════════════════════════════════════════

class NurseDeviceManagementScreen extends StatefulWidget {
  final String bookingId;
  final String patientId;
  final String patientName;

  const NurseDeviceManagementScreen({
    super.key,
    required this.bookingId,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<NurseDeviceManagementScreen> createState() =>
      _NurseDeviceManagementScreenState();
}

class _NurseDeviceManagementScreenState
    extends State<NurseDeviceManagementScreen> with TickerProviderStateMixin {
  final ApiClient _api = ApiClient();

  // State
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _assignedDevice;
  List<Map<String, dynamic>> _availableDevices = [];
  bool _isAssigning = false;
  bool _isReleasing = false;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _loadDeviceState();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  /// Check if a device is already assigned, and load available devices
  Future<void> _loadDeviceState() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 1. Check if there's already a device assigned to this booking
      try {
        final liveResp = await _api.get(
          ApiConstants.deviceLiveVitals(widget.bookingId),
        );
        if (liveResp != null && liveResp['success'] == true) {
          _assignedDevice = liveResp['data'];
        }
      } catch (_) {
        // No device assigned yet — that's fine
        _assignedDevice = null;
      }

      // 2. Fetch available (idle) devices from the pool
      try {
        final listResp = await _api.get('${ApiConstants.deviceList}?status=idle');
        if (listResp != null && listResp['success'] == true) {
          final devicesRaw = listResp['data']?['devices'] as List? ?? [];
          _availableDevices = devicesRaw
              .map((d) => Map<String, dynamic>.from(d))
              .toList();
        }
      } catch (_) {
        _availableDevices = [];
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load device information';
      });
    }
  }

  /// Assign a device to the current booking
  Future<void> _assignDevice(String deviceId) async {
    setState(() => _isAssigning = true);

    try {
      final resp = await _api.put(
        ApiConstants.deviceAssign(deviceId),
        body: {
          'bookingId': widget.bookingId,
          'patientId': widget.patientId,
        },
      );

      if (resp != null && resp['success'] == true) {
        _showSnackBar('✅ Device $deviceId assigned successfully', isError: false);
        await _loadDeviceState();
      } else {
        _showSnackBar(resp?['message'] ?? 'Failed to assign device');
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isAssigning = false);
    }
  }

  /// Release the currently assigned device
  Future<void> _releaseDevice(String deviceId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Release Device?',
          style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
        ),
        content: Text(
          'This will stop monitoring for ${widget.patientName} and return device $deviceId to the pool.',
          style: const TextStyle(color: Colors.white70, fontFamily: 'Inter'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Release'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isReleasing = true);

    try {
      final resp = await _api.put(
        ApiConstants.deviceRelease(deviceId),
        body: {},
      );

      if (resp != null && resp['success'] == true) {
        _showSnackBar('Device released to pool', isError: false);
        await _loadDeviceState();
      } else {
        _showSnackBar(resp?['message'] ?? 'Failed to release device');
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isReleasing = false);
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Inter')),
        backgroundColor:
            isError ? const Color(0xFFE53935) : const Color(0xFF2ECC71),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF2ECC71)))
            : _error != null
                ? _buildErrorState()
                : CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(child: _buildHeader()),
                      if (_assignedDevice != null)
                        SliverToBoxAdapter(child: _buildAssignedDeviceCard()),
                      if (_assignedDevice == null) ...[
                        SliverToBoxAdapter(child: _buildNoDeviceNotice()),
                        SliverToBoxAdapter(child: _buildAvailableDevicesHeader()),
                        _buildDeviceList(),
                      ],
                    ],
                  ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded,
              size: 64, color: Colors.white.withAlpha(80)),
          const SizedBox(height: 16),
          Text(_error ?? 'Error',
              style:
                  const TextStyle(color: Colors.white70, fontFamily: 'Inter')),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _loadDeviceState,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2ECC71)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
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
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Device Management',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Assign or release monitoring devices',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF667EEA).withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: const Color(0xFF667EEA).withAlpha(60)),
                ),
                child: const Icon(Icons.developer_board_rounded,
                    color: Color(0xFF667EEA), size: 22),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Patient info bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withAlpha(10)),
            ),
            child: Row(
              children: [
                const Icon(Icons.person_rounded,
                    color: Color(0xFF2ECC71), size: 20),
                const SizedBox(width: 8),
                Text(
                  widget.patientName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  'Booking: ${widget.bookingId.substring(0, 8)}...',
                  style: TextStyle(
                    color: Colors.white.withAlpha(100),
                    fontSize: 11,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Assigned Device Card ───────────────────────────────────────────────
  Widget _buildAssignedDeviceCard() {
    final device = _assignedDevice!;
    final deviceId = device['deviceId'] ?? '--';
    final isOnline = device['isOnline'] ?? false;
    final connType = device['connectionType'] ?? 'wifi';
    final status = device['status'] ?? 'active';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A3A2A), Color(0xFF162E1E)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2ECC71).withAlpha(60)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2ECC71).withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isOnline
                            ? Color.lerp(const Color(0xFF2ECC71),
                                const Color(0xFF27AE60),
                                _pulseController.value)
                            : const Color(0xFFE53935),
                        boxShadow: isOnline
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF2ECC71)
                                      .withAlpha(
                                          (80 * _pulseController.value)
                                              .toInt()),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  isOnline ? 'Device Active' : 'Device Offline',
                  style: TextStyle(
                    color: isOnline
                        ? const Color(0xFF2ECC71)
                        : const Color(0xFFE53935),
                    fontSize: 13,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: _statusColor(status),
                      fontSize: 10,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Device info
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.developer_board_rounded,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deviceId,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            connType == 'ble'
                                ? Icons.bluetooth_rounded
                                : Icons.wifi_rounded,
                            color: Colors.white54,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            connType == 'ble' ? 'Bluetooth' : 'WiFi',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Release button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isReleasing ? null : () => _releaseDevice(deviceId),
                icon: _isReleasing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.link_off_rounded, size: 18),
                label: Text(_isReleasing ? 'Releasing...' : 'Release Device'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── No Device Assigned Notice ──────────────────────────────────────────
  Widget _buildNoDeviceNotice() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF191919),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFB8A00).withAlpha(40)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFB8A00).withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.info_outline_rounded,
                color: Color(0xFFFB8A00), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'No Device Assigned',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Select a device below to start monitoring ${widget.patientName}',
                  style: TextStyle(
                    color: Colors.white.withAlpha(140),
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Available Devices Header ───────────────────────────────────────────
  Widget _buildAvailableDevicesHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          const Text(
            'Available Devices',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${_availableDevices.length} idle',
              style: TextStyle(
                color: Colors.white.withAlpha(120),
                fontSize: 12,
                fontFamily: 'Inter',
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _loadDeviceState,
            child: Icon(Icons.refresh_rounded,
                color: Colors.white.withAlpha(100), size: 20),
          ),
        ],
      ),
    );
  }

  // ── Device List ────────────────────────────────────────────────────────
  Widget _buildDeviceList() {
    if (_availableDevices.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF191919),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Icon(Icons.devices_other_rounded,
                  size: 48, color: Colors.white.withAlpha(60)),
              const SizedBox(height: 12),
              Text(
                'No idle devices available',
                style: TextStyle(
                  color: Colors.white.withAlpha(120),
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'All devices are currently assigned',
                style: TextStyle(
                  color: Colors.white.withAlpha(80),
                  fontSize: 12,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final device = _availableDevices[index];
          return _buildAvailableDeviceCard(device);
        },
        childCount: _availableDevices.length,
      ),
    );
  }

  Widget _buildAvailableDeviceCard(Map<String, dynamic> device) {
    final deviceId = device['deviceId'] ?? '--';
    final deviceName = device['deviceName'] ?? deviceId;
    final totalSessions = device['totalSessions'] ?? 0;
    final firmware = device['firmwareVersion'] ?? '1.0.0';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF191919),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withAlpha(10)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: _isAssigning ? null : () => _assignDevice(deviceId),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.developer_board_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deviceId,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        deviceName,
                        style: TextStyle(
                          color: Colors.white.withAlpha(120),
                          fontSize: 12,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildMiniStat(
                              Icons.repeat_rounded, '$totalSessions sessions'),
                          const SizedBox(width: 12),
                          _buildMiniStat(Icons.memory_rounded, 'v$firmware'),
                        ],
                      ),
                    ],
                  ),
                ),
                // Assign button
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2ECC71).withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: const Color(0xFF2ECC71).withAlpha(60)),
                  ),
                  child: _isAssigning
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Color(0xFF2ECC71)))
                      : const Text(
                          'Assign',
                          style: TextStyle(
                            color: Color(0xFF2ECC71),
                            fontSize: 13,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white38, size: 12),
        const SizedBox(width: 3),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withAlpha(80),
            fontSize: 10,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return const Color(0xFF2ECC71);
      case 'sos':
        return const Color(0xFFE53935);
      case 'fault':
        return const Color(0xFFFB8A00);
      default:
        return const Color(0xFF42A5F5);
    }
  }
}
