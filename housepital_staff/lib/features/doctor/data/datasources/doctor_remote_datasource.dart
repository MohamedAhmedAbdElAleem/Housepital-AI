import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/error/exceptions.dart';
import '../models/doctor_model.dart';
import '../models/clinic_model.dart';
import '../models/service_model.dart';

abstract class DoctorRemoteDataSource {
  Future<DoctorModel> createProfile(DoctorModel doctor);
  Future<DoctorModel> getProfile();
  Future<DoctorModel> updateProfile(DoctorModel doctor);
  Future<String> uploadImage(File file);

  Future<ClinicModel> addClinic(ClinicModel clinic);
  Future<List<ClinicModel>> getMyClinics();
  Future<ClinicModel> updateClinic(ClinicModel clinic);
  Future<void> deleteClinic(String clinicId);

  Future<List<ServiceModel>> getMyServices();
  Future<ServiceModel> addService(ServiceModel service);
  Future<ServiceModel> updateService(ServiceModel service);
  Future<void> deleteService(String serviceId);
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
  Future<String> uploadImage(File file) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(file.path),
      });
      final response = await apiClient.postFormData(
        '/doctors/upload',
        formData,
      );
      return response['data']['url'] as String;
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Failed to upload image',
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

  @override
  Future<List<ServiceModel>> getMyServices() async {
    try {
      final response = await apiClient.get('/services/my-services');
      final List<dynamic> data = response['data'];
      return data.map((e) => ServiceModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Failed to fetch services',
      );
    }
  }

  @override
  Future<ServiceModel> addService(ServiceModel service) async {
    try {
      final response = await apiClient.post(
        '/services',
        body: service.toJson(),
      );
      return ServiceModel.fromJson(response['data']);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Failed to add service',
      );
    }
  }

  @override
  Future<ServiceModel> updateService(ServiceModel service) async {
    try {
      final response = await apiClient.put(
        '/services/${service.id}',
        body: service.toJson(),
      );
      return ServiceModel.fromJson(response['data']);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Failed to update service',
      );
    }
  }

  @override
  Future<void> deleteService(String serviceId) async {
    try {
      await apiClient.delete('/services/$serviceId');
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Failed to delete service',
      );
    }
  }
}
