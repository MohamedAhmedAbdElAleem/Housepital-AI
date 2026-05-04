import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/token_manager.dart';
import '../../../../core/services/pdf_report_service.dart';
import '../cubit/admin_cubit.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;

  bool _isLoading = true;
  Map<String, dynamic> _dashboardData = {};
  int _selectedQuickAction = -1;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    );

    _fetchDashboardData();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final apiService = ApiClient();
      final response = await apiService.get('/admin/insights');

      if (mounted) {
        setState(() {
          _dashboardData = response?['data'] ?? _getMockData();
          _isLoading = false;
        });
        _slideController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _dashboardData = _getMockData();
          _isLoading = false;
        });
        _slideController.forward();
      }
    }
  }

  Map<String, dynamic> _getMockData() {
    return {
      'users': {'total': 0},
      'bookings': {'total': 0, 'completed': 0},
      'pendingVerifications': {
        'total': 0,
        'nurses': 0,
        'doctors': 0,
        'users': 0,
      },
      'today': {
        'newBookings': 0,
        'completedBookings': 0,
        'newRegistrations': 0,
        'activeBookings': 0,
      },
      'financial': {
        'today': {'revenue': 0},
        'thisMonth': {'revenue': 0},
      },
      'providers': {
        'nurses': {'online': 0, 'total': 0},
      },
      'recentActivity': [],
      'topNurses': [],
      'pendingUsers': [],
    };
  }

  // ==================== ACTION HANDLERS ====================

  void _handleQuickAction(int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, AppRoutes.adminVerifications);
        break;
      case 1:
        _showAddStaffDialog();
        break;
      case 2:
        _showReportsSheet();
        break;
      case 3:
        Navigator.pushNamed(context, AppRoutes.adminReceipts);
        break;
    }
  }

  void _showOnlineStaffSheet() {
    context.read<AdminCubit>().fetchAllUsers();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => BlocBuilder<AdminCubit, AdminState>(
            builder: (context, state) {
              List<Map<String, dynamic>> onlineStaff = [];
              if (state is AdminAllUsersLoaded) {
                onlineStaff =
                    state.users
                        .where((u) => u is Map<String, dynamic>)
                        .map((u) => u as Map<String, dynamic>)
                        .where(
                          (u) =>
                              (u['role'] == 'nurse' || u['role'] == 'doctor') &&
                              (u['isOnline'] == true),
                        )
                        .toList();
              }
              final bool isLoading = state is AdminLoading;

              return Container(
                height: MediaQuery.of(context).size.height * 0.85,
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  children: [
                    _buildSheetHandle(),
                    _buildSheetHeader(
                      title: 'Online Staff',
                      subtitle:
                          '${onlineStaff.length} providers currently active',
                      icon: Icons.sensors_rounded,
                      iconColor: const Color(0xFFF59E0B),
                    ),
                    Expanded(
                      child:
                          isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : onlineStaff.isEmpty
                              ? _buildEmptyState(
                                icon: Icons.cloud_off_rounded,
                                message:
                                    'No staff members are currently online',
                              )
                              : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: onlineStaff.length,
                                itemBuilder: (context, index) {
                                  final staff = onlineStaff[index];
                                  return _buildOnlineStaffCard(staff);
                                },
                              ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  Widget _buildOnlineStaffCard(Map<String, dynamic> staff) {
    final role = staff['role'] ?? 'staff';
    final roleColor = _getActivityColor(role);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: roleColor.withAlpha(30),
              child: Text(
                (staff['name'] ?? 'S')[0].toUpperCase(),
                style: TextStyle(color: roleColor, fontWeight: FontWeight.bold),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        title: Text(
          staff['name'] ?? 'Unknown Staff',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: roleColor.withAlpha(30),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                role.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  color: roleColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              staff['mobile'] ?? 'No number',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.chat_bubble_outline_rounded,
            color: AppColors.primary500,
          ),
          onPressed: () => _showSnackBar('Messaging feature coming soon!'),
        ),
      ),
    );
  }

  Widget _buildSheetHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildSheetHeader({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(25),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationCard(Map<String, dynamic> doctor) {
    final user = doctor['user'] ?? {};
    final doctorId = doctor['_id'];
    final name = user['name'] ?? 'Unknown';
    final role = user['role'] ?? 'Doctor';
    final specialization = doctor['specialization'] ?? 'General';
    final date =
        user['createdAt'] != null
            ? DateFormat(
              'MMM d, yyyy',
            ).format(DateTime.parse(user['createdAt']))
            : 'Recent';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary500, AppColors.primary600],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    name[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary500.withAlpha(25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            role.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.primary500,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          specialization,
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
              Text(
                date,
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Verification Documents:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildDocButton('National ID', doctor['nationalIdUrl']),
              const SizedBox(width: 8),
              _buildDocButton('License', doctor['licenseUrl']),
              const SizedBox(width: 8),
              _buildDocButton('Degree', doctor['degreeCertificateUrl']),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showRejectionDialog(doctorId),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error500,
                    side: BorderSide(color: AppColors.error500),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Reject',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context.read<AdminCubit>().approveDoctor(doctorId);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success500,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Approve',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocButton(String label, String? url) {
    final bool hasUrl = url != null && url.isNotEmpty;
    return Expanded(
      child: Opacity(
        opacity: hasUrl ? 1.0 : 0.4,
        child: InkWell(
          onTap: hasUrl ? () => _viewDocument(url) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.description_rounded,
                  size: 20,
                  color: hasUrl ? AppColors.primary500 : Colors.grey,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _viewDocument(String url) {
    // Placeholder for document viewing logic
    _showSnackBar('Opening document: ${url.split('/').last}');
  }

  void _showRejectionDialog(String doctorId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reason for Rejection'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Enter reason...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    context.read<AdminCubit>().rejectDoctor(
                      doctorId,
                      controller.text.trim(),
                    );
                    Navigator.pop(context);
                    Navigator.pop(context);
                  } else {
                    _showSnackBar('Please enter a reason', isError: true);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error500,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Reject'),
              ),
            ],
          ),
    );
  }

  void _showAddStaffDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.person_add_rounded,
                    color: Color(0xFF6366F1),
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Add Staff'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Choose the type of staff to add:'),
                const SizedBox(height: 20),
                _buildStaffOption(
                  Icons.medical_services_rounded,
                  'Add Nurse',
                  AppColors.primary500,
                  () {
                    Navigator.pop(context);
                    _navigateToAddStaff('nurse');
                  },
                ),
                const SizedBox(height: 12),
                _buildStaffOption(
                  Icons.local_hospital_rounded,
                  'Add Doctor',
                  const Color(0xFF6366F1),
                  () {
                    Navigator.pop(context);
                    _navigateToAddStaff('doctor');
                  },
                ),
                const SizedBox(height: 12),
                _buildStaffOption(
                  Icons.admin_panel_settings_rounded,
                  'Add Admin',
                  const Color(0xFFF59E0B),
                  () {
                    Navigator.pop(context);
                    _navigateToAddStaff('admin');
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _navigateToAddStaff(String staffType) {
    Navigator.pushNamed(
      context,
      AppRoutes.adminAddStaff,
      arguments: staffType,
    ).then((_) {
      // Refresh dashboard data when returning
      _fetchDashboardData();
    });
  }

  Widget _buildStaffOption(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  void _showReportsSheet() {
    final financial = _dashboardData['financial'] ?? {};
    final bookings = _dashboardData['bookings'] ?? {};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.analytics_rounded,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reports & Analytics',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'View detailed statistics',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Revenue Summary
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF10B981),
                                const Color(0xFF059669),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Revenue This Month',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(200),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${financial['thisMonth']?['revenue'] ?? 0} EGP',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  _buildReportMiniStat(
                                    'Today',
                                    '${financial['today']?['revenue'] ?? 0} EGP',
                                  ),
                                  const SizedBox(width: 20),
                                  _buildReportMiniStat(
                                    'Avg/Day',
                                    '${(financial['thisMonth']?['revenue'] ?? 0) ~/ 30} EGP',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Quick Stats
                        Row(
                          children: [
                            Expanded(
                              child: _buildReportCard(
                                'Total Bookings',
                                '${bookings['total'] ?? 0}',
                                Icons.calendar_today,
                                const Color(0xFF6366F1),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildReportCard(
                                'Completed',
                                '${bookings['completed'] ?? 0}',
                                Icons.check_circle,
                                AppColors.success500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildReportCard(
                                'Active Users',
                                '${_dashboardData['users']?['total'] ?? 0}',
                                Icons.people,
                                const Color(0xFFF59E0B),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildReportCard(
                                'Nurses',
                                '${_dashboardData['providers']?['nurses']?['total'] ?? 0}',
                                Icons.medical_services,
                                AppColors.primary500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Export Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              Navigator.pop(context);
                              await _exportReport();
                            },
                            icon: const Icon(Icons.download_rounded),
                            label: const Text('Export Full Report'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary500,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildReportMiniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildReportCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.settings_rounded,
                          color: Color(0xFF8B5CF6),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Settings',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Manage app configuration',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildSettingsItem(
                        Icons.notifications_rounded,
                        'Notifications',
                        'Manage notification preferences',
                        () => _showNotificationsSettings(),
                      ),
                      _buildSettingsItem(
                        Icons.lock_rounded,
                        'Security',
                        'Password & authentication',
                        () => _showSecuritySettings(),
                      ),
                      _buildSettingsItem(
                        Icons.payment_rounded,
                        'Payment Settings',
                        'Configure payment methods',
                        () => _showPaymentSettings(),
                      ),
                      _buildSettingsItem(
                        Icons.language_rounded,
                        'Language',
                        'Change app language',
                        () {},
                      ),
                      _buildSettingsItem(
                        Icons.info_rounded,
                        'About',
                        'App version & info',
                        () {
                          Navigator.pop(context);
                          _showAboutDialog();
                        },
                      ),
                      const Divider(height: 32),
                      _buildSettingsItem(
                        Icons.logout_rounded,
                        'Logout',
                        'Sign out of admin account',
                        _handleLogout,
                        isDestructive: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildSettingsItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppColors.error500 : AppColors.textPrimary;

    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (isDestructive ? AppColors.error500 : Colors.grey).withAlpha(
            20,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, color: color),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.local_hospital_rounded,
                    color: AppColors.primary500,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Housepital Admin',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Healthcare at Your Doorstep',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Close',
                  style: TextStyle(color: AppColors.primary500),
                ),
              ),
            ],
          ),
    );
  }

  void _showAllActivity() {
    final activities = _dashboardData['recentActivity'] as List? ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(Icons.history_rounded, color: AppColors.primary500),
                      const SizedBox(width: 10),
                      const Text(
                        'All Activity',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: activities.length * 3, // Show more items
                    itemBuilder: (context, index) {
                      final activity = activities[index % activities.length];
                      return _buildActivityTile(activity);
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildActivityTile(Map<String, dynamic> activity) {
    final color = _getActivityColor(activity['type'] ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              activity['icon'] ?? Icons.circle,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  activity['subtitle'] ?? '',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            activity['time'] ?? '',
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? AppColors.error500 : AppColors.success500,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _exportReport() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.primary500),
                const SizedBox(height: 20),
                const Text(
                  'Generating Report...',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  'This may take a few seconds',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
    );

    try {
      // Close loading dialog first
      if (mounted) Navigator.pop(context);

      // Open print/save dialog directly
      final success = await PdfReportService.generateAndShowReport(
        dashboardData: _dashboardData,
      );

      if (!success && mounted) {
        _showSnackBar('Failed to generate report', isError: true);
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        _showSnackBar('Error: ${e.toString()}', isError: true);
      }
    }
  }

  void _showNotificationsSettings() {
    context.read<AdminCubit>().fetchSettings();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (context) => BlocBuilder<AdminCubit, AdminState>(
            builder: (context, state) {
              if (state is AdminLoading) {
                return const SizedBox(
                  height: 300,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final settings =
                  state is AdminSettingsLoaded ? state.settings : {};
              final notifications =
                  settings['adminNotifications'] as Map<String, dynamic>? ?? {};

              return Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Notification Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildToggleItem(
                      'New Bookings',
                      notifications['newBookings'] ?? true,
                      (val) => context.read<AdminCubit>().updateSettings({
                        'adminNotifications': {'newBookings': val},
                      }),
                    ),
                    _buildToggleItem(
                      'New Verifications',
                      notifications['newVerifications'] ?? true,
                      (val) => context.read<AdminCubit>().updateSettings({
                        'adminNotifications': {'newVerifications': val},
                      }),
                    ),
                    _buildToggleItem(
                      'Revenue Alerts',
                      notifications['revenueAlerts'] ?? false,
                      (val) => context.read<AdminCubit>().updateSettings({
                        'adminNotifications': {'revenueAlerts': val},
                      }),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary500,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Close',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  Widget _buildToggleItem(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      value: value,
      activeColor: AppColors.primary500,
      onChanged: onChanged,
    );
  }

  void _showSecuritySettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Security Settings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(
                    Icons.password,
                    color: AppColors.primary500,
                  ),
                  title: const Text('Change Password'),
                  onTap: () {
                    Navigator.pop(context);
                    _showChangePasswordDialog();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.phonelink_lock,
                    color: AppColors.primary500,
                  ),
                  title: const Text('Two-Factor Authentication'),
                  trailing: const Text(
                    'OFF',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () => _showSnackBar('Two-Factor Auth coming soon!'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }

  void _showChangePasswordDialog() {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Change Password'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentController,
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                  ),
                  obscureText: true,
                ),
                TextField(
                  controller: newController,
                  decoration: const InputDecoration(labelText: 'New Password'),
                  obscureText: true,
                ),
                TextField(
                  controller: confirmController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                  ),
                  obscureText: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (newController.text != confirmController.text) {
                    _showSnackBar('Passwords do not match');
                    return;
                  }
                  if (newController.text.length < 6) {
                    _showSnackBar('Password must be at least 6 characters');
                    return;
                  }
                  context.read<AdminCubit>().changePassword(
                    currentController.text,
                    newController.text,
                  );
                  Navigator.pop(context);
                },
                child: const Text('Update'),
              ),
            ],
          ),
    );
  }

  void _showPaymentSettings() {
    context.read<AdminCubit>().fetchSettings();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (context) => BlocBuilder<AdminCubit, AdminState>(
            builder: (context, state) {
              if (state is AdminLoading) {
                return const SizedBox(
                  height: 300,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final settings =
                  state is AdminSettingsLoaded ? state.settings : {};
              final commissionController = TextEditingController(
                text: '${((settings['commissionRate'] ?? 0.10) * 100).toInt()}',
              );
              String selectedSchedule = settings['payoutSchedule'] ?? 'weekly';

              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 24,
                  right: 24,
                  top: 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Platform Commission (%)',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: commissionController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.percent, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Payout Schedule',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedSchedule,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.calendar_today, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items:
                          ['daily', 'weekly', 'monthly']
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s.toUpperCase()),
                                ),
                              )
                              .toList(),
                      onChanged:
                          (val) => selectedSchedule = val ?? selectedSchedule,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final rate = double.tryParse(
                            commissionController.text,
                          );
                          if (rate == null || rate < 0 || rate > 100) {
                            _showSnackBar('Invalid commission rate');
                            return;
                          }
                          context.read<AdminCubit>().updateSettings({
                            'commissionRate': rate / 100,
                            'payoutSchedule': selectedSchedule,
                          });
                          Navigator.pop(context);
                          _showSnackBar('Payment settings updated');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary500,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
    );
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'booking':
        return AppColors.primary500;
      case 'nurse':
        return const Color(0xFF6366F1);
      case 'payment':
        return const Color(0xFF10B981);
      case 'verification':
        return const Color(0xFFF59E0B);
      default:
        return AppColors.textSecondary;
    }
  }

  // ==================== BUILD METHODS ====================

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: _isLoading ? _buildLoadingState() : _buildContent(),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary500.withAlpha(30),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: CircularProgressIndicator(
              color: AppColors.primary500,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading Dashboard...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _fetchDashboardData,
      color: AppColors.primary500,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildAnimatedHeader()),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _slideAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(_slideAnimation),
                child: _buildQuickStats(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _slideAnimation,
              child: _buildQuickActions(),
            ),
          ),
          SliverToBoxAdapter(child: _buildAlertBanner()),
          SliverToBoxAdapter(child: _buildLiveActivityFeed()),
          SliverToBoxAdapter(child: _buildPerformanceOverview()),
          SliverToBoxAdapter(child: _buildTopCustomers()),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    final today = _dashboardData['today'] ?? {};

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 20,
        20,
        30,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary500,
            AppColors.primary600,
            const Color(0xFF1A7F5A),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(
                        (40 + 20 * _pulseController.value).toInt(),
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  );
                },
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome, Admin',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      DateFormat('EEEE, MMMM d').format(DateTime.now()),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withAlpha(200),
                      ),
                    ),
                  ],
                ),
              ),
              _buildHeaderButton(
                Icons.refresh_rounded,
                onTap: _fetchDashboardData,
              ),
              const SizedBox(width: 10),
              _buildHeaderButton(Icons.logout_rounded, onTap: _handleLogout),
            ],
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withAlpha(40)),
            ),
            child: Row(
              children: [
                _buildHighlightStat(
                  '${today['newBookings'] ?? 0}',
                  'New Bookings',
                  Icons.calendar_today_rounded,
                ),
                _buildDivider(),
                _buildHighlightStat(
                  '${today['activeBookings'] ?? 0}',
                  'Active Now',
                  Icons.play_circle_filled_rounded,
                ),
                _buildDivider(),
                _buildHighlightStat(
                  '${today['completedBookings'] ?? 0}',
                  'Completed',
                  Icons.check_circle_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(40),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildHighlightStat(String value, String label, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white.withAlpha(180), size: 18),
              const SizedBox(width: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.white.withAlpha(180)),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 40, color: Colors.white.withAlpha(50));
  }

  Widget _buildQuickStats() {
    final users = _dashboardData['users'] ?? {};
    final bookings = _dashboardData['bookings'] ?? {};
    final financial = _dashboardData['financial'] ?? {};
    final providers = _dashboardData['providers'] ?? {};

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatBubble(
              '${users['total'] ?? 0}',
              'Users',
              const Color(0xFF6366F1),
              Icons.people_alt_rounded,
              onTap: () => _navigateToUsersPage(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatBubble(
              '${bookings['total'] ?? 0}',
              'Bookings',
              AppColors.primary500,
              Icons.event_note_rounded,
              onTap:
                  () => Navigator.pushNamed(context, AppRoutes.adminBookings),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatBubble(
              '${providers['nurses']?['online'] ?? 0}',
              'Online',
              const Color(0xFFF59E0B),
              Icons.circle,
              small: true,
              onTap: () => _showOnlineStaffSheet(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatBubble(
              '${(financial['today']?['revenue'] ?? 0) ~/ 1000}K',
              'Revenue',
              const Color(0xFF10B981),
              Icons.trending_up_rounded,
              onTap: () => _showReportsSheet(),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToUsersPage() {
    Navigator.pushNamed(context, AppRoutes.adminUsers);
  }

  Widget _buildStatBubble(
    String value,
    String label,
    Color color,
    IconData icon, {
    bool small = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(30),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: small ? 16 : 22),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        'icon': Icons.verified_user_rounded,
        'label': 'Verify',
        'color': const Color(0xFFEF4444),
        'badge': _dashboardData['pendingVerifications']?['total'] ?? 0,
      },
      {
        'icon': Icons.person_add_rounded,
        'label': 'Add Staff',
        'color': const Color(0xFF6366F1),
        'badge': 0,
      },
      {
        'icon': Icons.analytics_rounded,
        'label': 'Reports',
        'color': const Color(0xFF10B981),
        'badge': 0,
      },
      {
        'icon': Icons.receipt_long_rounded,
        'label': 'Receipts',
        'color': const Color(0xFF8B5CF6),
        'badge': 0,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(actions.length, (index) {
          final action = actions[index];
          final isSelected = _selectedQuickAction == index;
          final badge = action['badge'] as int;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index < actions.length - 1 ? 10 : 0,
              ),
              child: GestureDetector(
                onTapDown: (_) => setState(() => _selectedQuickAction = index),
                onTapUp: (_) {
                  setState(() => _selectedQuickAction = -1);
                  _handleQuickAction(index);
                },
                onTapCancel: () => setState(() => _selectedQuickAction = -1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? (action['color'] as Color).withAlpha(25)
                            : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          isSelected
                              ? action['color'] as Color
                              : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(8),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            action['icon'] as IconData,
                            color: action['color'] as Color,
                            size: 26,
                          ),
                          if (badge > 0)
                            Positioned(
                              right: -8,
                              top: -8,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: action['color'] as Color,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '$badge',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        action['label'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAlertBanner() {
    final pending = _dashboardData['pendingVerifications'] ?? {};
    final total = pending['total'] ?? 0;

    if (total == 0) return const SizedBox(height: 20);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.adminVerifications),
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6B6B), Color(0xFFEE5A52)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEE5A52).withAlpha(50),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(50),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$total Pending Verifications',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Tap to review pending users',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withAlpha(200),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Review',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEE5A52),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveActivityFeed() {
    final activities = _dashboardData['recentActivity'] as List? ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.success500.withAlpha(
                        (150 + 105 * _pulseController.value).toInt(),
                      ),
                      shape: BoxShape.circle,
                    ),
                  );
                },
              ),
              const SizedBox(width: 10),
              Text(
                'Live Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _showAllActivity,
                child: Text(
                  'See All',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children:
                  activities.take(4).map((activity) {
                    final index = activities.indexOf(activity);
                    final isLast = index == 3 || index == activities.length - 1;
                    return _buildActivityItem(
                      activity['title'] ?? '',
                      activity['subtitle'] ?? '',
                      activity['time'] ?? '',
                      activity['icon'] ?? Icons.circle,
                      _getActivityColor(activity['type'] ?? ''),
                      isLast: isLast,
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String subtitle,
    String time,
    IconData icon,
    Color color, {
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border:
            isLast
                ? null
                : Border(bottom: BorderSide(color: const Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceOverview() {
    final topNurses = _dashboardData['topNurses'] as List? ?? [];
    final financial = _dashboardData['financial'] ?? {};

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF10B981), Color(0xFF059669)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monthly Revenue',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withAlpha(200),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(financial['thisMonth']?['revenue'] ?? 0).toString()} EGP',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.emoji_events_rounded,
                      color: Color(0xFFF59E0B),
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Top Nurses',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...topNurses.asMap().entries.map((entry) {
                  final index = entry.key;
                  final nurse = entry.value;
                  final medals = ['🥇', '🥈', '🥉'];
                  final colors = [
                    const Color(0xFFFFD700),
                    const Color(0xFFC0C0C0),
                    const Color(0xFFCD7F32),
                  ];

                  return Container(
                    margin: EdgeInsets.only(bottom: index < 2 ? 12 : 0),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colors[index].withAlpha(15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colors[index].withAlpha(40)),
                    ),
                    child: Row(
                      children: [
                        Text(
                          medals[index],
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nurse['name'] ?? '',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Color(0xFFF59E0B),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${nurse['rating'] ?? '0.0'}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${nurse['visits'] ?? '0'} visits',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${nurse['earnings']} EGP',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCustomers() {
    final topCustomers = _dashboardData['topCustomers'] as List? ?? [];

    if (topCustomers.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Customers',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'By Visits',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: topCustomers.asMap().entries.map((entry) {
                final index = entry.key;
                final customer = entry.value;
                final isLast = index == topCustomers.length - 1;

                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey[100]!)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primary500.withAlpha(20),
                        backgroundImage: customer['avatar'] != null ? NetworkImage(customer['avatar']) : null,
                        child: customer['avatar'] == null 
                          ? Text(
                              (customer['name'] ?? 'U')[0].toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary700),
                            )
                          : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer['name'] ?? 'Unknown',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              customer['email'] ?? 'No email',
                              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary500.withAlpha(20),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${customer['visits'] ?? 0} visits',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary700,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(Icons.logout_rounded, color: Colors.red),
                SizedBox(width: 10),
                Text('Logout'),
              ],
            ),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await TokenManager.deleteToken();
                  await TokenManager.deleteUserId();
                  await TokenManager.deleteUserRole();
                  if (mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.login,
                      (route) => false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error500,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }
}
