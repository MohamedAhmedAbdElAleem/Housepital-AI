import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

//  BLE VITALS SERVICE
//  Fallback mechanism to directly connect to the ESP32 when WiFi/Backend is unavailable.

class BleVitalsUpdate {
  final double? temperature;
  final int? heartRate;
  final int? oxygenSaturation;
  final bool sos;
  final bool fingerDetected;
  final bool sensorFault;
  final DateTime timestamp;

  BleVitalsUpdate({
    this.temperature,
    this.heartRate,
    this.oxygenSaturation,
    this.sos = false,
    this.fingerDetected = false,
    this.sensorFault = false,
    required this.timestamp,
  });
}

class BleVitalsService {
  BluetoothDevice? _connectedDevice;
  StreamSubscription? _scanSubscription;
  StreamSubscription? _vitalsSubscription;
  StreamSubscription? _connectionSubscription;

  // Event stream for UI updates
  final _vitalsController = StreamController<BleVitalsUpdate>.broadcast();
  Stream<BleVitalsUpdate> get onVitalsUpdate => _vitalsController.stream;

  final _connectionStateController = StreamController<bool>.broadcast();
  Stream<bool> get onConnectionChanged => _connectionStateController.stream;

  // UUIDs matching ESP32 firmware
  static const String SERVICE_UUID = "12345678-1234-5678-1234-56789abcdef0";
  static const String VITALS_CHAR_UUID = "12345678-1234-5678-1234-56789abcdef1";
  static const String SOS_CHAR_UUID = "12345678-1234-5678-1234-56789abcdef2";

  /// Start scanning for the ESP32 and auto-connect
  Future<void> startBLEScanAndConnect() async {
    // Check if Bluetooth is supported and enabled
    if (await FlutterBluePlus.isSupported == false) {
      debugPrint('[BLE] Bluetooth not supported by this device');
      return;
    }

    try {
      final state = await FlutterBluePlus.adapterState.first;
      if (state != BluetoothAdapterState.on) {
        debugPrint('[BLE] Bluetooth is off');
        // We could prompt user to turn it on here
      }
    } catch (e) {
      debugPrint('[BLE] Exception checking adapter state: $e');
    }

    _connectionStateController.add(false);

    debugPrint('[BLE] Starting scan...');
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    } catch (e) {
      debugPrint('[BLE] Failed to start scan: $e');
      return;
    }

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) async {
      for (ScanResult r in results) {
        if (r.device.advName == "Housepital-001" ||
            r.device.platformName == "Housepital-001") {
          debugPrint('[BLE] Found ESP32! Cancelling scan & connecting...');
          await FlutterBluePlus.stopScan();
          _connectToDevice(r.device);
          break;
        }
      }
    });

    // Handle end of scan if not found
    Future.delayed(const Duration(seconds: 16), () {
      if (_connectedDevice == null) {
        debugPrint('[BLE] Scan completed. Device not found.');
      }
    });
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    _connectedDevice = device;

    // Listen to connection state
    _connectionSubscription = device.connectionState.listen((
      BluetoothConnectionState state,
    ) async {
      if (state == BluetoothConnectionState.disconnected) {
        debugPrint('[BLE] Device disconnected');
        _connectionStateController.add(false);
        _connectedDevice = null;
      } else if (state == BluetoothConnectionState.connected) {
        debugPrint('[BLE] Device connected');
        _connectionStateController.add(true);
        await _discoverServices(device);
      }
    });

    try {
      await device.connect(
        license: License.free,
        autoConnect: false,
      );
    } catch (e) {
      debugPrint('[BLE] Connection error: $e');
    }
  }

  Future<void> _discoverServices(BluetoothDevice device) async {
    debugPrint('[BLE] Discovering services...');
    List<BluetoothService> services = await device.discoverServices();

    for (BluetoothService service in services) {
      if (service.uuid.toString() == SERVICE_UUID) {
        debugPrint('[BLE] Found matching Service!');

        for (BluetoothCharacteristic char in service.characteristics) {
          // Listen to Vitals characteristic
          if (char.uuid.toString() == VITALS_CHAR_UUID) {
            debugPrint('[BLE] Found Vitals Characteristic, subscribing...');
            await char.setNotifyValue(true);

            _vitalsSubscription = char.lastValueStream.listen((value) {
              if (value.isNotEmpty) {
                try {
                  String jsonStr = ascii.decode(value);
                  _parseVitalsJson(jsonStr);
                } catch (e) {
                  debugPrint('[BLE] JSON Parse error: $e');
                }
              }
            });
          }
          // Listen to SOS characteristic
          else if (char.uuid.toString() == SOS_CHAR_UUID) {
            debugPrint('[BLE] Found SOS Characteristic, subscribing...');
            await char.setNotifyValue(true);

            char.lastValueStream.listen((value) {
              if (value.isNotEmpty) {
                try {
                  String jsonStr = ascii.decode(value);
                  _parseVitalsJson(
                    jsonStr,
                  ); // Assuming it might output `{"sos": true}`
                } catch (e) {
                  debugPrint('[BLE] SOS Parse error: $e');
                }
              }
            });
          }
        }
      }
    }
  }

  void _parseVitalsJson(String jsonStr) {
    try {
      final data = json.decode(jsonStr) as Map<String, dynamic>;

      final update = BleVitalsUpdate(
        temperature:
            data['temp']?.toDouble() ?? data['temperature']?.toDouble(),
        heartRate: data['bpm']?.toInt() ?? data['heartRate']?.toInt(),
        oxygenSaturation:
            data['spo2']?.toInt() ?? data['oxygenSaturation']?.toInt(),
        sos: data['sos'] as bool? ?? false,
        fingerDetected:
            data['finger'] as bool? ?? data['fingerDetected'] as bool? ?? true,
        sensorFault:
            data['fault'] as bool? ?? data['sensorFault'] as bool? ?? false,
        timestamp: DateTime.now(),
      );

      _vitalsController.add(update);
    } catch (e) {
      debugPrint('[BLE] Error decoding vitals JSON: $e');
      debugPrint('[BLE] Raw string was: $jsonStr');
    }
  }

  void dispose() {
    _scanSubscription?.cancel();
    _vitalsSubscription?.cancel();
    _connectionSubscription?.cancel();
    _connectedDevice?.disconnect();
    _vitalsController.close();
    _connectionStateController.close();
  }
}
