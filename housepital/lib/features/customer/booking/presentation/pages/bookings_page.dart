import 'package:flutter/material.dart';
import '../../../../../core/network/api_service.dart';
import '../../../../../core/utils/token_manager.dart';
import 'booking_tracking_page.dart';
import '../../../home/presentation/widgets/custom_bottom_nav_bar.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../widgets/booking_tab_switcher.dart';
import '../widgets/booking_card_nurse_waiting.dart';
import '../widgets/booking_card_nurse_emergency.dart';
import '../widgets/booking_card_confirmed_nursing.dart';
import '../widgets/booking_card_confirmed_clinic.dart';
import '../widgets/booking_card_searching.dart';
import '../widgets/booking_card_completed.dart';
import '../widgets/booking_cancellation_modal.dart';
import '../widgets/booking_ticket_modal.dart';
import '../widgets/booking_empty_state.dart';
import '../../utils/booking_utils.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({Key? key}) : super(key: key);

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  List<dynamic> _bookings = [];
  bool _isLoading = true;
  int _currentNavIndex = 1; // Bookings tab is active
  int _activeTab = 0; // 0 = Active & Upcoming, 1 = History

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = await TokenManager.getUserId();
      if (userId == null || userId.isEmpty) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      final apiService = ApiService();
      final response = await apiService.get('/api/bookings/my-bookings');

      if (mounted) {
        setState(() {
          _bookings =
              response is List ? response : (response['bookings'] ?? []);

          // 🧪 DEBUG: Add mock data if no bookings exist (for testing UI)
          if (_bookings.isEmpty) {
            _bookings = _getMockBookings();
            debugPrint('🧪 Using mock booking data for UI testing');
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading bookings: $e');
      if (mounted) {
        setState(() {
          // 🧪 Show mock data on error for testing
          _bookings = _getMockBookings();
          _isLoading = false;
        });
      }
    }
  }

  // 🧪 Mock data for testing UI with all different states
  List<Map<String, dynamic>> _getMockBookings() {
    return [
      {
        'id': 'mock1',
        'serviceName': 'Home Nursing Care',
        'patientName': 'Ahmed Ali',
        'status': 'nurse_waiting',
        'bookingType': 'nursing',
        'timeOption': 'asap',
        'servicePrice': 150,
        'scheduledDate': null,
        'nurseName': 'Nurse Sarah',
        'nursePhone': '+201234567890',
        'waitingStartTime':
            DateTime.now()
                .subtract(const Duration(minutes: 3))
                .toIso8601String(),
      },
      {
        'id': 'mock2',
        'serviceName': 'IV Therapy',
        'patientName': 'Fatima Ali',
        'status': 'nurse_emergency',
        'bookingType': 'nursing',
        'timeOption': 'schedule',
        'servicePrice': 200,
        'scheduledDate':
            DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
      },
      {
        'id': 'mock3',
        'serviceName': 'Wound Care',
        'patientName': 'Ahmed Ali',
        'status': 'confirmed',
        'bookingType': 'nursing',
        'timeOption': 'asap',
        'servicePrice': 180,
        'scheduledDate': null,
        'nurseName': 'Nurse Mohamed',
        'nursePhone': '+201234567891',
      },
      {
        'id': 'mock4',
        'serviceName': 'Dermatology Consultation',
        'patientName': 'Ahmed Ali',
        'status': 'clinic_confirmed',
        'bookingType': 'clinic',
        'timeOption': 'schedule',
        'servicePrice': 350,
        'scheduledDate':
            DateTime.now()
                .add(const Duration(days: 1, hours: 10))
                .toIso8601String(),
        'clinicName': 'Nile Medical Center',
        'clinicAddress': 'Maadi, Cairo',
        'doctorName': 'Dr. Hany Ezzat',
        'checkInPin': '8472',
      },
      {
        'id': 'mock5',
        'serviceName': 'Elderly Care',
        'patientName': 'Fatima Ali',
        'status': 'searching',
        'bookingType': 'nursing',
        'timeOption': 'asap',
        'servicePrice': 250,
        'scheduledDate': null,
      },
      {
        'id': 'mock6',
        'serviceName': 'Post-Op Care',
        'patientName': 'Ahmed Ali',
        'status': 'completed',
        'bookingType': 'nursing',
        'timeOption': 'schedule',
        'servicePrice': 300,
        'scheduledDate':
            DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'nurseName': 'Nurse Laila',
        'nurseRating': 4.8,
      },
      {
        'id': 'mock7',
        'serviceName': 'General Checkup',
        'patientName': 'Ahmed Ali',
        'status': 'completed',
        'bookingType': 'clinic',
        'timeOption': 'schedule',
        'servicePrice': 200,
        'scheduledDate':
            DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'doctorName': 'Dr. Ahmed Hassan',
        'clinicName': 'Cairo Medical',
      },
    ];
  }

  List<dynamic> _getFilteredBookings() {
    if (_activeTab == 0) {
      // Active & Upcoming
      return _bookings
          .where((b) => BookingUtils.activeStatuses.contains(b['status']))
          .toList();
    } else {
      // History
      return _bookings
          .where((b) => BookingUtils.historyStatuses.contains(b['status']))
          .toList();
    }
  }

  void _handleCancelBooking(Map<String, dynamic> booking) {
    final isLate = BookingUtils.isLateCancel(booking['status']);

    showDialog(
      context: context,
      builder:
          (context) => BookingCancellationModal(
            isLateCancel: isLate,
            onConfirm: () {
              Navigator.pop(context);
              _performCancelBooking(booking['id']);
            },
            onCancel: () => Navigator.pop(context),
          ),
    );
  }

  Future<void> _performCancelBooking(String bookingId) async {
    try {
      final apiService = ApiService();
      await apiService.put('/api/bookings/$bookingId/cancel', body: {});
      _fetchBookings(); // Refresh the list
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking cancelled successfully'),
            backgroundColor: Color(0xFF17C47F),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error cancelling booking: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to cancel booking'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleViewTicket(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder:
          (context) => BookingTicketModal(
            serviceName: booking['serviceName'] ?? 'Service',
            patientName: booking['patientName'] ?? 'Patient',
            clinicName: booking['clinicName'] ?? 'Clinic',
            clinicAddress: booking['clinicAddress'] ?? '',
            doctorName: booking['doctorName'] ?? 'Doctor',
            scheduledTime: BookingUtils.formatScheduledTime(
              booking['scheduledDate'],
            ),
            checkInPin: booking['checkInPin'] ?? '0000',
            onClose: () => Navigator.pop(context),
          ),
    );
  }

  void _handleTrackNurse(Map<String, dynamic> booking) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingTrackingPage(booking: booking),
      ),
    );
  }

  void _handleCheckIn(Map<String, dynamic> booking) {
    // TODO: Implement check-in flow
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Check-in feature coming soon!'),
        backgroundColor: Color(0xFF17C47F),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: const Text(
          'My Bookings',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Column(
        children: [
          // Tab Switcher
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: BookingTabSwitcher(
              activeTab: _activeTab,
              onTabChanged: (tab) {
                setState(() {
                  _activeTab = tab;
                });
              },
            ),
          ),

          // Bookings List
          Expanded(
            child:
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF17C47F),
                      ),
                    )
                    : _buildBookingsList(),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          } else if (index == 4) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          }
        },
      ),
    );
  }

  Widget _buildBookingsList() {
    final bookings = _getFilteredBookings();

    if (bookings.isEmpty) {
      return BookingEmptyState(isHistory: _activeTab == 1);
    }

    return RefreshIndicator(
      onRefresh: _fetchBookings,
      color: const Color(0xFF17C47F),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = Map<String, dynamic>.from(bookings[index]);
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildBookingCard(booking),
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final String status = booking['status'] ?? 'pending';
    final String bookingType = booking['bookingType'] ?? 'nursing';
    final String serviceName = booking['serviceName'] ?? 'Service';
    final String patientName = booking['patientName'] ?? 'Patient';
    final double price = (booking['servicePrice'] ?? 0).toDouble();
    final String scheduledTime = BookingUtils.formatScheduledTime(
      booking['scheduledDate'],
    );

    switch (status) {
      case 'nurse_waiting':
        // Calculate remaining time from waitingStartTime
        int remainingSeconds = 300; // 5 minutes default
        if (booking['waitingStartTime'] != null) {
          try {
            final startTime = DateTime.parse(booking['waitingStartTime']);
            final elapsed = DateTime.now().difference(startTime).inSeconds;
            remainingSeconds = (300 - elapsed).clamp(0, 300);
          } catch (e) {
            // Use default
          }
        }
        return BookingCardNurseWaiting(
          serviceName: serviceName,
          patientName: patientName,
          nurseName: booking['nurseName'] ?? 'Nurse',
          remainingSeconds: remainingSeconds,
          onCheckIn: () => _handleCheckIn(booking),
          onCall: () {
            // TODO: Implement call
          },
        );

      case 'nurse_emergency':
        return BookingCardNurseEmergency(
          serviceName: serviceName,
          patientName: patientName,
          scheduledTime: scheduledTime,
        );

      case 'confirmed':
      case 'assigned':
      case 'in-progress':
        if (bookingType == 'clinic') {
          return BookingCardConfirmedClinic(
            serviceName: serviceName,
            patientName: patientName,
            clinicName: booking['clinicName'] ?? 'Clinic',
            doctorName: booking['doctorName'] ?? 'Doctor',
            scheduledTime: scheduledTime,
            onViewTicket: () => _handleViewTicket(booking),
            onCancel: () => _handleCancelBooking(booking),
          );
        }
        return BookingCardConfirmedNursing(
          serviceName: serviceName,
          patientName: patientName,
          nurseName: booking['nurseName'] ?? 'Finding nurse...',
          scheduledTime: scheduledTime,
          onTrackNurse: () => _handleTrackNurse(booking),
          onCancel: () => _handleCancelBooking(booking),
        );

      case 'clinic_confirmed':
        return BookingCardConfirmedClinic(
          serviceName: serviceName,
          patientName: patientName,
          clinicName: booking['clinicName'] ?? 'Clinic',
          doctorName: booking['doctorName'] ?? 'Doctor',
          scheduledTime: scheduledTime,
          onViewTicket: () => _handleViewTicket(booking),
          onCancel: () => _handleCancelBooking(booking),
        );

      case 'pending':
      case 'searching':
        return BookingCardSearching(
          serviceName: serviceName,
          patientName: patientName,
          price: price,
          scheduledTime: scheduledTime,
          onCancel: () => _handleCancelBooking(booking),
        );

      case 'completed':
        return BookingCardCompleted(
          serviceName: serviceName,
          patientName: patientName,
          providerName:
              booking['nurseName'] ?? booking['doctorName'] ?? 'Provider',
          completedDate: scheduledTime,
          price: price,
          onRebook: () {
            // TODO: Implement rebook
          },
          onRate: () {
            // TODO: Implement rate
          },
        );

      default:
        // Fallback to confirmed nursing card
        return BookingCardConfirmedNursing(
          serviceName: serviceName,
          patientName: patientName,
          nurseName: booking['nurseName'] ?? 'Provider',
          scheduledTime: scheduledTime,
          onTrackNurse: () => _handleTrackNurse(booking),
          onCancel: () => _handleCancelBooking(booking),
        );
    }
  }
}
