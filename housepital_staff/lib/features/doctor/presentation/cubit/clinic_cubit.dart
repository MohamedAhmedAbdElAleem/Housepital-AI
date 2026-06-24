import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/clinic_model.dart';
import '../../domain/repositories/doctor_repository.dart';

// ─── States ───────────────────────────────────────────────────────────────────

abstract class ClinicState {}

class ClinicInitial extends ClinicState {}

class ClinicLoading extends ClinicState {}

class ClinicLoaded extends ClinicState {
  final List<ClinicModel> clinics;
  ClinicLoaded(this.clinics);
}

class ClinicError extends ClinicState {
  final String message;
  ClinicError(this.message);
}

// ─── Cubit ────────────────────────────────────────────────────────────────────

class ClinicCubit extends Cubit<ClinicState> {
  final DoctorRepository repository;

  ClinicCubit({required this.repository}) : super(ClinicInitial());

  Future<void> fetchClinics() async {
    emit(ClinicLoading());
    try {
      final clinics = await repository.getMyClinics();
      emit(ClinicLoaded(clinics));
    } catch (e) {
      emit(ClinicError(e.toString()));
    }
  }

  Future<void> addClinic(ClinicModel clinic) async {
    emit(ClinicLoading());
    try {
      await repository.addClinic(clinic);
      final clinics = await repository.getMyClinics();
      emit(ClinicLoaded(clinics));
    } catch (e) {
      emit(ClinicError(e.toString()));
    }
  }

  Future<void> updateClinic(ClinicModel clinic) async {
    emit(ClinicLoading());
    try {
      await repository.updateClinic(clinic);
      final clinics = await repository.getMyClinics();
      emit(ClinicLoaded(clinics));
    } catch (e) {
      emit(ClinicError(e.toString()));
    }
  }

  Future<void> deleteClinic(String clinicId) async {
    emit(ClinicLoading());
    try {
      await repository.deleteClinic(clinicId);
      final clinics = await repository.getMyClinics();
      emit(ClinicLoaded(clinics));
    } catch (e) {
      emit(ClinicError(e.toString()));
    }
  }
}
