import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/nurse_profile_model.dart';

abstract class NurseRemoteDataSource {
  Future<NurseProfile> getProfile();
  Future<NurseProfile> updateProfile(Map<String, dynamic> data);
  Future<NurseProfile> submitForReview();
  Future<ProfileStatus> getProfileStatus();
  Future<String> uploadDocument(String filePath, String documentType);
}

class NurseRemoteDataSourceImpl implements NurseRemoteDataSource {
  final ApiClient apiClient;

  NurseRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<NurseProfile> getProfile() async {
    try {
      print('📥 Fetching nurse profile...');
      final response = await apiClient.get(ApiConstants.nurseProfile);
      print('✅ Profile fetched successfully');

      final responseData = response is String ? jsonDecode(response) : response;
      return NurseProfile.fromJson(responseData['nurse']);
    } catch (e) {
      print('❌ Error fetching profile: $e');
      rethrow;
    }
  }

  @override
  Future<NurseProfile> updateProfile(Map<String, dynamic> data) async {
    try {
      print('📤 Updating nurse profile...');
      print('   Data: $data');
      final response = await apiClient.post(
        ApiConstants.nurseProfile,
        body: data,
      );
      print('✅ Profile updated successfully');

      // Handle response if it's a string, though Dio usually parses JSON
      final responseData = response is String ? jsonDecode(response) : response;

      return NurseProfile.fromJson(responseData['nurse']);
    } catch (e) {
      print('❌ Error updating profile: $e');
      rethrow;
    }
  }

  @override
  Future<NurseProfile> submitForReview() async {
    try {
      print('📤 Submitting profile for review...');
      final response = await apiClient.post(
        ApiConstants.nurseProfileSubmit,
        body: {},
      );
      print('✅ Profile submitted successfully');
      final responseData = response is String ? jsonDecode(response) : response;
      return NurseProfile.fromJson(responseData['nurse']);
    } catch (e) {
      print('❌ Error submitting profile: $e');
      rethrow;
    }
  }

  @override
  Future<ProfileStatus> getProfileStatus() async {
    try {
      print('[DATASOURCE] 📡 GET /api/nurse/profile/status');
      final response = await apiClient.get(ApiConstants.nurseProfileStatus);
      final responseData = response is String ? jsonDecode(response) : response;
      print('[DATASOURCE] 📥 Raw response from server: $responseData');
      return ProfileStatus.fromJson(responseData);
    } catch (e) {
      print('[DATASOURCE] ❌ Error in getProfileStatus: $e');
      rethrow;
    }
  }

  @override
  Future<String> uploadDocument(String filePath, String documentType) async {
    try {
      print('📤 Uploading document: $documentType');
      print('   File: $filePath');

      final fileName = filePath.split(RegExp(r'[\\/]+')).last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
        'folder': _resolveCloudinaryFolder(documentType),
      });

      final response = await apiClient.postFormData(
        ApiConstants.cloudinaryUpload,
        formData,
      );
      final responseData = response is String ? jsonDecode(response) : response;
      final url = responseData['data']?['url'] as String?;

      if (url == null || url.isEmpty) {
        throw Exception('Upload succeeded but returned URL is missing');
      }

      print('✅ Document uploaded: $url');
      return url;
    } catch (e) {
      print('❌ Error uploading document: $e');
      rethrow;
    }
  }

  String _resolveCloudinaryFolder(String documentType) {
    switch (documentType) {
      case 'national_id':
        return 'ID_DOCUMENTS';
      case 'degree':
      case 'license':
        return 'MEDICAL_RECORDS';
      default:
        return 'GENERAL';
    }
  }
}
