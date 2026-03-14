part of 'appointment_cubit.dart';

abstract class AppointmentState {}

class AppointmentInitial extends AppointmentState {}

class AppointmentLoading extends AppointmentState {}

class AppointmentLoaded extends AppointmentState {
  final List<dynamic> pending;   // slot bookings awaiting doctor confirm
  final List<dynamic> upcoming;  // confirmed future bookings
  final List<dynamic> past;      // completed / cancelled

  AppointmentLoaded({
    required this.pending,
    required this.upcoming,
    required this.past,
  });
}

class AppointmentActionSuccess extends AppointmentState {
  final String message;
  AppointmentActionSuccess(this.message);
}

class AppointmentError extends AppointmentState {
  final String message;
  AppointmentError(this.message);
}
