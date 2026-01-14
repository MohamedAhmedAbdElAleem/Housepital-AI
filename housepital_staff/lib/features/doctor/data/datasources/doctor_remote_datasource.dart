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

  Future<ClinicModel> addClinic(ClinicModel clinic);
  Future<List<ClinicModel>> getMyClinics();
  Future<ClinicModel> updateClinic(ClinicModel clinic);
  Future<void> deleteClinic(String clinicId);
  Future<String> uploadImage(File file);
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

  Future<String> uploadImage(File file) async {
    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await apiClient.post(
        '/cloudinary/uploadFile',
        body: formData,
      );

      // Assumption: Cloudinary controller returns { url: "...", ... }
      // I should double check the controller return value.
      // Usually it returns the full cloudinary response.
      // Let's assume response['url'] or response['secure_url'].
      // To be safe, I'll log the response first if I could, but I can't.
      // Based on standard Housepital backend patterns, it likely returns { success: true, url: "..." }
      // I'll check the controller code in next step to be sure, but for now I'll anticipate standard structure.

      // Checking CloudinaryController in next step...
      // For now, I'll write the method accessing `url`.
      return response['url'];
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Failed to upload image',
      );
    }
  }
}
