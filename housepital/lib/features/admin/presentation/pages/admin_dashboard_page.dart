import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/token_manager.dart';
import '../../../../core/services/pdf_report_service.dart';
import 'add_staff_page.dart';
import 'admin_users_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage>
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
      final apiService = ApiService();
      final response = await apiService.get('/api/admin/insights');

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
      'users': {'total': 1247},
      'bookings': {'total': 3456, 'completed': 2890},
      'pendingVerifications': {
        'total': 15,
        'nurses': 8,
        'doctors': 2,
        'users': 5,
      },
      'today': {
        'newBookings': 47,
        'completedBookings': 38,
        'newRegistrations': 12,
        'activeBookings': 20,
      },
      'financial': {
        'today': {'revenue': 4250},
        'thisMonth': {'revenue': 87500},
      },
      'providers': {
        'nurses': {'online': 45, 'total': 128},
      },
      'recentActivity': [
        {
          'type': 'booking',
          'title': 'New booking received',
          'subtitle': 'IV Therapy - Ahmed Ali',
          'time': '2 min ago',
          'icon': Icons.calendar_today,
        },
        {
          'type': 'nurse',
          'title': 'Nurse went online',
          'subtitle': 'Sarah Ahmed is now available',
          'time': '5 min ago',
          'icon': Icons.person,
        },
        {
          'type': 'payment',
          'title': 'Payment received',
          'subtitle': '250 EGP from Mohamed',
          'time': '12 min ago',
          'icon': Icons.payments,
        },
        {
          'type': 'verification',
          'title': 'New verification request',
          'subtitle': 'Dr. Khaled submitted documents',
          'time': '25 min ago',
          'icon': Icons.verified,
        },
        {
          'type': 'booking',
          'title': 'Booking completed',
          'subtitle': 'Wound Care - Fatima Hassan',
          'time': '1 hour ago',
          'icon': Icons.check_circle,
        },
      ],
      'topNurses': [
        {
          'name': 'Sarah Ahmed',
          'rating': 4.9,
          'visits': 234,
          'earnings': 23400,
        },
        {
          'name': 'Mohamed Hassan',
          'rating': 4.8,
          'visits': 198,
          'earnings': 19800,
        },
        {
          'name': 'Laila Mahmoud',
          'rating': 4.8,
          'visits': 187,
          'earnings': 18700,
        },
      ],
      'pendingUsers': [
        {'name': 'Dr. Khaled Omar', 'type': 'Doctor', 'date': 'Dec 24'},
        {'name': 'Nurse Amal Hassan', 'type': 'Nurse', 'date': 'Dec 24'},
        {'name': 'Nurse Fatima Ali', 'type': 'Nurse', 'date': 'Dec 23'},
      ],
    };
  }

  // ==================== ACTION HANDLERS ====================

  void _handleQuickAction(int index) {
    switch (index) {
      case 0:
        _showVerificationSheet();
        break;
      case 1:
        _showAddStaffDialog();
        break;
      case 2:
        _showReportsSheet();
        break;
      case 3:
        _showSettingsSheet();
        break;
    }
  }

  void _showVerificationSheet() {
    final pending = _dashboardData['pendingUsers'] as List? ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.verified_user_rounded,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pending Verifications',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Review and approve users',
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
                // List
                Expanded(
                  child:
                      pending.isEmpty
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 64,
                                  color: AppColors.success500,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'All caught up!',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'No pending verifications',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                          : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: pending.length,
                            itemBuilder: (context, index) {
                              final user = pending[index];
                              return _buildVerificationCard(user);
                            },
                          ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildVerificationCard(Map<String, dynamic> user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    (user['name'] as String? ?? 'U')[0],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary600,
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
                      user['name'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            user['type'] ?? '',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.secondary700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          user['date'] ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showSnackBar('User rejected', isError: true);
                  },
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error500,
                    side: BorderSide(color: AppColors.error500),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showSnackBar('User approved successfully!');
                    _fetchDashboardData();
                  },
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success500,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddStaffPage(staffType: staffType),
      ),
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
                        () {},
                      ),
                      _buildSettingsItem(
                        Icons.lock_rounded,
                        'Security',
                        'Password & authentication',
                        () {},
                      ),
                      _buildSettingsItem(
                        Icons.payment_rounded,
                        'Payment Settings',
                        'Configure payment methods',
                        () {},
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
              onTap: () => _showSnackBar('Bookings page coming soon!'),
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
              onTap: () => _showSnackBar('Staff online page coming soon!'),
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminUsersPage()),
    );
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
        'icon': Icons.settings_rounded,
        'label': 'Settings',
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
      onTap: _showVerificationSheet,
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
                      'Top Performers',
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
                                    '${nurse['rating']}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${nurse['visits']} visits',
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
