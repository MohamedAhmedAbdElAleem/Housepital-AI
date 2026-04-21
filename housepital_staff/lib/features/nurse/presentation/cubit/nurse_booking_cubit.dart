import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../data/models/booking_model.dart';

// ─── States ──────────────────────────────────────────────────────────────────

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

class NurseBookingWaitingForPatient extends NurseBookingState {
  final NurseBooking booking;
  NurseBookingWaitingForPatient(this.booking);
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

/// Emitted while history is being fetched
class NurseBookingHistoryLoading extends NurseBookingState {}

/// Emitted once history is ready (up to 10 recent completed/cancelled sessions)
class NurseBookingHistoryLoaded extends NurseBookingState {
  final List<NurseBooking> history;
  NurseBookingHistoryLoaded(this.history);
}

// ─── Cubit ───────────────────────────────────────────────────────────────────

class NurseBookingCubit extends Cubit<NurseBookingState> {
  final ApiClient _apiClient;
  NurseBooking? _currentBooking;

  /// Tracks whether pending items came from the matching API or the legacy
  /// pending-bookings API so that accept/decline can route to the right endpoint.
  String _pendingSource = 'matching';

  NurseBookingCubit(this._apiClient) : super(NurseBookingInitial());

  NurseBooking? get currentBooking => _currentBooking;

  // ── Helper: convert a matching offer map into a NurseBooking ─────────────

  NurseBooking _matchingOfferToBooking(Map<String, dynamic> offer) {
    final patient = (offer['patient'] as Map<String, dynamic>?) ?? {};
    final service = (offer['service'] as Map<String, dynamic>?) ?? {};
    final pricing = (offer['pricing'] as Map<String, dynamic>?) ?? {};
    final location = (offer['location'] as Map<String, dynamic>?) ?? {};
    final nurseStatus = (offer['nurseStatus'] ?? 'pending').toString();
    final patientStatus = (offer['patientStatus'] ?? 'not_applicable').toString();

    final bookingStatus =
        (nurseStatus == 'accepted' && patientStatus == 'pending')
        ? 'waiting-patient'
        : 'pending';

    return NurseBooking.fromJson({
      '_id': offer['offerId'],
      'type': 'home_nursing',
      'serviceName': service['name'] ?? 'Service',
      'servicePrice': pricing['servicePrice'] ?? pricing['totalPrice'] ?? 0,
      'patientId': '',
      'patientName': patient['name'] ?? 'Patient',
      'userId': {'name': patient['name'] ?? 'Patient'},
      'status': bookingStatus,
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

  // ── Main booking flow ────────────────────────────────────────────────────

  /// Fetch pending bookings and check for active booking.
  /// Tries the matching API first, falls back to legacy pending-bookings API.
  Future<void> fetchBookings() async {
    if (state is! NurseBookingIdle &&
        state is! NurseBookingWaitingForPatient &&
        state is! NurseBookingInProgress &&
        state is! NurseBookingActive) {
      emit(NurseBookingLoading());
    }

    try {
      // 1️⃣ Check for an already-active booking
      final activeResponse = await _apiClient.get(
        ApiConstants.nurseActiveBooking,
      );

      if (activeResponse['success'] == true &&
          activeResponse['booking'] != null) {
        final booking = NurseBooking.fromJson(activeResponse['booking']);
        _currentBooking = booking;

        if (booking.isAssigned) {
          emit(
            NurseBookingActive(
              booking,
              needsPinVerification: booking.status == 'arrived',
            ),
          );
        } else if (booking.isInProgress) {
          emit(NurseBookingInProgress(booking));
        }
        return;
      }

      // 2️⃣ No active booking — exclusively fetch matching offers
      final matchingResponse = await _apiClient.get(
        ApiConstants.nurseMatchingOffers,
      );

      if (matchingResponse['success'] == true) {
        final offers = (matchingResponse['offers'] as List? ?? []);
        final bookings = offers.map((o) => _matchingOfferToBooking(o)).toList();
        final waitingBookings =
            bookings.where((b) => b.isWaitingForPatient).toList();
        final pendingBookings =
            bookings.where((b) => !b.isWaitingForPatient).toList();

        if (waitingBookings.isNotEmpty) {
          emit(NurseBookingWaitingForPatient(waitingBookings.first));
        } else {
          emit(NurseBookingIdle(pendingBookings));
        }
      } else {
        emit(NurseBookingIdle([]));
      }
    } catch (e) {
      print('❌ Error fetching bookings: $e');
      emit(NurseBookingError('Failed to fetch bookings: ${e.toString()}'));
    }
  }

  // ── History ──────────────────────────────────────────────────────────────

  /// Fetch the last 10 completed / cancelled sessions for this nurse.
  Future<void> fetchHistory() async {
    emit(NurseBookingHistoryLoading());
    try {
      final response = await _apiClient.get(ApiConstants.nurseBookingHistory);
      if (response['success'] == true) {
        final bookings = (response['bookings'] as List)
            .map((b) => NurseBooking.fromJson(b))
            .toList();
        emit(NurseBookingHistoryLoaded(bookings));
      } else {
        emit(NurseBookingHistoryLoaded([]));
      }
    } catch (e) {
      print('❌ Error fetching history: $e');
      emit(NurseBookingHistoryLoaded([]));
    }
  }

  // ── Actions ──────────────────────────────────────────────────────────────

  /// Accept a booking / matching offer.
  Future<void> acceptBooking(String bookingId) async {
    NurseBooking? acceptedOffer;
    if (state is NurseBookingIdle) {
      try {
        acceptedOffer = (state as NurseBookingIdle).pendingBookings.firstWhere((b) => b.id == bookingId);
      } catch (_) {}
    }

    emit(NurseBookingLoading());
    try {
      final response = await _apiClient.put(
        ApiConstants.respondToNurseOffer(bookingId),
        body: {'response': 'accepted'},
      );

      if (response['success'] == true) {
        if (acceptedOffer != null) {
          emit(NurseBookingWaitingForPatient(acceptedOffer));
        } else {
          await fetchBookings();
        }
        return;
      }

      emit(
        NurseBookingError(response['message'] ?? 'Failed to accept offer'),
      );
      await fetchBookings();
    } catch (e) {
      print('❌ Error accepting offer: $e');
      emit(NurseBookingError('Failed to accept offer: ${e.toString()}'));
    }
  }

  /// Update booking status (e.g., to on-the-way or arrived).
  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.updateBookingStatus(bookingId),
        body: {'status': status},
      );
      if (response['success'] == true) {
        final booking = NurseBooking.fromJson(response['booking']);
        _currentBooking = booking;
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

  /// Decline a pending booking or matching offer.
  Future<void> declineBooking(String bookingId) async {
    try {
      await _apiClient.put(
        ApiConstants.respondToNurseOffer(bookingId),
        body: {'response': 'declined'},
      );
    } catch (e) {
      print('❌ Error declining offer: $e');
    }

    _currentBooking = null;
    fetchBookings();
  }

  /// Verify PIN and start visit.
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

  /// Complete the visit.
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

  /// Reset to idle state.
  void resetToIdle() {
    _currentBooking = null;
    fetchBookings();
  }
}
