import '../datasources/nurse_remote_datasource.dart';
import '../models/nurse_profile_model.dart';

abstract class NurseRepository {
  Future<NurseProfile> getProfile();
  Future<NurseProfile> updateProfile(Map<String, dynamic> data);
  Future<NurseProfile> submitForReview();
  Future<ProfileStatus> getProfileStatus();
  Future<String> uploadDocument(String filePath, String documentType);
}

class NurseRepositoryImpl implements NurseRepository {
  final NurseRemoteDataSource remoteDataSource;

  NurseRepositoryImpl({required this.remoteDataSource});

  @override
  Future<NurseProfile> getProfile() async {
    return await remoteDataSource.getProfile();
  }

  @override
  Future<NurseProfile> updateProfile(Map<String, dynamic> data) async {
    return await remoteDataSource.updateProfile(data);
  }

  @override
  Future<NurseProfile> submitForReview() async {
    return await remoteDataSource.submitForReview();
  }

  @override
  Future<ProfileStatus> getProfileStatus() async {
    return await remoteDataSource.getProfileStatus();
  }

  @override
  Future<String> uploadDocument(String filePath, String documentType) async {
    return await remoteDataSource.uploadDocument(filePath, documentType);
  }
}
