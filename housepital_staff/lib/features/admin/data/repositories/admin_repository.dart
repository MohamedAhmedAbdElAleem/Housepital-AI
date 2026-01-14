import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/dashboard_stats.dart';
import '../models/user_model.dart';

class AdminRepository {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  Future<DashboardStats> getDashboardStats() async {
    try {
      final response = await _dio.get('/admin/insights');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return DashboardStats.fromJson(response.data['data']);
      }
      return DashboardStats.empty();
    } catch (e) {
      debugPrint('Error fetching dashboard stats: $e');
      return DashboardStats.empty();
    }
  }

  Future<List<UserModel>> getAllUsers({String? role, String? search}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (role != null && role != 'all') queryParams['role'] = role;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dio.get(
        '/admin/insights/all-users',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> usersJson = response.data['users'] ?? [];
        return usersJson.map((json) => UserModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching users: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getUserInsights({String period = 'week'}) async {
    try {
      final response = await _dio.get(
        '/admin/insights/users',
        queryParameters: {'period': period},
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] ?? {};
      }
      return {};
    } catch (e) {
      debugPrint('Error fetching user insights: $e');
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> getAuditLogs() async {
    try {
      final response = await _dio.get('/admin/insights/logs');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return List<Map<String, dynamic>>.from(response.data['logs'] ?? []);
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching audit logs: $e');
      return [];
    }
  }

  Future<List<UserModel>> getPendingVerifications() async {
    try {
      final response = await _dio.get(
        '/admin/insights/all-users',
        queryParameters: {'verificationStatus': 'pending'},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> usersJson = response.data['users'] ?? [];
        return usersJson.map((json) => UserModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching pending verifications: $e');
      return [];
    }
  }

  /// Returns a map with 'success', 'emailSent', and 'emailMessage' keys
  Future<Map<String, dynamic>> verifyUser(String userId,
      {bool approve = true}) async {
    try {
      final response = await _dio.patch(
        '/user/$userId/verify',
        data: {'status': approve ? 'approved' : 'rejected'},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'emailSent': response.data['emailSent'] ?? false,
          'emailMessage':
              response.data['emailMessage'] ?? 'Verification completed',
        };
      }
      return {
        'success': false,
        'emailSent': false,
        'emailMessage': 'Verification failed',
      };
    } catch (e) {
      debugPrint('Error verifying user: $e');
      return {
        'success': false,
        'emailSent': false,
        'emailMessage': 'Error: $e',
      };
    }
  }

  Future<bool> updateUser(
    String userId, {
    String? name,
    String? email,
    String? mobile,
    String? role,
    String? verificationStatus,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null && name.isNotEmpty) data['name'] = name;
      if (email != null && email.isNotEmpty) data['email'] = email;
      if (mobile != null && mobile.isNotEmpty) data['mobile'] = mobile;
      if (role != null) data['role'] = role;
      if (verificationStatus != null) {
        data['verificationStatus'] = verificationStatus;
        data['isVerified'] = verificationStatus == 'verified';
        if (verificationStatus == 'verified') {
          data['status'] = 'approved';
        } else if (verificationStatus == 'rejected') {
          data['status'] = 'rejected';
        } else if (verificationStatus == 'pending') {
          data['status'] = 'pending';
        }
      }

      final response = await _dio.patch(
        '/admin/insights/users/$userId',
        data: data,
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error updating user: $e');
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      final response = await _dio.delete('/admin/insights/users/$userId');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error deleting user: $e');
      return false;
    }
  }

  Future<bool> deactivateUser(
    String userId, {
    required DateTime startDate,
    required int durationDays,
    String? reason,
  }) async {
    try {
      final endDate = startDate.add(Duration(days: durationDays));
      final response = await _dio.patch(
        '/admin/insights/users/$userId/deactivate',
        data: {
          'isActive': false,
          'deactivation': {
            'startDate': startDate.toIso8601String(),
            'endDate': endDate.toIso8601String(),
            'durationDays': durationDays,
            'reason': reason ?? 'Administrative action',
          },
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error deactivating user: $e');
      return false;
    }
  }

  Future<bool> reactivateUser(String userId) async {
    try {
      final response = await _dio.patch(
        '/admin/insights/users/$userId/reactivate',
        data: {'isActive': true},
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error reactivating user: $e');
      return false;
    }
  }
}
