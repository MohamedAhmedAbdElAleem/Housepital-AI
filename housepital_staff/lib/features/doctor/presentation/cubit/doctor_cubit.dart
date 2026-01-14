import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/doctor_model.dart';
import '../../data/models/clinic_model.dart';
import '../../domain/repositories/doctor_repository.dart';

import '../../../../core/error/exceptions.dart';

part 'doctor_state.dart';

class DoctorCubit extends Cubit<DoctorState> {
  final DoctorRepository repository;

  DoctorCubit({required this.repository}) : super(DoctorInitial());

  // Profile Management
  Future<void> fetchProfile() async {
    emit(DoctorLoading());
    try {
      final profile = await repository.getProfile();
      emit(DoctorProfileLoaded(profile));
    } on NotFoundException {
      // Profile not found is expected for new doctors
      emit(DoctorInitial());
    } catch (e) {
      emit(DoctorError(e.toString()));
    }
  }

  Future<void> createProfile(DoctorModel doctor) async {
    emit(DoctorLoading());
    try {
      final profile = await repository.createProfile(doctor);
      emit(DoctorProfileLoaded(profile));
    } catch (e) {
      emit(DoctorError(e.toString()));
    }
  }

  Future<void> updateProfile(DoctorModel doctor) async {
    emit(DoctorLoading());
    try {
      final profile = await repository.updateProfile(doctor);
      emit(DoctorProfileLoaded(profile));
    } catch (e) {
      emit(DoctorError(e.toString()));
    }
  }

  // Clinic Management
  Future<void> fetchClinics() async {
    emit(DoctorLoading());
    try {
      final clinics = await repository.getMyClinics();
      emit(DoctorClinicsLoaded(clinics));
    } catch (e) {
      emit(DoctorError(e.toString()));
    }
  }

  Future<void> addClinic(ClinicModel clinic) async {
    emit(DoctorLoading());
    try {
      await repository.addClinic(clinic);
      // Refresh list after adding
      final clinics = await repository.getMyClinics();
      emit(DoctorClinicsLoaded(clinics));
    } catch (e) {
      emit(DoctorError(e.toString()));
    }
  }

  Future<void> updateClinic(ClinicModel clinic) async {
    emit(DoctorLoading());
    try {
      await repository.updateClinic(clinic);
      // Refresh list after update
      final clinics = await repository.getMyClinics();
      emit(DoctorClinicsLoaded(clinics));
    } catch (e) {
      emit(DoctorError(e.toString()));
    }
  }

  Future<void> deleteClinic(String clinicId) async {
    emit(DoctorLoading());
    try {
      await repository.deleteClinic(clinicId);
      // Refresh list after delete
      final clinics = await repository.getMyClinics();
      emit(DoctorClinicsLoaded(clinics));
    } catch (e) {
      emit(DoctorError(e.toString()));
    }
  }
}
