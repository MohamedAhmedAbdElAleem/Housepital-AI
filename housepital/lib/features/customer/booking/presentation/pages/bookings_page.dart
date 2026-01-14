import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../../core/network/api_service.dart';
import '../../../../../core/utils/token_manager.dart';
import 'booking_tracking_page.dart';
import '../../../home/presentation/widgets/custom_bottom_nav_bar.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../widgets/booking_cancellation_modal.dart';
import 'customer_booking_details_page.dart';

import '../../utils/booking_utils.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage>
    with TickerProviderStateMixin {
  List<dynamic> _bookings = [];
  bool _isLoading = true;
  int _currentNavIndex = 1;
  int _selectedTab = 0;
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
    setState(() => _isLoading = true);

    try {
      final userId = await TokenManager.getUserId();
      if (userId == null || userId.isEmpty) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final apiService = ApiService();
      final response = await apiService.get('/api/bookings/my-bookings');

      if (mounted) {
        setState(() {
          _bookings =
              response is List ? response : (response['bookings'] ?? []);
          if (_bookings.isEmpty) _bookings = _getMockBookings();
          _isLoading = false;
        });
        _fadeController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _bookings = _getMockBookings();
          _isLoading = false;
        });
        _fadeController.forward();
      }
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
    ];
  }

  List<dynamic> get _activeBookings =>
      _bookings
          .where((b) => BookingUtils.activeStatuses.contains(b['status']))
          .toList();

  List<dynamic> get _historyBookings =>
      _bookings
          .where((b) => BookingUtils.historyStatuses.contains(b['status']))
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
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildHeader(),
          _buildTabSelector(),
          Expanded(
            child:
                _isLoading
                    ? _buildLoadingState()
                    : FadeTransition(
                      opacity: _fadeAnimation,
                      child:
                          _selectedTab == 0
                              ? _buildActiveBookings()
                              : _buildHistoryBookings(),
                    ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          if (index == 0) Navigator.pop(context);
          if (index == 4) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            );
          }
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 20,
        20,
        24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00D47F), Color(0xFF00B870), Color(0xFF009960)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Bookings',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Track and manage your appointments',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _fetchBookings,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.refresh_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Quick Stats
          Row(
            children: [
              _buildStatChip(
                icon: Icons.schedule_rounded,
                label: '${_activeBookings.length} Active',
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              _buildStatChip(
                icon: Icons.check_circle_rounded,
                label: '${_historyBookings.length} Completed',
                color: Colors.white70,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _buildTab(0, 'Active', Icons.flash_on_rounded)),
          Expanded(child: _buildTab(1, 'History', Icons.history_rounded)),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label, IconData icon) {
    final isSelected = _selectedTab == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient:
              isSelected
                  ? const LinearGradient(
                    colors: [Color(0xFF00D47F), Color(0xFF00B870)],
                  )
                  : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF94A3B8),
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF94A3B8),
              ),
            ),
            if (index == 0 && _activeBookings.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? Colors.white.withOpacity(0.2)
                          : const Color(0xFF00B870),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_activeBookings.length}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
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
              color: const Color(0xFF00B870).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              color: Color(0xFF00B870),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading bookings...',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveBookings() {
    if (_activeBookings.isEmpty) {
      return _buildEmptyState(
        icon: Icons.calendar_today_rounded,
        title: 'No Active Bookings',
        subtitle: 'Your upcoming appointments will appear here',
        showAction: true,
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchBookings,
      color: const Color(0xFF00B870),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _activeBookings.length,
        itemBuilder: (context, index) {
          final booking = Map<String, dynamic>.from(_activeBookings[index]);
          return _buildActiveBookingCard(booking, index);
        },
      ),
    );
  }

  Widget _buildHistoryBookings() {
    if (_historyBookings.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history_rounded,
        title: 'No Booking History',
        subtitle: 'Your completed bookings will appear here',
        showAction: false,
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchBookings,
      color: const Color(0xFF00B870),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _historyBookings.length,
        itemBuilder: (context, index) {
          final booking = Map<String, dynamic>.from(_historyBookings[index]);
          return _buildHistoryBookingCard(booking, index);
        },
      ),
    );
  }

  Widget _buildActiveBookingCard(Map<String, dynamic> booking, int index) {
    final status = booking['status'] ?? 'pending';
    final serviceName = booking['serviceName'] ?? 'Service';
    final patientName = booking['patientName'] ?? 'Patient';
    final nurseName = booking['nurseName'];
    final price = (booking['servicePrice'] ?? 0).toDouble();
    final bookingType = booking['type'] ?? 'home_nursing'; // Key fix: use 'type' field
    final isClinicAppointment = bookingType == 'clinic_appointment';

    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (status) {
      case 'in-progress':
        statusColor = const Color(0xFF00B870);
        statusLabel = 'In Progress';
        statusIcon = isClinicAppointment ? Icons.local_hospital_rounded : Icons.directions_car_rounded;
        break;
      case 'confirmed':
      case 'assigned':
        statusColor = const Color(0xFF3B82F6);
        statusLabel = 'Confirmed';
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'searching':
      case 'pending':
        statusColor = const Color(0xFFF59E0B);
        statusLabel = isClinicAppointment ? 'Awaiting Confirmation' : 'Finding Nurse';
        statusIcon = isClinicAppointment ? Icons.schedule_rounded : Icons.search_rounded;
        break;
      default:
        statusColor = const Color(0xFF64748B);
        statusLabel = 'Pending';
        statusIcon = Icons.schedule_rounded;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CustomerBookingDetailsPage(booking: booking),
            ),
          );
          _fetchBookings(); // Refresh on return
        },
        child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Status Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [statusColor, statusColor.withOpacity(0.8)],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(statusIcon, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    statusLabel,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  if (status == 'in-progress')
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Colors.white,
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '~15 min',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.medical_services_rounded,
                          color: statusColor,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              serviceName,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 14,
                                  color: Colors.grey[500],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  patientName,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${price.toStringAsFixed(0)} EGP',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00B870),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  if (nurseName != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  statusColor,
                                  statusColor.withOpacity(0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                nurseName[0],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nurseName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Color(0xFFF59E0B),
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${booking['nurseRating'] ?? 4.5}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00B870).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.phone_rounded,
                                color: Color(0xFF00B870),
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 14),

                  // Actions
                  Row(
                    children: [
                      // For clinic appointments: Show "View PIN" button
                      if (isClinicAppointment && status == 'confirmed')
                        Expanded(
                          child: _buildActionButton(
                            label: 'View PIN',
                            icon: Icons.qr_code_rounded,
                            color: const Color(0xFF8B5CF6),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CustomerBookingDetailsPage(booking: booking),
                              ),
                            ),
                          ),
                        ),
                      // For home nursing: Show "Track" button
                      if (!isClinicAppointment && (status == 'in-progress' || status == 'confirmed'))
                        Expanded(
                          child: _buildActionButton(
                            label: 'Track',
                            icon: Icons.location_on_rounded,
                            color: const Color(0xFF00B870),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BookingTrackingPage(booking: booking),
                              ),
                            ),
                          ),
                        ),
                      if ((isClinicAppointment && status == 'confirmed') || 
                          (!isClinicAppointment && (status == 'in-progress' || status == 'confirmed')))
                        const SizedBox(width: 10),
                      Expanded(
                        child: _buildActionButton(
                          label: 'Cancel',
                          icon: Icons.close_rounded,
                          color: const Color(0xFFEF4444),
                          isOutlined: true,
                          onTap: () => _handleCancelBooking(booking),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildHistoryBookingCard(Map<String, dynamic> booking, int index) {
    final serviceName = booking['serviceName'] ?? 'Service';
    final nurseName = booking['nurseName'] ?? 'Provider';
    final price = (booking['servicePrice'] ?? 0).toDouble();
    final scheduledDate = booking['scheduledDate'];
    final rating = booking['nurseRating'] ?? 0.0;

    String dateLabel = 'Completed';
    if (scheduledDate != null) {
      try {
        final date = DateTime.parse(scheduledDate);
        dateLabel = DateFormat('MMM d, yyyy').format(date);
      } catch (_) {}
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF00B870),
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    serviceName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        dateLabel,
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(
                        nurseName,
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  if (rating > 0) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: List.generate(5, (i) {
                        return Icon(
                          i < rating.round() ? Icons.star : Icons.star_border,
                          color: const Color(0xFFF59E0B),
                          size: 14,
                        );
                      }),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${price.toStringAsFixed(0)} EGP',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B870).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Rebook',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF00B870),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isOutlined = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isOutlined ? Colors.white : color,
          borderRadius: BorderRadius.circular(12),
          border: isOutlined ? Border.all(color: color) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isOutlined ? color : Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isOutlined ? color : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool showAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF00B870).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: const Color(0xFF00B870)),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            if (showAction) ...[
              const SizedBox(height: 28),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00D47F), Color(0xFF00B870)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Book a Service',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
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
              _performCancelBooking(booking['_id'] ?? booking['id'] ?? '');
            },
            onCancel: () => Navigator.pop(context),
          ),
    );
  }

  Future<void> _performCancelBooking(String bookingId) async {
    try {
      final apiService = ApiService();
      await apiService.put('/api/bookings/$bookingId/cancel', body: {});
      _fetchBookings();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Booking cancelled'),
              ],
            ),
            backgroundColor: const Color(0xFF00B870),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      // Handle error
    }
  }
}
