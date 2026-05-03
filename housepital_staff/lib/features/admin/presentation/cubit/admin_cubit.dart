import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';

// States
abstract class AdminState {}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminDoctorsLoaded extends AdminState {
  final List<Map<String, dynamic>> doctors;
  AdminDoctorsLoaded(this.doctors);
}

class AdminClinicsLoaded extends AdminState {
  final List<Map<String, dynamic>> clinics;
  AdminClinicsLoaded(this.clinics);
}

class AdminInsightsLoaded extends AdminState {
  final Map<String, dynamic> insights;
  AdminInsightsLoaded(this.insights);
}

class AdminAllUsersLoaded extends AdminState {
  final List<dynamic> users;
  AdminAllUsersLoaded(this.users);
}

class AdminSettingsLoaded extends AdminState {
  final Map<String, dynamic> settings;
  AdminSettingsLoaded(this.settings);
}

class AdminBookingsLoaded extends AdminState {
  final List<dynamic> bookings;
  final Map<String, dynamic>? pagination;
  AdminBookingsLoaded(this.bookings, {this.pagination});
}

class AdminError extends AdminState {
  final String message;
  AdminError(this.message);
}

class AdminActionSuccess extends AdminState {
  final String message;
  AdminActionSuccess(this.message);
}

// Cubit
class AdminCubit extends Cubit<AdminState> {
  final ApiClient apiClient;

  AdminCubit({required this.apiClient}) : super(AdminInitial());

  Future<void> fetchDoctors({String status = 'pending'}) async {
    emit(AdminLoading());
    try {
      final response = await apiClient.get('/doctors/pending?status=$status');
      final data = response['data'] is List ? response['data'] as List : [];
      emit(AdminDoctorsLoaded(List<Map<String, dynamic>>.from(data)));
    } on DioException catch (e) {
      emit(AdminError(e.response?.data['message'] ?? 'Failed to load doctors'));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> approveDoctor(String doctorId) async {
    try {
      final response = await apiClient.put(
        '/doctors/$doctorId/verify',
        body: {'action': 'approve'},
      );
      emit(AdminActionSuccess(response['message'] ?? 'Doctor approved'));
    } on DioException catch (e) {
      emit(AdminError(e.response?.data['message'] ?? 'Failed to approve'));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> rejectDoctor(String doctorId, String reason) async {
    try {
      final response = await apiClient.put(
        '/doctors/$doctorId/verify',
        body: {'action': 'reject', 'rejectionReason': reason},
      );
      emit(AdminActionSuccess(response['message'] ?? 'Doctor rejected'));
    } on DioException catch (e) {
      emit(AdminError(e.response?.data['message'] ?? 'Failed to reject'));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> fetchClinics({String status = 'pending'}) async {
    emit(AdminLoading());
    try {
      final response = await apiClient.get('/clinics/pending?status=$status');
      final data = response['data'] is List ? response['data'] as List : [];
      emit(AdminClinicsLoaded(List<Map<String, dynamic>>.from(data)));
    } on DioException catch (e) {
      emit(AdminError(e.response?.data['message'] ?? 'Failed to load clinics'));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> approveClinic(String clinicId) async {
    try {
      final response = await apiClient.put(
        '/clinics/$clinicId/verify',
        body: {'action': 'approve'},
      );
      emit(AdminActionSuccess(response['message'] ?? 'Clinic approved'));
    } on DioException catch (e) {
      emit(AdminError(e.response?.data['message'] ?? 'Failed to approve clinic'));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> rejectClinic(String clinicId, String reason) async {
    try {
      final response = await apiClient.put(
        '/clinics/$clinicId/verify',
        body: {'action': 'reject', 'rejectionReason': reason},
      );
      emit(AdminActionSuccess(response['message'] ?? 'Clinic rejected'));
    } on DioException catch (e) {
      emit(AdminError(e.response?.data['message'] ?? 'Failed to reject clinic'));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> fetchDashboardInsights() async {
    emit(AdminLoading());
    try {
      final response = await apiClient.get('/admin/insights');
      emit(AdminInsightsLoaded(response['data'] ?? response));
    } on DioException catch (e) {
      emit(AdminError(e.response?.data['message'] ?? 'Failed to load insights'));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> fetchAllUsers() async {
    emit(AdminLoading());
    try {
      final response = await apiClient.get('/admin/insights/all-users');
      emit(AdminAllUsersLoaded(response['users'] ?? response['data'] ?? []));
    } on DioException catch (e) {
      emit(AdminError(e.response?.data['message'] ?? 'Failed to load users'));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> addStaff(Map<String, dynamic> staffData) async {
    emit(AdminLoading());
    try {
      final response = await apiClient.post('/admin/insights/staff', body: staffData);
      emit(AdminActionSuccess(response['message'] ?? 'Staff added successfully'));
    } on DioException catch (e) {
      emit(AdminError(e.response?.data['message'] ?? 'Failed to add staff'));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> updateUserStatus(String userId, String status) async {
    try {
      final response = await apiClient.patch(
        '/admin/insights/user/$userId/status',
        body: {'status': status},
      );
      emit(AdminActionSuccess(response['message'] ?? 'Status updated'));
    } on DioException catch (e) {
      emit(AdminError(e.response?.data['message'] ?? 'Failed to update status'));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> fetchAllBookings({String? status, String? type, int page = 1}) async {
    emit(AdminLoading());
    try {
      String path = '/bookings/admin/all?page=$page';
      if (status != null && status.isNotEmpty) path += '&status=$status';
      if (type != null && type.isNotEmpty) path += '&type=$type';

      final response = await apiClient.get(path);
      emit(AdminBookingsLoaded(
        response['bookings'] ?? response['data'] ?? [],
        pagination: response['pagination'],
      ));
    } on DioException catch (e) {
      emit(AdminError(e.response?.data['message'] ?? 'Failed to load bookings'));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> fetchSettings() async {
    emit(AdminLoading());
    try {
      final response = await apiClient.get('/settings');
      emit(AdminSettingsLoaded(response['settings'] ?? {}));
    } on DioException catch (e) {
      emit(AdminError(e.response?.data['message'] ?? 'Failed to load settings'));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> updateSettings(Map<String, dynamic> settingsData) async {
    try {
      final response = await apiClient.patch('/settings', body: settingsData);
      // Re-fetch to get latest state
      fetchSettings();
    } on DioException catch (e) {
      emit(AdminError(e.response?.data['message'] ?? 'Failed to update settings'));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    emit(AdminLoading());
    try {
      await apiClient.put(
        '/user/change-password',
        body: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
      emit(AdminActionSuccess('Password changed successfully'));
    } on DioException catch (e) {
      emit(AdminError(e.response?.data['message'] ?? 'Failed to change password'));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }
}
