import 'dart:io';
import '../../domain/repositories/doctor_repository.dart';
import '../../data/datasources/doctor_remote_datasource.dart';
import '../../data/models/doctor_model.dart';
import '../../data/models/clinic_model.dart';

class DoctorRepositoryImpl implements DoctorRepository {
  final DoctorRemoteDataSource remoteDataSource;

  DoctorRepositoryImpl({required this.remoteDataSource});

  @override
  Future<DoctorModel> createProfile(DoctorModel doctor) async {
    return await remoteDataSource.createProfile(doctor);
  }

  @override
  Future<DoctorModel> getProfile() async {
    return await remoteDataSource.getProfile();
  }

  @override
  Future<DoctorModel> updateProfile(DoctorModel doctor) async {
    return await remoteDataSource.updateProfile(doctor);
  }

  @override
  Future<ClinicModel> addClinic(ClinicModel clinic) async {
    return await remoteDataSource.addClinic(clinic);
  }

  @override
  Future<List<ClinicModel>> getMyClinics() async {
    return await remoteDataSource.getMyClinics();
  }

  @override
  Future<ClinicModel> updateClinic(ClinicModel clinic) async {
    return await remoteDataSource.updateClinic(clinic);
  }

  @override
  Future<void> deleteClinic(String clinicId) async {
    return await remoteDataSource.deleteClinic(clinicId);
  }

  @override
  Future<String> uploadImage(File file) async {
    return await remoteDataSource.uploadImage(file);
  }
}
