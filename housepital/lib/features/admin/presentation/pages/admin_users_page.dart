import 'package:flutter/material.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/constants/app_colors.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String _searchQuery = '';
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  String _selectedFilter = 'all';

  final List<Map<String, String>> _tabs = [
    {'id': 'all', 'label': 'All'},
    {'id': 'customer', 'label': 'Customers'},
    {'id': 'nurse', 'label': 'Nurses'},
    {'id': 'doctor', 'label': 'Doctors'},
    {'id': 'admin', 'label': 'Admins'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedFilter = _tabs[_tabController.index]['id']!;
          _filterUsers();
        });
      }
    });
    _fetchUsers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();
      // Try to fetch from API, fallback to mock data
      final response = await apiService.get('/api/admin/insights/all-users');

      if (response != null && response['users'] != null) {
        _allUsers = List<Map<String, dynamic>>.from(response['users']);
      } else {
        _allUsers = _getMockUsers();
      }
    } catch (e) {
      _allUsers = _getMockUsers();
    }

    _filterUsers();
    setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> _getMockUsers() {
    return [
      {
        'id': '1',
        'name': 'Ahmed Mohamed',
        'email': 'ahmed@example.com',
        'mobile': '01012345678',
        'role': 'customer',
        'status': 'approved',
        'isVerified': true,
        'createdAt': '2024-12-20',
      },
      {
        'id': '2',
        'name': 'Sarah Ahmed',
        'email': 'sarah@example.com',
        'mobile': '01123456789',
        'role': 'nurse',
        'status': 'approved',
        'isVerified': true,
        'createdAt': '2024-12-19',
      },
      {
        'id': '3',
        'name': 'Dr. Khaled Omar',
        'email': 'khaled@example.com',
        'mobile': '01234567890',
        'role': 'doctor',
        'status': 'pending',
        'isVerified': false,
        'createdAt': '2024-12-24',
      },
      {
        'id': '4',
        'name': 'Fatima Hassan',
        'email': 'fatima@example.com',
        'mobile': '01098765432',
        'role': 'customer',
        'status': 'approved',
        'isVerified': true,
        'createdAt': '2024-12-18',
      },
      {
        'id': '5',
        'name': 'Mohamed Ali',
        'email': 'mohamed.ali@example.com',
        'mobile': '01187654321',
        'role': 'nurse',
        'status': 'approved',
        'isVerified': true,
        'createdAt': '2024-12-15',
      },
      {
        'id': '6',
        'name': 'Laila Mahmoud',
        'email': 'laila@example.com',
        'mobile': '01276543210',
        'role': 'nurse',
        'status': 'approved',
        'isVerified': true,
        'createdAt': '2024-12-10',
      },
      {
        'id': '7',
        'name': 'Admin User',
        'email': 'admin@housepital.com',
        'mobile': '01000000000',
        'role': 'admin',
        'status': 'approved',
        'isVerified': true,
        'createdAt': '2024-01-01',
      },
      {
        'id': '8',
        'name': 'Dr. Amal Nasser',
        'email': 'amal@example.com',
        'mobile': '01198765432',
        'role': 'doctor',
        'status': 'approved',
        'isVerified': true,
        'createdAt': '2024-12-05',
      },
      {
        'id': '9',
        'name': 'Hassan Ibrahim',
        'email': 'hassan@example.com',
        'mobile': '01087654321',
        'role': 'customer',
        'status': 'suspended',
        'isVerified': true,
        'createdAt': '2024-11-20',
      },
      {
        'id': '10',
        'name': 'Nurse Mona',
        'email': 'mona@example.com',
        'mobile': '01176543210',
        'role': 'nurse',
        'status': 'pending',
        'isVerified': false,
        'createdAt': '2024-12-23',
      },
    ];
  }

  void _filterUsers() {
    _filteredUsers =
        _allUsers.where((user) {
          // Filter by role
          if (_selectedFilter != 'all' && user['role'] != _selectedFilter) {
            return false;
          }
          // Filter by search query
          if (_searchQuery.isNotEmpty) {
            final name = (user['name'] ?? '').toString().toLowerCase();
            final email = (user['email'] ?? '').toString().toLowerCase();
            final mobile = (user['mobile'] ?? '').toString();
            final query = _searchQuery.toLowerCase();
            return name.contains(query) ||
                email.contains(query) ||
                mobile.contains(query);
          }
          return true;
        }).toList();
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'customer':
        return const Color(0xFF6366F1);
      case 'nurse':
        return AppColors.primary500;
      case 'doctor':
        return const Color(0xFF3B82F6);
      case 'admin':
        return const Color(0xFFF59E0B);
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return AppColors.success500;
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'suspended':
        return AppColors.error500;
      case 'rejected':
        return AppColors.error500;
      default:
        return Colors.grey;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'customer':
        return Icons.person_rounded;
      case 'nurse':
        return Icons.medical_services_rounded;
      case 'doctor':
        return Icons.local_hospital_rounded;
      case 'admin':
        return Icons.admin_panel_settings_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF6366F1),
                      Color(0xFF4F46E5),
                      Color(0xFF4338CA),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(40),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.people_alt_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'User Management',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '${_allUsers.length} total users',
                                    style: TextStyle(
                                      color: Colors.white.withAlpha(200),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _filterUsers();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by name, email or phone...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Colors.grey[400],
                    ),
                    suffixIcon:
                        _searchQuery.isNotEmpty
                            ? IconButton(
                              icon: Icon(
                                Icons.close_rounded,
                                color: Colors.grey[400],
                              ),
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                  _filterUsers();
                                });
                              },
                            )
                            : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Tabs
          SliverToBoxAdapter(
            child: Container(
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _tabs.length,
                itemBuilder: (context, index) {
                  final tab = _tabs[index];
                  final isSelected = _selectedFilter == tab['id'];
                  final count =
                      tab['id'] == 'all'
                          ? _allUsers.length
                          : _allUsers
                              .where((u) => u['role'] == tab['id'])
                              .length;

                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < _tabs.length - 1 ? 10 : 0,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedFilter = tab['id']!;
                          _filterUsers();
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? const Color(0xFF6366F1)
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow:
                              isSelected
                                  ? [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF6366F1,
                                      ).withAlpha(50),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                  : null,
                        ),
                        child: Row(
                          children: [
                            Text(
                              tab['label']!,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color:
                                    isSelected
                                        ? Colors.white
                                        : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? Colors.white.withAlpha(50)
                                        : Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$count',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Users List
          _isLoading
              ? SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: CircularProgressIndicator(
                      color: AppColors.primary500,
                    ),
                  ),
                ),
              )
              : _filteredUsers.isEmpty
              ? SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No users found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Try adjusting your search or filter',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              : SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final user = _filteredUsers[index];
                    return _buildUserCard(user, index);
                  }, childCount: _filteredUsers.length),
                ),
              ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, int index) {
    final role = user['role'] ?? 'customer';
    final status = user['status'] ?? 'pending';
    final isVerified = user['isVerified'] ?? false;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: () => _showUserDetails(user),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(8),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Colored top bar
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: _getRoleColor(role),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Avatar
                    Stack(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _getRoleColor(role),
                                _getRoleColor(role).withAlpha(180),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              (user['name'] ?? 'U')[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        if (isVerified)
                          Positioned(
                            right: -2,
                            bottom: -2,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.verified,
                                color: AppColors.success500,
                                size: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    // User Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  user['name'] ?? 'Unknown',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(status).withAlpha(25),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  status[0].toUpperCase() + status.substring(1),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusColor(status),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user['email'] ?? '',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getRoleColor(role).withAlpha(20),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getRoleIcon(role),
                                      size: 14,
                                      color: _getRoleColor(role),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      role[0].toUpperCase() + role.substring(1),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: _getRoleColor(role),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.phone_rounded,
                                size: 14,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                user['mobile'] ?? '',
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
                    // Arrow
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: Colors.grey[400],
                      ),
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

  void _showUserDetails(Map<String, dynamic> user) {
    final role = user['role'] ?? 'customer';
    final status = user['status'] ?? 'pending';

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
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getRoleColor(role),
                              _getRoleColor(role).withAlpha(180),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            (user['name'] ?? 'U')[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user['name'] ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user['email'] ?? '',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getRoleColor(role).withAlpha(20),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _getRoleIcon(role),
                                  size: 16,
                                  color: _getRoleColor(role),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  role[0].toUpperCase() + role.substring(1),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: _getRoleColor(role),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status).withAlpha(20),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status[0].toUpperCase() + status.substring(1),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(status),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Details
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          Icons.phone_rounded,
                          'Phone',
                          user['mobile'] ?? 'N/A',
                        ),
                        _buildDetailRow(
                          Icons.email_rounded,
                          'Email',
                          user['email'] ?? 'N/A',
                        ),
                        _buildDetailRow(
                          Icons.calendar_today_rounded,
                          'Joined',
                          user['createdAt'] ?? 'N/A',
                        ),
                        _buildDetailRow(
                          Icons.verified_rounded,
                          'Verified',
                          (user['isVerified'] ?? false) ? 'Yes' : 'No',
                        ),
                        const SizedBox(height: 24),
                        // Actions
                        if (status == 'pending') ...[
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _showSnackBar(
                                      'User rejected',
                                      isError: true,
                                    );
                                  },
                                  icon: const Icon(Icons.close),
                                  label: const Text('Reject'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.error500,
                                    side: BorderSide(color: AppColors.error500),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _showSnackBar('User approved!');
                                  },
                                  icon: const Icon(Icons.check),
                                  label: const Text('Approve'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.success500,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ] else if (status == 'approved') ...[
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _showSnackBar('User suspended', isError: true);
                              },
                              icon: const Icon(Icons.block_rounded),
                              label: const Text('Suspend User'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.error500,
                                side: BorderSide(color: AppColors.error500),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                        ] else if (status == 'suspended') ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _showSnackBar('User reactivated');
                              },
                              icon: const Icon(Icons.restore_rounded),
                              label: const Text('Reactivate User'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success500,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withAlpha(15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF6366F1), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
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
            Text(message),
          ],
        ),
        backgroundColor: isError ? AppColors.error500 : AppColors.success500,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
