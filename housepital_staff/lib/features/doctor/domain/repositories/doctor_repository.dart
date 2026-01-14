import 'dart:io';
import '../../data/models/appointment_model.dart';
import '../../data/models/doctor_model.dart';
import '../../data/models/clinic_model.dart';
import '../../data/models/service_model.dart';

abstract class DoctorRepository {
  Future<DoctorModel> createProfile(DoctorModel doctor);
  Future<DoctorModel> getProfile();
  Future<DoctorModel> updateProfile(DoctorModel doctor);

  Future<ClinicModel> addClinic(ClinicModel clinic);
  Future<List<ClinicModel>> getMyClinics();
  Future<ClinicModel> updateClinic(ClinicModel clinic);
  Future<void> deleteClinic(String clinicId);
  Future<String> uploadImage(File file);

  // Services
  Future<ServiceModel> addService(ServiceModel service);
  Future<List<ServiceModel>> getMyServices();
  Future<ServiceModel> updateService(ServiceModel service);
  Future<void> deleteService(String serviceId);

  // Appointments
  Future<List<AppointmentModel>> getAppointments();
}
