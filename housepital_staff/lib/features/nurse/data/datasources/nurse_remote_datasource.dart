import 'dart:io';
import 'dart:convert';
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
      print('📥 Fetching profile status...');
      final response = await apiClient.get(ApiConstants.nurseProfileStatus);
      print('✅ Status fetched: ${response is String ? jsonDecode(response)['profileStatus'] ?? jsonDecode(response)['status'] : response['profileStatus'] ?? response['status']}');
      final responseData = response is String ? jsonDecode(response) : response;
      return ProfileStatus.fromJson(responseData);
    } catch (e) {
      print('❌ Error fetching status: $e');
      rethrow;
    }
  }

  @override
  Future<String> uploadDocument(String filePath, String documentType) async {
    try {
      print('📤 Uploading document: $documentType');
      print('   File: $filePath');

      // Read file as base64
      final bytes = await _readFileAsBytes(filePath);
      final base64Image = _base64Encode(bytes);

      final response = await apiClient.post(
        ApiConstants.cloudinaryUpload,
        body: {
          'file': 'data:image/jpeg;base64,$base64Image',
          'folder': 'nurse_documents/$documentType',
        },
      );

      final url = response['secure_url'] as String;
      print('✅ Document uploaded: $url');
      return url;
    } catch (e) {
      print('❌ Error uploading document: $e');
      rethrow;
    }
  }

  Future<List<int>> _readFileAsBytes(String filePath) async {
    return await File(filePath).readAsBytes();
  }

  String _base64Encode(List<int> bytes) {
    return base64Encode(bytes);
  }
}
