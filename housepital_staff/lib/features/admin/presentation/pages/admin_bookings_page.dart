import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../cubit/admin_cubit.dart';
import '../../../../core/constants/app_colors.dart';

class AdminBookingsPage extends StatefulWidget {
  const AdminBookingsPage({super.key});

  @override
  State<AdminBookingsPage> createState() => _AdminBookingsPageState();
}

class _AdminBookingsPageState extends State<AdminBookingsPage> {
  String? _statusFilter;
  String? _typeFilter;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  void _fetchBookings() {
    context.read<AdminCubit>().fetchAllBookings(
      status: _statusFilter,
      type: _typeFilter,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Platform Bookings',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchBookings,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: BlocBuilder<AdminCubit, AdminState>(
              builder: (context, state) {
                if (state is AdminLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is AdminBookingsLoaded) {
                  if (state.bookings.isEmpty) {
                    return _buildEmptyState();
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: state.bookings.length,
                    itemBuilder: (context, index) {
                      final booking = state.bookings[index];
                      return _buildBookingCard(booking);
                    },
                  );
                } else if (state is AdminError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(state.message),
                        TextButton(
                          onPressed: _fetchBookings,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              label: 'All Status',
              isSelected: _statusFilter == null,
              onTap: () {
                setState(() => _statusFilter = null);
                _fetchBookings();
              },
            ),
            _buildFilterChip(
              label: 'Pending',
              isSelected: _statusFilter == 'pending',
              onTap: () {
                setState(() => _statusFilter = 'pending');
                _fetchBookings();
              },
            ),
            _buildFilterChip(
              label: 'In Progress',
              isSelected: _statusFilter == 'in-progress',
              onTap: () {
                setState(() => _statusFilter = 'in-progress');
                _fetchBookings();
              },
            ),
            _buildFilterChip(
              label: 'Completed',
              isSelected: _statusFilter == 'completed',
              onTap: () {
                setState(() => _statusFilter = 'completed');
                _fetchBookings();
              },
            ),
            const VerticalDivider(width: 24),
            _buildFilterChip(
              label: 'Home Nursing',
              isSelected: _typeFilter == 'home_nursing',
              onTap: () {
                setState(
                  () =>
                      _typeFilter =
                          _typeFilter == 'home_nursing' ? null : 'home_nursing',
                );
                _fetchBookings();
              },
            ),
            _buildFilterChip(
              label: 'Clinic',
              isSelected: _typeFilter == 'clinic_appointment',
              onTap: () {
                setState(
                  () =>
                      _typeFilter =
                          _typeFilter == 'clinic_appointment'
                              ? null
                              : 'clinic_appointment',
                );
                _fetchBookings();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary500.withOpacity(0.12),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary700 : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
        backgroundColor: Colors.grey[50],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.primary300 : Colors.grey[200]!,
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final status = (booking['status'] as String? ?? 'pending').toLowerCase();
    final type = booking['type'] as String? ?? 'home_nursing';
    final date = DateTime.parse(booking['createdAt']);
    final formattedDate = DateFormat('MMM d, h:mm a').format(date);
    final serviceName = booking['serviceName'] ?? 'Unknown Service';
    final patientName = booking['patientName'] ?? 'Unknown Patient';
    final price = booking['servicePrice'] ?? 0;

    Color statusColor;
    switch (status) {
      case 'completed':
        statusColor = Colors.green;
        break;
      case 'in-progress':
        statusColor = Colors.blue;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showBookingDetails(booking),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Text(
                    formattedDate,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
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
                  Icon(Icons.person_outline, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    patientName,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const Spacer(),
                  Text(
                    'EGP $price',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary700,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Icon(
                    type == 'home_nursing'
                        ? Icons.home_rounded
                        : Icons.local_hospital_rounded,
                    size: 14,
                    color: AppColors.primary500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    type == 'home_nursing' ? 'Home Nursing' : 'Clinic Visit',
                    style: TextStyle(
                      color: AppColors.primary700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'View Details',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBookingDetails(Map<String, dynamic> booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BookingDetailsSheet(booking: booking),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          const Text(
            'No bookings found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _BookingDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> booking;
  const _BookingDetailsSheet({required this.booking});

  @override
  Widget build(BuildContext context) {
    final status = (booking['status'] as String? ?? 'pending');
    final patient = booking['userId'] ?? {};
    final provider = booking['assignedNurse'] ?? booking['doctorId'] ?? {};
    final providerUser = provider['user'] ?? {};

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Booking Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildInfoSection('Service', [
                  _buildInfoRow('Name', booking['serviceName']),
                  _buildInfoRow('Type', booking['type']),
                  _buildInfoRow('Price', 'EGP ${booking['servicePrice']}'),
                  _buildInfoRow('Status', status.toUpperCase()),
                ]),
                const SizedBox(height: 24),
                _buildInfoSection('Patient Information', [
                  _buildInfoRow(
                    'Name',
                    patient['name'] ?? booking['patientName'],
                  ),
                  _buildInfoRow('Email', patient['email'] ?? 'N/A'),
                  _buildInfoRow('Mobile', patient['mobile'] ?? 'N/A'),
                ]),
                if (providerUser.isNotEmpty || provider.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildInfoSection('Provider Information', [
                    _buildInfoRow(
                      'Name',
                      providerUser['name'] ?? 'Assigned Professional',
                    ),
                    _buildInfoRow(
                      'Role',
                      booking['assignedNurse'] != null ? 'Nurse' : 'Doctor',
                    ),
                    _buildInfoRow('Mobile', providerUser['mobile'] ?? 'N/A'),
                  ]),
                ],
                const SizedBox(height: 40),
                if (status != 'cancelled' && status != 'completed')
                  ElevatedButton(
                    onPressed: () {
                      // Logic to manage booking (e.g. cancel as admin)
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[50],
                      foregroundColor: Colors.red,
                      minimumSize: const Size.fromHeight(56),
                      elevation: 0,
                    ),
                    child: const Text('Cancel Booking (Admin Action)'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[500],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value ?? 'N/A',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
