import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../data/models/booking_model.dart';

// States
abstract class NurseBookingState {}

class NurseBookingInitial extends NurseBookingState {}

class NurseBookingLoading extends NurseBookingState {}

class NurseBookingIdle extends NurseBookingState {
  final List<NurseBooking> pendingBookings;
  NurseBookingIdle(this.pendingBookings);
}

class NurseBookingIncoming extends NurseBookingState {
  final NurseBooking booking;
  NurseBookingIncoming(this.booking);
}

class NurseBookingActive extends NurseBookingState {
  final NurseBooking booking;
  final bool needsPinVerification;
  NurseBookingActive(this.booking, {this.needsPinVerification = true});
}

class NurseBookingInProgress extends NurseBookingState {
  final NurseBooking booking;
  NurseBookingInProgress(this.booking);
}

class NurseBookingCompleted extends NurseBookingState {
  final NurseBooking booking;
  NurseBookingCompleted(this.booking);
}

class NurseBookingError extends NurseBookingState {
  final String message;
  NurseBookingError(this.message);
}

// Cubit
class NurseBookingCubit extends Cubit<NurseBookingState> {
  final ApiClient _apiClient;
  NurseBooking? _currentBooking;

  NurseBookingCubit(this._apiClient) : super(NurseBookingInitial());

  NurseBooking? get currentBooking => _currentBooking;

  /// Fetch pending bookings and check for active booking
  Future<void> fetchBookings() async {
    emit(NurseBookingLoading());

    try {
      // First check if there's an active booking
      final activeResponse = await _apiClient.get(
        ApiConstants.nurseActiveBooking,
      );

      if (activeResponse['success'] == true &&
          activeResponse['booking'] != null) {
        final booking = NurseBooking.fromJson(activeResponse['booking']);
        _currentBooking = booking;

        if (booking.isAssigned) {
          // Need PIN verification
          emit(NurseBookingActive(booking, needsPinVerification: true));
        } else if (booking.isInProgress) {
          // Visit already started
          emit(NurseBookingInProgress(booking));
        }
        return;
      }

      // No active booking, fetch pending ones
      final pendingResponse = await _apiClient.get(
        ApiConstants.nursePendingBookings,
      );

      if (pendingResponse['success'] == true) {
        final bookings =
            (pendingResponse['bookings'] as List)
                .map((b) => NurseBooking.fromJson(b))
                .toList();
        emit(NurseBookingIdle(bookings));
      } else {
        emit(NurseBookingIdle([]));
      }
    } catch (e) {
      print('❌ Error fetching bookings: $e');
      emit(NurseBookingError('Failed to fetch bookings: ${e.toString()}'));
    }
  }

  /// Accept a booking request
  Future<void> acceptBooking(String bookingId) async {
    emit(NurseBookingLoading());

    try {
      final response = await _apiClient.post(
        ApiConstants.acceptBooking(bookingId),
        body: {},
      );

      if (response['success'] == true) {
        final booking = NurseBooking.fromJson(response['booking']);
        _currentBooking = booking;
        emit(NurseBookingActive(booking, needsPinVerification: true));
      } else {
        emit(
          NurseBookingError(response['message'] ?? 'Failed to accept booking'),
        );
        // Refresh to show current state
        await fetchBookings();
      }
    } catch (e) {
      print('❌ Error accepting booking: $e');
      emit(NurseBookingError('Failed to accept booking: ${e.toString()}'));
    }
  }

  /// Decline a booking (just go back to idle for now)
  void declineBooking() {
    _currentBooking = null;
    fetchBookings();
  }

  /// Verify PIN and start visit
  Future<void> verifyPinAndStartVisit(String bookingId, String pin) async {
    emit(NurseBookingLoading());

    try {
      final response = await _apiClient.post(
        ApiConstants.verifyPin(bookingId),
        body: {'pin': pin},
      );

      if (response['success'] == true) {
        final booking = NurseBooking.fromJson(response['booking']);
        _currentBooking = booking;
        emit(NurseBookingInProgress(booking));
      } else {
        emit(NurseBookingError(response['message'] ?? 'Invalid PIN'));
        // Go back to active state for retry
        if (_currentBooking != null) {
          emit(
            NurseBookingActive(_currentBooking!, needsPinVerification: true),
          );
        }
      }
    } catch (e) {
      print('❌ Error verifying PIN: $e');
      emit(NurseBookingError('Failed to verify PIN: ${e.toString()}'));
      if (_currentBooking != null) {
        emit(NurseBookingActive(_currentBooking!, needsPinVerification: true));
      }
    }
  }

  /// Complete the visit
  Future<void> completeVisit(String bookingId, {String? report}) async {
    emit(NurseBookingLoading());

    try {
      final response = await _apiClient.post(
        ApiConstants.completeVisit(bookingId),
        body: {'report': report ?? ''},
      );

      if (response['success'] == true) {
        final booking = NurseBooking.fromJson(response['booking']);
        _currentBooking = null;
        emit(NurseBookingCompleted(booking));

        // Refresh after a short delay
        await Future.delayed(const Duration(seconds: 2));
        await fetchBookings();
      } else {
        emit(
          NurseBookingError(response['message'] ?? 'Failed to complete visit'),
        );
      }
    } catch (e) {
      print('❌ Error completing visit: $e');
      emit(NurseBookingError('Failed to complete visit: ${e.toString()}'));
    }
  }

  /// Reset to idle state
  void resetToIdle() {
    _currentBooking = null;
    fetchBookings();
  }
}
