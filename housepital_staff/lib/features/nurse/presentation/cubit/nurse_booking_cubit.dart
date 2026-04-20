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
  String _pendingSource = 'matching';

  NurseBookingCubit(this._apiClient) : super(NurseBookingInitial());

  NurseBooking? get currentBooking => _currentBooking;

  NurseBooking _matchingOfferToBooking(Map<String, dynamic> offer) {
    final patient = (offer['patient'] as Map<String, dynamic>?) ?? {};
    final service = (offer['service'] as Map<String, dynamic>?) ?? {};
    final pricing = (offer['pricing'] as Map<String, dynamic>?) ?? {};
    final location = (offer['location'] as Map<String, dynamic>?) ?? {};

    return NurseBooking.fromJson({
      '_id': offer['offerId'],
      'type': 'home_nursing',
      'serviceName': service['name'] ?? 'Service',
      'servicePrice': pricing['servicePrice'] ?? pricing['totalPrice'] ?? 0,
      'patientId': '',
      'patientName': patient['name'] ?? 'Patient',
      'userId': {'name': patient['name'] ?? 'Patient'},
      'status': 'pending',
      'notes': offer['notes'] ?? '',
      'timeOption': offer['timeOption'] ?? 'asap',
      'address': {
        'street': location['street'],
        'area': location['area'],
        'city': location['city'],
        'state': location['state'],
      },
      'createdAt': offer['createdAt'] ?? DateTime.now().toIso8601String(),
    });
  }

  /// Fetch pending bookings and check for active booking
  Future<void> fetchBookings() async {
    if (state is! NurseBookingIdle &&
        state is! NurseBookingInProgress &&
        state is! NurseBookingActive)
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
          // If arrived, we might need PIN. Otherwise, just show map.
          emit(
            NurseBookingActive(
              booking,
              needsPinVerification: booking.status == 'arrived',
            ),
          );
        } else if (booking.isInProgress) {
          // Visit already started
          emit(NurseBookingInProgress(booking));
        }
        return;
      }

      // No active booking, fetch pending matching offers first
      try {
        final matchingResponse = await _apiClient.get(
          ApiConstants.nurseMatchingOffers,
        );

        if (matchingResponse['success'] == true) {
          _pendingSource = 'matching';
          final offers = (matchingResponse['offers'] as List? ?? []);
          final bookings =
              offers.map((o) => _matchingOfferToBooking(o)).toList();
          emit(NurseBookingIdle(bookings));
          return;
        }
      } catch (_) {
        // Fall back to the legacy pending-booking API if matching API is unavailable.
      }

      final pendingResponse = await _apiClient.get(
        ApiConstants.nursePendingBookings,
      );

      _pendingSource = 'legacy';
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
      if (_pendingSource == 'matching') {
        final response = await _apiClient.put(
          ApiConstants.respondToNurseOffer(bookingId),
          body: {'response': 'accepted'},
        );

        if (response['success'] == true) {
          await fetchBookings();
          return;
        }

        emit(
          NurseBookingError(response['message'] ?? 'Failed to accept offer'),
        );
        await fetchBookings();
        return;
      }

      final response = await _apiClient.post(
        ApiConstants.acceptBooking(bookingId),
        body: {},
      );

      if (response['success'] == true) {
        final booking = NurseBooking.fromJson(response['booking']);
        _currentBooking = booking;
        emit(
          NurseBookingActive(
            booking,
            needsPinVerification: booking.status == 'arrived',
          ),
        );
      } else {
        emit(
          NurseBookingError(response['message'] ?? 'Failed to accept booking'),
        );
        await fetchBookings();
      }
    } catch (e) {
      print('❌ Error accepting booking: $e');
      emit(NurseBookingError('Failed to accept booking: ${e.toString()}'));
    }
  }

  /// Update booking status (e.g., to on-the-way or arrived)
  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.updateBookingStatus(bookingId),
        body: {'status': status},
      );
      if (response['success'] == true) {
        final booking = NurseBooking.fromJson(response['booking']);
        _currentBooking = booking;
        // Keep it in active state but maybe refresh the map
        emit(
          NurseBookingActive(
            booking,
            needsPinVerification: status == 'arrived',
          ),
        );
      }
    } catch (e) {
      print('❌ Error updating status: $e');
    }
  }

  /// Decline a pending item.
  Future<void> declineBooking(String bookingId) async {
    try {
      if (_pendingSource == 'matching') {
        await _apiClient.put(
          ApiConstants.respondToNurseOffer(bookingId),
          body: {'response': 'declined'},
        );
      }
    } catch (e) {
      print('❌ Error declining booking/offer: $e');
    }

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
