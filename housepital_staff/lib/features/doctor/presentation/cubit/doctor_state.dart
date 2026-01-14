part of 'doctor_cubit.dart';

abstract class DoctorState {}

class DoctorInitial extends DoctorState {}

class DoctorLoading extends DoctorState {}

class DoctorProfileLoaded extends DoctorState {
  final DoctorModel profile;
  DoctorProfileLoaded(this.profile);
}

class DoctorClinicsLoaded extends DoctorState {
  final List<ClinicModel> clinics;
  DoctorClinicsLoaded(this.clinics);
}

class DoctorOperationSuccess extends DoctorState {
  final String message;
  DoctorOperationSuccess(this.message);
}

class DoctorError extends DoctorState {
  final String message;
  DoctorError(this.message);
}
