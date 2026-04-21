import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TokenManager {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';
  static const String _rememberMeKey = 'remember_me';
  static const String _savedEmailKey = 'saved_email';
  static const String _onboardingSeenKey = 'onboarding_seen';

  // ========== Token Management ==========
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<bool> hasToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_tokenKey);
  }

  // ========== User ID Management ==========
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  static Future<void> deleteUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
  }

  // ========== User Role Management ==========
  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  static Future<void> saveUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userRoleKey, role);
  }

  static Future<void> deleteUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userRoleKey);
  }

  // ========== Doctor Verification Status ==========
  static const String _verificationStatusKey = 'verification_status';
  static const String _hasProfileKey = 'has_profile';
  static const String _rejectionReasonKey = 'rejection_reason';

  static Future<void> saveVerificationStatus(String status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_verificationStatusKey, status);
  }

  static Future<String?> getVerificationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_verificationStatusKey);
  }

  static Future<void> saveHasProfile(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasProfileKey, value);
  }

  static Future<bool> getHasProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasProfileKey) ?? false;
  }

  static Future<void> saveRejectionReason(String? reason) async {
    final prefs = await SharedPreferences.getInstance();
    if (reason != null) {
      await prefs.setString(_rejectionReasonKey, reason);
    } else {
      await prefs.remove(_rejectionReasonKey);
    }
  }

  static Future<String?> getRejectionReason() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_rejectionReasonKey);
  }

  static Future<void> deleteVerificationData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hasProfileKey);
    await prefs.remove(_verificationStatusKey);
    await prefs.remove(_rejectionReasonKey);
  }

  // ========== Remember Me ==========
  static Future<void> setRememberMe(bool value, {String? email}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, value);
    if (value && email != null) {
      await prefs.setString(_savedEmailKey, email);
    } else if (!value) {
      await prefs.remove(_savedEmailKey);
    }
  }

  static Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }

  static Future<String?> getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_savedEmailKey);
  }

  // ========== Onboarding / First Launch ==========
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return !prefs.containsKey(_onboardingSeenKey);
  }

  static Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingSeenKey, true);
  }

  // ========== JWT Token Decode ==========
  static Map<String, dynamic>? decodeToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      return json.decode(decoded) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getUserFromToken() async {
    final token = await getToken();
    if (token == null) return null;
    return decodeToken(token);
  }
}
