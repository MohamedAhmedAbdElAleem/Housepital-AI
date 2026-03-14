import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_client.dart';

part 'appointment_state.dart';

class AppointmentCubit extends Cubit<AppointmentState> {
  final ApiClient _api;

  AppointmentCubit({ApiClient? apiClient})
      : _api = apiClient ?? ApiClient(),
        super(AppointmentInitial());

  Future<void> fetchAppointments() async {
    emit(AppointmentLoading());
    try {
      final resp = await _api.get('/bookings/doctor-appointments');
      final all = (resp is Map ? resp['bookings'] : resp) as List? ?? [];

      final now = DateTime.now();

      // pending = slot bookings still awaiting doctor confirmation
      final pending = all
          .where((b) =>
              b['status'] == 'pending' && b['timeOption'] == 'schedule')
          .toList();

      // upcoming = confirmed or in-progress and date in the future (or no date yet)
      final upcoming = all.where((b) {
        if (!['confirmed', 'in-progress'].contains(b['status'])) return false;
        final d = b['scheduledDate'];
        if (d == null) return true;
        try {
          return DateTime.parse(d).isAfter(now.subtract(const Duration(days: 1)));
        } catch (_) {
          return true;
        }
      }).toList();

      // past = completed or cancelled
      final past = all.where((b) {
        return ['completed', 'cancelled'].contains(b['status']);
      }).toList();

      emit(AppointmentLoaded(pending: pending, upcoming: upcoming, past: past));
    } catch (e) {
      emit(AppointmentError(e.toString()));
    }
  }

  Future<void> confirmAppointment(String bookingId) async {
    try {
      await _api.put('/bookings/$bookingId/status',
          body: {'status': 'confirmed'});
      emit(AppointmentActionSuccess('تم تأكيد الحجز'));
      await fetchAppointments();
    } catch (e) {
      emit(AppointmentError(e.toString()));
    }
  }

  Future<void> rejectAppointment(String bookingId) async {
    try {
      await _api.put('/bookings/$bookingId/status',
          body: {'status': 'cancelled'});
      emit(AppointmentActionSuccess('تم رفض الحجز'));
      await fetchAppointments();
    } catch (e) {
      emit(AppointmentError(e.toString()));
    }
  }

  Future<void> startVisit(String bookingId) async {
    try {
      await _api.put('/bookings/$bookingId/status',
          body: {'status': 'in-progress'});
      emit(AppointmentActionSuccess('تم بدء الزيارة'));
      await fetchAppointments();
    } catch (e) {
      emit(AppointmentError(e.toString()));
    }
  }

  Future<void> completeVisit(String bookingId) async {
    try {
      await _api.put('/bookings/$bookingId/status',
          body: {'status': 'completed'});
      emit(AppointmentActionSuccess('تم إنهاء الزيارة'));
      await fetchAppointments();
    } catch (e) {
      emit(AppointmentError(e.toString()));
    }
  }
}
