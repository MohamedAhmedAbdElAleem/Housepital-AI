import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/doctor_repository.dart';
import 'appointment_state.dart';

class AppointmentCubit extends Cubit<AppointmentState> {
  final DoctorRepository repository;

  AppointmentCubit({required this.repository}) : super(AppointmentInitial());

  Future<void> fetchAppointments() async {
    emit(AppointmentLoading());
    try {
      final appointments = await repository.getAppointments();
      emit(AppointmentLoaded(appointments));
    } catch (e) {
      emit(AppointmentError(e.toString()));
    }
  }
}
