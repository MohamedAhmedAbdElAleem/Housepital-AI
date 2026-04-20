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
      final data = response['data'] as List<dynamic>;
      emit(AdminDoctorsLoaded(data.cast<Map<String, dynamic>>()));
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
}
