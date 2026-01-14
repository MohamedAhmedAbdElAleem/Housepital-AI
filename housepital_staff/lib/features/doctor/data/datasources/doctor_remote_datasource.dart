import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/error/exceptions.dart';
import '../models/doctor_model.dart';
import '../models/clinic_model.dart';

abstract class DoctorRemoteDataSource {
  Future<DoctorModel> createProfile(DoctorModel doctor);
  Future<DoctorModel> getProfile();
  Future<DoctorModel> updateProfile(DoctorModel doctor);

  Future<ClinicModel> addClinic(ClinicModel clinic);
  Future<List<ClinicModel>> getMyClinics();
  Future<ClinicModel> updateClinic(ClinicModel clinic);
  Future<void> deleteClinic(String clinicId);
}

class DoctorRemoteDataSourceImpl implements DoctorRemoteDataSource {
  final ApiClient apiClient;

  DoctorRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<DoctorModel> createProfile(DoctorModel doctor) async {
    try {
      final response = await apiClient.post(
        '/doctors/profile',
        body: doctor.toJson(),
      );
      return DoctorModel.fromJson(response['data']);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Failed to create profile',
      );
    }
  }

  @override
  Future<DoctorModel> getProfile() async {
    try {
      final response = await apiClient.get('/doctors/profile');
      return DoctorModel.fromJson(response['data']);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Failed to fetch profile',
      );
    }
  }

  @override
  Future<DoctorModel> updateProfile(DoctorModel doctor) async {
    try {
      final response = await apiClient.put(
        '/doctors/profile',
        body: doctor.toJson(),
      );
      return DoctorModel.fromJson(response['data']);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Failed to update profile',
      );
    }
  }

  @override
  Future<ClinicModel> addClinic(ClinicModel clinic) async {
    try {
      final response = await apiClient.post('/clinics', body: clinic.toJson());
      return ClinicModel.fromJson(response['data']);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Failed to add clinic',
      );
    }
  }

  @override
  Future<List<ClinicModel>> getMyClinics() async {
    try {
      final response = await apiClient.get('/clinics/my-clinics');
      final List<dynamic> data = response['data'];
      return data.map((e) => ClinicModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Failed to fetch clinics',
      );
    }
  }

  @override
  Future<ClinicModel> updateClinic(ClinicModel clinic) async {
    try {
      final response = await apiClient.put(
        '/clinics/${clinic.id}',
        body: clinic.toJson(),
      );
      return ClinicModel.fromJson(response['data']);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Failed to update clinic',
      );
    }
  }

  @override
  Future<void> deleteClinic(String clinicId) async {
    try {
      await apiClient.delete('/clinics/$clinicId');
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Failed to delete clinic',
      );
    }
  }
}
