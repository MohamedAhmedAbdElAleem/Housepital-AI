import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';

class AdminDeviceManagementPage extends StatefulWidget {
  const AdminDeviceManagementPage({super.key});
  @override
  State<AdminDeviceManagementPage> createState() =>
      _AdminDeviceManagementPageState();
}

class _AdminDeviceManagementPageState extends State<AdminDeviceManagementPage> {
  final ApiClient _api = ApiClient();
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _devices = [];
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final query = _filterStatus == 'all' ? '' : '?status=$_filterStatus';
      final resp = await _api.get('${ApiConstants.deviceList}$query');
      if (resp != null && resp['success'] == true) {
        final raw = resp['data']?['devices'] as List? ?? [];
        _devices = raw.map((d) => Map<String, dynamic>.from(d)).toList();
      }
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        title: const Text(
          'Device Fleet',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadDevices,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showRegisterDeviceDialog,
        backgroundColor: const Color(0xFF2ECC71),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Register Device',
          style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
        ),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          _buildSummaryBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  void _showRegisterDeviceDialog() {
    final deviceIdCtrl = TextEditingController();
    final deviceNameCtrl = TextEditingController();
    final macCtrl = TextEditingController();
    final fwCtrl = TextEditingController();
    bool _isRegistering = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                backgroundColor: const Color(0xFF1E1E2E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Text(
                  'Register New ESP32',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontSize: 18,
                  ),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _dialogTextField(
                        deviceIdCtrl,
                        'Device ID (e.g. HOSP-NODE-001) *',
                      ),
                      const SizedBox(height: 10),
                      _dialogTextField(
                        deviceNameCtrl,
                        'Device Name (Optional)',
                      ),
                      const SizedBox(height: 10),
                      _dialogTextField(macCtrl, 'MAC Address (Optional)'),
                      const SizedBox(height: 10),
                      _dialogTextField(fwCtrl, 'Firmware Version (Optional)'),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: _isRegistering ? null : () => Navigator.pop(ctx),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2ECC71),
                    ),
                    onPressed:
                        _isRegistering
                            ? null
                            : () async {
                              if (deviceIdCtrl.text.trim().isEmpty) return;

                              setState(() => _isRegistering = true);
                              try {
                                // API Call to register
                                final res = await _api.post(
                                  '/device/register',
                                  body: {
                                    'deviceId': deviceIdCtrl.text.trim(),
                                    'deviceName': deviceNameCtrl.text.trim(),
                                    'macAddress': macCtrl.text.trim(),
                                    'firmwareVersion': fwCtrl.text.trim(),
                                  },
                                );

                                setState(() => _isRegistering = false);
                                Navigator.pop(ctx); // Close register dialog

                                if (res != null && res['success'] == true) {
                                  final token = res['data']['token'];
                                  _loadDevices(); // Refresh list
                                  _showTokenDialog(
                                    deviceIdCtrl.text.trim(),
                                    token,
                                  );
                                } else {
                                  ScaffoldMessenger.of(
                                    this.context,
                                  ).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        res?['message'] ?? 'Failed to register',
                                      ),
                                      backgroundColor: const Color(0xFFE53935),
                                    ),
                                  );
                                }
                              } catch (e) {
                                setState(() => _isRegistering = false);
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: const Color(0xFFE53935),
                                  ),
                                );
                              }
                            },
                    child:
                        _isRegistering
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Text(
                              'Register',
                              style: TextStyle(color: Colors.white),
                            ),
                  ),
                ],
              );
            },
          ),
    );
  }

  void _showTokenDialog(String id, String token) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E2E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Registration Successful! 🎉',
              style: TextStyle(
                color: const Color(0xFF2ECC71),
                fontFamily: 'Poppins',
                fontSize: 18,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Device $id is now registered in the cloud.',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 20),
                const Text(
                  'DEVICE TOKEN',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F0F0F),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: SelectableText(
                    token,
                    style: const TextStyle(
                      color: const Color(0xFF2ECC71),
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '⚠️ IMPORTANT: Copy this token now and paste it into your ESP32 pin_config.h. You will NOT be able to see this token again.',
                  style: TextStyle(
                    color: const Color(0xFFFB8A00),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'I copied it',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Widget _dialogTextField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30),
        filled: true,
        fillColor: const Color(0xFF0F0F0F),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    final filters = ['all', 'idle', 'active', 'sos', 'offline', 'fault'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children:
            filters.map((f) {
              final selected = _filterStatus == f;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(
                    f.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : Colors.white54,
                    ),
                  ),
                  selected: selected,
                  selectedColor: _statusColor(f),
                  backgroundColor: const Color(0xFF1E1E2E),
                  side: BorderSide(
                    color: selected ? _statusColor(f) : Colors.white12,
                  ),
                  onSelected: (_) {
                    setState(() => _filterStatus = f);
                    _loadDevices();
                  },
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildSummaryBar() {
    final total = _devices.length;
    final active = _devices.where((d) => d['status'] == 'active').length;
    final idle = _devices.where((d) => d['status'] == 'idle').length;
    final sos = _devices.where((d) => d['status'] == 'sos').length;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF191919),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _stat('Total', '$total', Colors.white70),
          _stat('Active', '$active', const Color(0xFF2ECC71)),
          _stat('Idle', '$idle', const Color(0xFF42A5F5)),
          _stat('SOS', '$sos', const Color(0xFFE53935)),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withAlpha(100),
            fontSize: 10,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading)
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2ECC71)),
      );
    if (_error != null)
      return Center(
        child: Text(_error!, style: const TextStyle(color: Colors.white54)),
      );
    if (_devices.isEmpty)
      return Center(
        child: Text(
          'No devices found',
          style: TextStyle(
            color: Colors.white.withAlpha(100),
            fontFamily: 'Inter',
          ),
        ),
      );

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _devices.length,
      itemBuilder: (ctx, i) => _buildDeviceCard(_devices[i]),
    );
  }

  Widget _buildDeviceCard(Map<String, dynamic> device) {
    final id = device['deviceId'] ?? '--';
    final status = device['status'] ?? 'idle';
    final isOnline = device['isOnline'] ?? false;
    final conn = device['connectionType'] ?? 'none';
    final sessions = device['totalSessions'] ?? 0;
    final readings = device['totalReadings'] ?? 0;
    final fw = device['firmwareVersion'] ?? '?';
    final lastSeen = device['lastSeenAt'];
    final assignedBooking = device['assignedBooking'];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF191919),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              status == 'sos'
                  ? const Color(0xFFE53935).withAlpha(80)
                  : Colors.white.withAlpha(10),
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: const Border(),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _statusColor(status),
                _statusColor(status).withAlpha(150),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.developer_board_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
        title: Text(
          id,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isOnline
                        ? const Color(0xFF2ECC71)
                        : const Color(0xFFE53935),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${status.toUpperCase()} • $conn',
              style: TextStyle(
                color: Colors.white.withAlpha(120),
                fontSize: 11,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(color: Colors.white12),
                _infoRow('Firmware', 'v$fw'),
                _infoRow('Sessions', '$sessions'),
                _infoRow('Readings', '$readings'),
                if (lastSeen != null)
                  _infoRow('Last Seen', _formatTime(lastSeen)),
                if (assignedBooking != null)
                  _infoRow(
                    'Booking',
                    assignedBooking.toString().substring(0, 12),
                  ),
                const SizedBox(height: 12),
                if (status == 'active' || status == 'sos')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _releaseDevice(id),
                      icon: const Icon(Icons.link_off_rounded, size: 16),
                      label: const Text('Force Release'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
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

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.white.withAlpha(100),
              fontSize: 12,
              fontFamily: 'Inter',
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(dynamic ts) {
    try {
      final dt = DateTime.parse(ts.toString()).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return '--';
    }
  }

  Future<void> _releaseDevice(String deviceId) async {
    try {
      await _api.put(ApiConstants.deviceRelease(deviceId), body: {});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Device $deviceId released'),
          backgroundColor: const Color(0xFF2ECC71),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      _loadDevices();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: const Color(0xFFE53935),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return const Color(0xFF2ECC71);
      case 'idle':
        return const Color(0xFF42A5F5);
      case 'sos':
        return const Color(0xFFE53935);
      case 'fault':
        return const Color(0xFFFB8A00);
      case 'offline':
        return const Color(0xFF78909C);
      default:
        return const Color(0xFF667EEA);
    }
  }
}
