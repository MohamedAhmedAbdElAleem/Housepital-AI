import 'package:flutter/material.dart';
import '../../../../../core/network/api_service.dart';
import '../../../../../core/utils/token_manager.dart';
import 'booking_tracking_page.dart';
import '../../../home/presentation/widgets/custom_bottom_nav_bar.dart';
import '../../../profile/presentation/pages/profile_page.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({Key? key}) : super(key: key);

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _bookings = [];
  bool _isLoading = true;
  int _currentNavIndex = 1; // Bookings tab is active

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  // 🧪 Mock data for testing UI
  List<Map<String, dynamic>> _getMockBookings() {
    return [
      {
        'id': 'mock1',
        'serviceName': 'Wound Care',
        'patientName': 'Ahmed Ali',
        'status': 'confirmed',
        'timeOption': 'asap',
        'servicePrice': 150,
        'scheduledDate': null,
      },
      {
        'id': 'mock2',
        'serviceName': 'Injections',
        'patientName': 'Fatima Ali',
        'status': 'assigned',
        'timeOption': 'schedule',
        'servicePrice': 50,
        'scheduledDate':
            DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
      },
      {
        'id': 'mock3',
        'serviceName': 'Elderly Care',
        'patientName': 'Ahmed Ali',
        'status': 'in-progress',
        'timeOption': 'asap',
        'servicePrice': 200,
        'scheduledDate': null,
      },
      {
        'id': 'mock4',
        'serviceName': 'Post-Op Care',
        'patientName': 'Ahmed Ali',
        'status': 'completed',
        'timeOption': 'schedule',
        'servicePrice': 300,
        'scheduledDate':
            DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      },
      {
        'id': 'mock5',
        'serviceName': 'IV Therapy',
        'patientName': 'Fatima Ali',
        'status': 'pending',
        'timeOption': 'asap',
        'servicePrice': 120,
        'scheduledDate': null,
      },
    ];
  }

  List<dynamic> _getFilteredBookings(String status) {
    if (status == 'all') return _bookings;

    if (status == 'active') {
      return _bookings
          .where(
            (b) => [
              'pending',
              'confirmed',
              'assigned',
              'in-progress',
            ].contains(b['status']),
          )
          .toList();
    }

    if (status == 'completed') {
      return _bookings
          .where((b) => ['completed', 'cancelled'].contains(b['status']))
          .toList();
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'My Bookings',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF17C47F),
          indicatorWeight: 3,
          labelColor: const Color(0xFF17C47F),
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Active'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF17C47F)),
              )
              : TabBarView(
                controller: _tabController,
                children: [
                  _buildBookingsList('all'),
                  _buildBookingsList('active'),
                  _buildBookingsList('completed'),
                ],
              ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          if (index == 0) {
            // Navigate to Home
            Navigator.pop(context);
          } else if (index == 4) {
            // Navigate to Profile
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          }
          // index 1 is current page (Bookings), so do nothing
        },
      ),
    );
  }

  Widget _buildBookingsList(String filter) {
    final bookings = _getFilteredBookings(filter);

    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FA),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_today,
                size: 64,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              filter == 'active' ? 'No active bookings' : 'No bookings found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              filter == 'active'
                  ? 'Book a service to get started'
                  : 'Your booking history will appear here',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchBookings,
      color: const Color(0xFF17C47F),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          100,
        ), // Extra bottom padding for nav bar
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return _buildBookingCard(booking);
        },
      ),
    );
  }

  Widget _buildBookingCard(dynamic booking) {
    final String serviceName = booking['serviceName'] ?? 'Service';
    final String patientName = booking['patientName'] ?? 'Patient';
    final String status = booking['status'] ?? 'pending';
    final String timeOption = booking['timeOption'] ?? 'asap';
    final double price = (booking['servicePrice'] ?? 0).toDouble();
    final String? scheduledDate = booking['scheduledDate'];

    // Status configuration
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case 'pending':
        statusColor = const Color(0xFFF59E0B);
        statusIcon = Icons.access_time;
        statusText = 'Pending';
        break;
      case 'confirmed':
        statusColor = const Color(0xFF3B82F6);
        statusIcon = Icons.check_circle;
        statusText = 'Confirmed';
        break;
      case 'assigned':
        statusColor = const Color(0xFF8B5CF6);
        statusIcon = Icons.person_pin;
        statusText = 'Nurse Assigned';
        break;
      case 'in-progress':
        statusColor = const Color(0xFF17C47F);
        statusIcon = Icons.local_hospital;
        statusText = 'In Progress';
        break;
      case 'completed':
        statusColor = const Color(0xFF10B981);
        statusIcon = Icons.check_circle;
        statusText = 'Completed';
        break;
      case 'cancelled':
        statusColor = const Color(0xFFEF4444);
        statusIcon = Icons.cancel;
        statusText = 'Cancelled';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusText = status;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to tracking page for active bookings
            if (['confirmed', 'assigned', 'in-progress'].contains(status)) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookingTrackingPage(booking: booking),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with service icon and status
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF17C47F).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.medical_services,
                        color: Color(0xFF17C47F),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
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
                              Icon(
                                Icons.person_outline,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                patientName,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(statusIcon, size: 14, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 12),

                // Booking details
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.schedule,
                        timeOption == 'asap' ? 'ASAP' : 'Scheduled',
                        scheduledDate != null
                            ? _formatDate(scheduledDate)
                            : 'As soon as possible',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.payments,
                        'Price',
                        '${price.toStringAsFixed(0)} EGP',
                      ),
                    ),
                  ],
                ),

                // Action buttons for active bookings
                if ([
                  'confirmed',
                  'assigned',
                  'in-progress',
                ].contains(status)) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (['assigned', 'in-progress'].contains(status))
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // TODO: Call nurse
                            },
                            icon: const Icon(Icons.phone, size: 16),
                            label: const Text('Call'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF17C47F),
                              side: const BorderSide(color: Color(0xFF17C47F)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      if (['assigned', 'in-progress'].contains(status))
                        const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        BookingTrackingPage(booking: booking),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF17C47F),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Track'),
                        ),
                      ),
                    ],
                  ),
                ],

                // Rate button for completed bookings
                if (status == 'completed') ...[
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to rating page
                    },
                    icon: const Icon(Icons.star, size: 16),
                    label: const Text('Rate Service'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFF8E1),
                      foregroundColor: const Color(0xFFF59E0B),
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 36),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${date.day} ${months[date.month - 1]}, ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
