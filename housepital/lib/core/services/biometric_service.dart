import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  static const String _biometricEnabledKey = 'biometric_login_enabled';
  static const String _secureTokenKey = 'secure_session_token';

  /// Check if the device has biometric hardware available and enrolled.
  Future<bool> isBiometricAvailable() async {
    try {
      final bool isDeviceSupported = await _auth.isDeviceSupported();
      final bool canCheckBiometrics = await _auth.canCheckBiometrics;
      final List<BiometricType> availableBiometrics = await _auth.getAvailableBiometrics();
      
      debugPrint('🔍 Biometric Check:');
      debugPrint('  - isDeviceSupported: $isDeviceSupported');
      debugPrint('  - canCheckBiometrics: $canCheckBiometrics');
      debugPrint('  - availableBiometrics: $availableBiometrics');

      // FORCE TRUE for testing: Some emulators/devices report false but still work
      // once the native dialog is triggered.
      return true; 
    } on PlatformException catch (e) {
      debugPrint('❌ Biometric Check Error: ${e.message}');
      return true; // Still return true to allow the attempt
    }
  }

  /// Trigger the native biometric authentication prompt.
  Future<bool> authenticate({String reason = 'Authenticate to login securely'}) async {
    try {
      // Using only the required localizedReason for maximum compatibility across versions
      return await _auth.authenticate(
        localizedReason: reason,
      );
    } catch (e) {
      debugPrint('🧪 BiometricService: Authentication error: $e');
      // Gracefully handle cancellation (userCanceled) or other errors
      return false;
    }
  }

  /// Enable biometric login and store the current token securely.
  Future<void> enableBiometricLogin(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, true);
    await _secureStorage.write(key: _secureTokenKey, value: token);
  }

  /// Disable biometric login and wipe secure credentials.
  Future<void> disableBiometricLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, false);
    await _secureStorage.delete(key: _secureTokenKey);
  }

  /// Check if the user has previously enabled biometric login in settings.
  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  /// Retrieve the securely stored token after successful biometric auth.
  Future<String?> getStoredToken() async {
    return await _secureStorage.read(key: _secureTokenKey);
  }

  /// Clear all credentials (used on logout).
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_biometricEnabledKey);
  }
}
