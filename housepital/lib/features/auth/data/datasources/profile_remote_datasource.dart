import '../../../../core/network/api_service.dart';

abstract class ProfileRemoteDataSource {
  Future<Map<String, dynamic>> updateMedicalInfo({
    String? bloodType,
    List<String>? chronicDiseases,
    List<String>? allergies,
    String? otherConditions,
    String? currentMedications,
    bool? hasNoChronicDiseases,
    bool? hasNoAllergies,
  });

  Future<Map<String, dynamic>> getMedicalInfo();

  /// Upload ID document - either as base64 or Cloudinary URL
  /// [side] - 'front' or 'back'
  /// [imageBase64] - Base64 encoded image (deprecated, use imageUrl)
  /// [imageUrl] - Cloudinary URL (preferred)
  /// [publicId] - Cloudinary public ID for deletion
  Future<Map<String, dynamic>> uploadIdDocument({
    required String side,
    String? imageBase64,
    String? imageUrl,
    String? publicId,
  });

  Future<Map<String, dynamic>> getVerificationStatus();

  Future<Map<String, dynamic>> completeProfileSetup({
    String? bloodType,
    List<String>? chronicDiseases,
    List<String>? allergies,
    String? otherConditions,
    String? currentMedications,
    bool? hasNoChronicDiseases,
    bool? hasNoAllergies,
    String? idFrontImage,
    String? idBackImage,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiService apiService;

  ProfileRemoteDataSourceImpl({required this.apiService});

  @override
  Future<Map<String, dynamic>> updateMedicalInfo({
    String? bloodType,
    List<String>? chronicDiseases,
    List<String>? allergies,
    String? otherConditions,
    String? currentMedications,
    bool? hasNoChronicDiseases,
    bool? hasNoAllergies,
  }) async {
    final body = <String, dynamic>{};

    if (bloodType != null) body['bloodType'] = bloodType;
    if (chronicDiseases != null) body['chronicDiseases'] = chronicDiseases;
    if (allergies != null) body['allergies'] = allergies;
    if (otherConditions != null) body['otherConditions'] = otherConditions;
    if (currentMedications != null) {
      body['currentMedications'] = currentMedications;
    }
    if (hasNoChronicDiseases != null) {
      body['hasNoChronicDiseases'] = hasNoChronicDiseases;
    }
    if (hasNoAllergies != null) body['hasNoAllergies'] = hasNoAllergies;

    final response = await apiService.put('/profile/medical-info', body: body);
    return response as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> getMedicalInfo() async {
    final response = await apiService.get('/profile/medical-info');
    return response as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> uploadIdDocument({
    required String side,
    String? imageBase64,
    String? imageUrl,
    String? publicId,
  }) async {
    final body = <String, dynamic>{'side': side};

    // Prefer URL over base64
    if (imageUrl != null) {
      body['imageUrl'] = imageUrl;
      if (publicId != null) body['publicId'] = publicId;
    } else if (imageBase64 != null) {
      body['imageBase64'] = imageBase64;
    }

    final response = await apiService.post(
      '/api/profile/upload-id',
      body: body,
    );
    return response as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> getVerificationStatus() async {
    final response = await apiService.get('/profile/verification-status');
    return response as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> completeProfileSetup({
    String? bloodType,
    List<String>? chronicDiseases,
    List<String>? allergies,
    String? otherConditions,
    String? currentMedications,
    bool? hasNoChronicDiseases,
    bool? hasNoAllergies,
    String? idFrontImage,
    String? idBackImage,
  }) async {
    final body = <String, dynamic>{};

    if (bloodType != null) body['bloodType'] = bloodType;
    if (chronicDiseases != null) body['chronicDiseases'] = chronicDiseases;
    if (allergies != null) body['allergies'] = allergies;
    if (otherConditions != null) body['otherConditions'] = otherConditions;
    if (currentMedications != null) {
      body['currentMedications'] = currentMedications;
    }
    if (hasNoChronicDiseases != null) {
      body['hasNoChronicDiseases'] = hasNoChronicDiseases;
    }
    if (hasNoAllergies != null) body['hasNoAllergies'] = hasNoAllergies;
    if (idFrontImage != null) body['idFrontImage'] = idFrontImage;
    if (idBackImage != null) body['idBackImage'] = idBackImage;

    final response = await apiService.post(
      '/profile/complete-setup',
      body: body,
    );
    return response as Map<String, dynamic>;
  }
}
