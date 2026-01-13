import '../datasources/profile_remote_datasource.dart';

class MedicalInfoResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? medicalInfo;

  MedicalInfoResponse({
    required this.success,
    required this.message,
    this.medicalInfo,
  });

  factory MedicalInfoResponse.fromJson(Map<String, dynamic> json) {
    return MedicalInfoResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      medicalInfo: json['medicalInfo'],
    );
  }
}

class IdUploadResponse {
  final bool success;
  final String message;
  final String? imageUrl;
  final String? verificationStatus;

  IdUploadResponse({
    required this.success,
    required this.message,
    this.imageUrl,
    this.verificationStatus,
  });

  factory IdUploadResponse.fromJson(Map<String, dynamic> json) {
    return IdUploadResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      imageUrl: json['imageUrl'],
      verificationStatus: json['verificationStatus'],
    );
  }
}

class VerificationStatusResponse {
  final bool success;
  final String verificationStatus;
  final bool hasFrontId;
  final bool hasBackId;
  final String? rejectionReason;

  VerificationStatusResponse({
    required this.success,
    required this.verificationStatus,
    required this.hasFrontId,
    required this.hasBackId,
    this.rejectionReason,
  });

  factory VerificationStatusResponse.fromJson(Map<String, dynamic> json) {
    return VerificationStatusResponse(
      success: json['success'] ?? false,
      verificationStatus: json['verificationStatus'] ?? 'unverified',
      hasFrontId: json['hasFrontId'] ?? false,
      hasBackId: json['hasBackId'] ?? false,
      rejectionReason: json['rejectionReason'],
    );
  }
}

class ProfileRepositoryImpl {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  Future<MedicalInfoResponse> updateMedicalInfo({
    String? bloodType,
    List<String>? chronicDiseases,
    List<String>? allergies,
    String? otherConditions,
    String? currentMedications,
    bool? hasNoChronicDiseases,
    bool? hasNoAllergies,
  }) async {
    final response = await remoteDataSource.updateMedicalInfo(
      bloodType: bloodType,
      chronicDiseases: chronicDiseases,
      allergies: allergies,
      otherConditions: otherConditions,
      currentMedications: currentMedications,
      hasNoChronicDiseases: hasNoChronicDiseases,
      hasNoAllergies: hasNoAllergies,
    );
    return MedicalInfoResponse.fromJson(response);
  }

  Future<MedicalInfoResponse> getMedicalInfo() async {
    final response = await remoteDataSource.getMedicalInfo();
    return MedicalInfoResponse.fromJson(response);
  }

  Future<IdUploadResponse> uploadIdDocument({
    required String side,
    required String imageBase64,
  }) async {
    final response = await remoteDataSource.uploadIdDocument(
      side: side,
      imageBase64: imageBase64,
    );
    return IdUploadResponse.fromJson(response);
  }

  Future<VerificationStatusResponse> getVerificationStatus() async {
    final response = await remoteDataSource.getVerificationStatus();
    return VerificationStatusResponse.fromJson(response);
  }

  Future<MedicalInfoResponse> completeProfileSetup({
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
    final response = await remoteDataSource.completeProfileSetup(
      bloodType: bloodType,
      chronicDiseases: chronicDiseases,
      allergies: allergies,
      otherConditions: otherConditions,
      currentMedications: currentMedications,
      hasNoChronicDiseases: hasNoChronicDiseases,
      hasNoAllergies: hasNoAllergies,
      idFrontImage: idFrontImage,
      idBackImage: idBackImage,
    );
    return MedicalInfoResponse.fromJson(response);
  }
}
