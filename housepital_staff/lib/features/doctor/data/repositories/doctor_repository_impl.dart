import 'dart:io';
import '../../domain/repositories/doctor_repository.dart';
import '../../data/models/appointment_model.dart';
import '../../data/datasources/doctor_remote_datasource.dart';
import '../../data/models/doctor_model.dart';
import '../../data/models/clinic_model.dart';
import '../../data/models/service_model.dart';

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

  @override
  Future<ServiceModel> addService(ServiceModel service) async {
    return await remoteDataSource.addService(service);
  }

  @override
  Future<List<ServiceModel>> getMyServices() async {
    return await remoteDataSource.getMyServices();
  }

  @override
  Future<ServiceModel> updateService(ServiceModel service) async {
    return await remoteDataSource.updateService(service);
  }

  @override
  Future<void> deleteService(String serviceId) async {
    return await remoteDataSource.deleteService(serviceId);
  }
  @override
  Future<List<AppointmentModel>> getAppointments() async {
    return await remoteDataSource.getAppointments();
  }
}
