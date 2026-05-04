import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/network/api_service.dart';
import '../../../../../core/utils/token_manager.dart';

import '../../utils/booking_utils.dart';
import '../widgets/bookings_canopy_header.dart';
import '../widgets/bookings_glass_tab_bar.dart';
import '../widgets/bookings_type_filter.dart';
import '../widgets/bookings_active_card.dart';
import '../widgets/bookings_history_card.dart';
import '../widgets/bookings_empty_state_card.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage>
    with TickerProviderStateMixin {
  List<dynamic> _bookings = [];
  bool _isLoading = false;
  int _selectedTab = 0;
  int _selectedType = 0; // 0=All, 1=Nursing, 2=Clinic
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _fetchBookings();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
      value: 1.0, // start fully visible — content shows immediately
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _fetchBookings() async {
    // Show mock data immediately while loading real data
    if (_bookings.isEmpty) {
      setState(() {
        _bookings = _getMockBookings();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = true);
    }

    try {
      final userId = await TokenManager.getUserId();
      if (userId == null || userId.isEmpty) {
        // Not logged in — keep mock data visible
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final apiService = ApiService();
      final bookingResponse = await apiService.get('/api/bookings/my-bookings');
      final matchingResponse = await apiService.get('/api/matching/my-requests');

      final user = await TokenManager.getUserFromToken();
      final patientName = (user?['name'] ?? 'Patient').toString();

      final fetchedBookings =
          bookingResponse is List
              ? bookingResponse
              : (bookingResponse['bookings'] ?? []) as List;

      final matchingRequests =
          (matchingResponse is Map<String, dynamic>
                  ? matchingResponse['requests']
                  : null)
              as List? ??
          const [];

      final matchingCards =
          matchingRequests
              .whereType<Map>()
              .map((request) {
                final data = Map<String, dynamic>.from(request);
                final id = (data['id'] ?? '').toString();
                return {
                  'id': id,
                  'matchingRequestId': id,
                  'isMatchingRequest': true,
                  'bookingType': 'nursing',
                  'type': 'home_nursing',
                  'status': data['status'] ?? 'searching',
                  'serviceName': data['serviceName'] ?? 'Home Nursing Service',
                  'servicePrice': (data['servicePrice'] ?? 0),
                  'patientName': patientName,
                  'timeOption': 'asap',
                  'createdAt': data['createdAt'],
                  'address': data['location'] ?? {},
                };
              })
              .toList();

      final merged = [
        ...fetchedBookings.whereType<Map>().map((e) => Map<String, dynamic>.from(e)),
        ...matchingCards,
      ];

      merged.sort((a, b) {
        final aDate = DateTime.tryParse((a['createdAt'] ?? '').toString());
        final bDate = DateTime.tryParse((b['createdAt'] ?? '').toString());
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });

      if (mounted) {
        setState(() {
          if (merged.isNotEmpty) _bookings = merged;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _getMockBookings() {
    return [
      {
        'id': 'mock1',
        'serviceName': 'Home Nursing Care',
        'patientName': 'Ahmed Ali',
        'status': 'in-progress',
        'bookingType': 'nursing',
        'timeOption': 'asap',
        'servicePrice': 150,
        'nurseName': 'Sarah Ahmed',
        'nurseImage': null,
        'nurseRating': 4.9,
        'estimatedArrival':
            DateTime.now().add(const Duration(minutes: 15)).toIso8601String(),
      },
      {
        'id': 'mock2',
        'serviceName': 'IV Therapy',
        'patientName': 'Fatima Ali',
        'status': 'confirmed',
        'bookingType': 'nursing',
        'timeOption': 'schedule',
        'servicePrice': 200,
        'scheduledDate':
            DateTime.now().add(const Duration(hours: 3)).toIso8601String(),
        'nurseName': 'Mohamed Hassan',
        'nurseRating': 4.7,
      },
      {
        'id': 'mock3',
        'serviceName': 'Wound Care',
        'patientName': 'Ahmed Ali',
        'status': 'searching',
        'bookingType': 'nursing',
        'timeOption': 'asap',
        'servicePrice': 180,
      },
      {
        'id': 'mock4',
        'serviceName': 'Post-Op Care',
        'patientName': 'Ahmed Ali',
        'status': 'completed',
        'bookingType': 'nursing',
        'servicePrice': 300,
        'scheduledDate':
            DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'nurseName': 'Laila Mahmoud',
        'nurseRating': 4.8,
      },
      {
        'id': 'mock5',
        'serviceName': 'Blood Test',
        'patientName': 'Ahmed Ali',
        'status': 'completed',
        'bookingType': 'nursing',
        'servicePrice': 120,
        'scheduledDate':
            DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'nurseName': 'Ahmed Karim',
        'nurseRating': 5.0,
      },
      // ── Clinic Appointments (mock) ──
      {
        'id': 'mock6',
        'type': 'clinic_appointment',
        'serviceName': 'Dermatology Consultation',
        'patientName': 'Ahmed Ali',
        'status': 'confirmed',
        'servicePrice': 250,
        'scheduledDate':
            DateTime.now().add(const Duration(days: 2)).toIso8601String(),
        'scheduledTime': '10:30',
        'doctorName': 'Dr. Mona Saleh',
        'doctorSpecialization': 'Dermatologist',
        'clinicName': 'Skin Care Clinic',
        'timeOption': 'schedule',
      },
      {
        'id': 'mock7',
        'type': 'clinic_appointment',
        'serviceName': 'General Checkup',
        'patientName': 'Ahmed Ali',
        'status': 'pending',
        'servicePrice': 150,
        'scheduledDate':
            DateTime.now().add(const Duration(days: 4)).toIso8601String(),
        'doctorName': 'Dr. Karim Hassan',
        'doctorSpecialization': 'General Practitioner',
        'clinicName': 'City Medical Center',
        'timeOption': 'queue',
      },
      {
        'id': 'mock8',
        'type': 'clinic_appointment',
        'serviceName': 'Eye Exam',
        'patientName': 'Ahmed Ali',
        'status': 'completed',
        'servicePrice': 200,
        'scheduledDate':
            DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'scheduledTime': '14:00',
        'doctorName': 'Dr. Sara Nour',
        'doctorSpecialization': 'Ophthalmologist',
        'clinicName': 'Vision Plus Clinic',
        'timeOption': 'schedule',
      },
    ];
  }

  bool _isClinic(dynamic b) =>
      (b['type'] ?? b['bookingType'] ?? '') == 'clinic_appointment';

  List<dynamic> get _filteredBookings {
    if (_selectedType == 0) return _bookings;
    return _bookings
        .where((b) => _selectedType == 2 ? _isClinic(b) : !_isClinic(b))
        .toList();
  }

  List<dynamic> get _activeBookings =>
      _filteredBookings
          .where((b) {
            final status = BookingUtils.normalizeStatus(
              b is Map ? b['status'] : null,
            );
            return BookingUtils.activeStatuses.contains(status);
          })
          .toList();

  List<dynamic> get _historyBookings =>
      _filteredBookings
          .where((b) {
            final status = BookingUtils.normalizeStatus(
              b is Map ? b['status'] : null,
            );
            return BookingUtils.historyStatuses.contains(status);
          })
          .toList();



  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Stack(
        children: [
          // ── 1. The Canopy (Background Header) ──
          BookingsCanopyHeader(
            activeCount: _activeBookings.length,
            historyCount: _historyBookings.length,
            onRefresh: _fetchBookings,
          ),

          // ── 2. The Overlapping Grid Body ──
          // Pulls content up over the canopy with negative offset
          Padding(
            padding: const EdgeInsets.only(top: 220),
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Column(
                children: [
                  // Glassmorphic Tab Bar
                  BookingsGlassTabBar(
                    selectedTab: _selectedTab,
                    activeCount: _activeBookings.length,
                    onTabChanged: (tab) => setState(() => _selectedTab = tab),
                  ),

                  // Type Filter
                  BookingsTypeFilter(
                    selectedType: _selectedType,
                    onTypeChanged: (type) =>
                        setState(() => _selectedType = type),
                  ),

                  const SizedBox(height: 8),

                  // Content
                  Expanded(
                    child: _isLoading
                        ? _buildLoadingState()
                        : FadeTransition(
                            opacity: _fadeAnimation,
                            child: _selectedTab == 0
                                ? _buildActiveBookings()
                                : _buildHistoryBookings(),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2ECC71).withAlpha(25),
                  const Color(0xFF3498BB).withAlpha(20),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              color: Color(0xFF2ECC71),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Loading bookings...',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveBookings() {
    if (_activeBookings.isEmpty) {
      return BookingsEmptyState(
        icon: Icons.calendar_today_rounded,
        title: 'No Active Bookings',
        subtitle: 'Your upcoming appointments will appear here',
        showAction: true,
        onAction: () => Navigator.pop(context),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchBookings,
      color: const Color(0xFF2ECC71),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _activeBookings.length,
        itemBuilder: (context, index) {
          final booking = Map<String, dynamic>.from(_activeBookings[index]);
          return BookingsActiveCard(
            booking: booking,
            index: index,
            onRefresh: _fetchBookings,
          );
        },
      ),
    );
  }

  Widget _buildHistoryBookings() {
    if (_historyBookings.isEmpty) {
      return const BookingsEmptyState(
        icon: Icons.history_rounded,
        title: 'No Booking History',
        subtitle: 'Your completed bookings will appear here',
        showAction: false,
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchBookings,
      color: const Color(0xFF2ECC71),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _historyBookings.length,
        itemBuilder: (context, index) {
          final booking = Map<String, dynamic>.from(_historyBookings[index]);
          return BookingsHistoryCard(
            booking: booking,
            index: index,
          );
        },
      ),
    );
  }
}
