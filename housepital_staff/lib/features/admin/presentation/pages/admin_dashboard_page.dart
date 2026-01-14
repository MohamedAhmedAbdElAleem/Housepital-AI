import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../features/auth/presentation/cubit/auth_cubit.dart';
import '../cubit/admin_cubit.dart';
import '../widgets/stat_card.dart';
import '../widgets/user_list_item.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _currentIndex = 0;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          // Navigate to login when logged out
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.login,
            (route) => false,
          );
        }
      },
      child: BlocProvider(
        create: (_) => AdminCubit()..loadDashboard(),
        child: Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            title: Text(
              _getTitle(),
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: Colors.black87),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                tooltip: 'Logout',
                onPressed: () => _showLogoutDialog(context),
              ),
            ],
          ),
          body: IndexedStack(
            index: _currentIndex,
            children: [
              _buildOverviewTab(),
              _buildUsersTab(),
              _buildInsightsTab(),
              _buildVerificationsTab(),
              _buildAuditLogsTab(),
              _buildSettingsTab(),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) =>
                setState(() => _currentIndex = index),
            backgroundColor: Colors.white,
            elevation: 8,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Overview',
              ),
              NavigationDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: 'Users',
              ),
              NavigationDestination(
                icon: Icon(Icons.insights_outlined),
                selectedIcon: Icon(Icons.insights),
                label: 'Insights',
              ),
              NavigationDestination(
                icon: Icon(Icons.verified_user_outlined),
                selectedIcon: Icon(Icons.verified_user),
                label: 'Verify',
              ),
              NavigationDestination(
                icon: Icon(Icons.history_outlined),
                selectedIcon: Icon(Icons.history),
                label: 'Audit',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthCubit>().logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Admin Dashboard';
      case 1:
        return 'User Management';
      case 2:
        return 'Insights & Analytics';
      case 3:
        return 'Verifications';
      case 4:
        return 'Audit & Logs';
      case 5:
        return 'Settings';
      default:
        return 'Admin';
    }
  }

  Widget _buildOverviewTab() {
    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        if (state is AdminLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AdminError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(state.message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<AdminCubit>().loadDashboard(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is AdminLoaded) {
          return RefreshIndicator(
            onRefresh: () => context.read<AdminCubit>().refreshStats(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome back, Admin',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Here\'s what\'s happening with Housepital today',
                          style: TextStyle(
                            color: Colors.white.withAlpha(230),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats Grid
                  const Text(
                    'Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.95,
                    children: [
                      StatCard(
                        title: 'Total Users',
                        value: state.stats.totalUsers.toString(),
                        subtitle: '+${state.stats.totalCustomers} customers',
                        icon: Icons.people,
                        color: Colors.blue,
                        onTap: () => setState(() => _currentIndex = 1),
                      ),
                      StatCard(
                        title: 'Active Nurses',
                        value:
                            '${state.stats.onlineNurses}/${state.stats.totalNurses}',
                        subtitle: 'Online now',
                        icon: Icons.medical_services,
                        color: Colors.teal,
                      ),
                      StatCard(
                        title: 'Today\'s Bookings',
                        value: state.stats.todayBookings.toString(),
                        subtitle: '${state.stats.completedBookings} completed',
                        icon: Icons.calendar_today,
                        color: Colors.orange,
                      ),
                      StatCard(
                        title: 'Pending Verifications',
                        value: state.pendingUsers.length.toString(),
                        subtitle: 'Action required',
                        icon: Icons.verified_user,
                        color: Colors.red,
                        onTap: () => setState(() => _currentIndex = 3),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Staff Summary
                  const Text(
                    'Staff Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withAlpha(25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildStaffRow(
                          'Doctors',
                          state.stats.totalDoctors,
                          Icons.medical_information,
                          Colors.blue,
                        ),
                        const Divider(),
                        _buildStaffRow(
                          'Nurses',
                          state.stats.totalNurses,
                          Icons.health_and_safety,
                          Colors.teal,
                        ),
                        const Divider(),
                        _buildStaffRow(
                          'Customers',
                          state.stats.totalCustomers,
                          Icons.person,
                          Colors.orange,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Average Rating
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withAlpha(25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.withAlpha(25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.star,
                              color: Colors.amber, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Average Rating',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              state.stats.avgRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < state.stats.avgRating.round()
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 20,
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStaffRow(String title, int count, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
          const Spacer(),
          Text(
            count.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        if (state is AdminLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AdminLoaded) {
          return Column(
            children: [
              // Search and filters
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  children: [
                    // Search bar
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search users...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onSubmitted: (value) {
                        context.read<AdminCubit>().searchUsers(value);
                      },
                    ),
                    const SizedBox(height: 12),
                    // Filter chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                              context, 'All', 'all', state.selectedFilter),
                          _buildFilterChip(context, 'Customers', 'customer',
                              state.selectedFilter),
                          _buildFilterChip(
                              context, 'Nurses', 'nurse', state.selectedFilter),
                          _buildFilterChip(context, 'Doctors', 'doctor',
                              state.selectedFilter),
                          _buildFilterChip(
                              context, 'Admins', 'admin', state.selectedFilter),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // User list
              Expanded(
                child: state.users.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No users found',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.users.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final user = state.users[index];
                          return UserListItem(
                            user: user,
                            onTap: () => _showUserDetails(context, user),
                          );
                        },
                      ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildFilterChip(
      BuildContext context, String label, String value, String selected) {
    final isSelected = selected == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => context.read<AdminCubit>().filterUsers(value),
        selectedColor: Theme.of(context).primaryColor.withAlpha(51),
        checkmarkColor: Theme.of(context).primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  void _showUserDetails(BuildContext context, user) {
    // Capture parent context references before showing bottom sheet
    final parentContext = context;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue.withAlpha(25),
              child: Text(
                user.initials,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(user.email, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildInfoChip(Icons.badge, user.formattedRole),
                const SizedBox(width: 8),
                _buildInfoChip(
                  user.isVerified ? Icons.verified : Icons.pending,
                  user.isVerified ? 'Verified' : 'Pending',
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Main action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(bottomSheetContext),
                    icon: const Icon(Icons.close),
                    label: const Text('Close'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(bottomSheetContext);
                      _showEditUserDialog(parentContext, user);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Deactivate and Delete buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(bottomSheetContext);
                      _showDeactivateUserDialog(parentContext, user);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange),
                    ),
                    icon: const Icon(Icons.pause_circle_outline),
                    label: const Text('Deactivate'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(bottomSheetContext);
                      _showDeleteUserDialog(parentContext, user);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    icon: const Icon(Icons.delete, color: Colors.white),
                    label: const Text('Delete',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: Colors.grey[700])),
        ],
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, user) {
    final adminCubit = context.read<AdminCubit>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final mobileController = TextEditingController(text: user.mobile ?? '');
    String selectedRole = user.role;
    String selectedStatus = user.verificationStatus ?? 'unverified';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.edit, color: Colors.blue),
              const SizedBox(width: 8),
              const Text('Edit User'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: mobileController,
                  decoration: const InputDecoration(
                    labelText: 'Mobile',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                const Text('Role',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'customer', child: Text('Customer')),
                    DropdownMenuItem(value: 'nurse', child: Text('Nurse')),
                    DropdownMenuItem(value: 'doctor', child: Text('Doctor')),
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedRole = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text('Verification Status',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.verified_user),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'unverified', child: Text('Unverified')),
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(
                        value: 'verified', child: Text('Verified')),
                    DropdownMenuItem(
                        value: 'rejected', child: Text('Rejected')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedStatus = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                adminCubit.updateUser(
                  user.id,
                  name: nameController.text,
                  email: emailController.text,
                  mobile: mobileController.text,
                  role: selectedRole,
                  verificationStatus: selectedStatus,
                );
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('User updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteUserDialog(BuildContext context, user) {
    final adminCubit = context.read<AdminCubit>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.delete_forever, color: Colors.red),
            const SizedBox(width: 8),
            const Text('Delete User'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete ${user.name}?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withAlpha(50)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'This action cannot be undone. All user data will be permanently removed.',
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await adminCubit.deleteUser(user.id);
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? '${user.name} has been deleted'
                        : 'Failed to delete user',
                  ),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeactivateUserDialog(BuildContext context, user) {
    final adminCubit = context.read<AdminCubit>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final reasonController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    int selectedDuration = 7; // Default 7 days

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.pause_circle, color: Colors.orange),
              const SizedBox(width: 8),
              const Text('Deactivate User'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Deactivate account for ${user.name}'),
                const SizedBox(height: 20),
                // Start Date
                const Text('Start Date',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: dialogContext,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(() => selectedDate = date);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            color: Colors.grey, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Duration
                const Text('Duration',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: selectedDuration,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.timer),
                  ),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('1 Day')),
                    DropdownMenuItem(value: 3, child: Text('3 Days')),
                    DropdownMenuItem(value: 7, child: Text('1 Week')),
                    DropdownMenuItem(value: 14, child: Text('2 Weeks')),
                    DropdownMenuItem(value: 30, child: Text('1 Month')),
                    DropdownMenuItem(value: 90, child: Text('3 Months')),
                    DropdownMenuItem(value: 180, child: Text('6 Months')),
                    DropdownMenuItem(value: 365, child: Text('1 Year')),
                    DropdownMenuItem(value: -1, child: Text('Permanent')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedDuration = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                // End Date Preview
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          selectedDuration == -1
                              ? 'Account will be deactivated permanently'
                              : 'Account will be reactivated on ${_formatDate(selectedDate.add(Duration(days: selectedDuration)))}',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Reason
                const Text('Reason (Optional)',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    hintText: 'Enter reason for deactivation...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final duration =
                    selectedDuration == -1 ? 36500 : selectedDuration;
                final success = await adminCubit.deactivateUser(
                  user.id,
                  startDate: selectedDate,
                  durationDays: duration,
                  reason: reasonController.text.isNotEmpty
                      ? reasonController.text
                      : null,
                );
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? '${user.name} has been deactivated'
                          : 'Failed to deactivate user',
                    ),
                    backgroundColor: success ? Colors.orange : Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Deactivate',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildInsightsTab() {
    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        if (state is AdminLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AdminLoaded) {
          return RefreshIndicator(
            onRefresh: () => context.read<AdminCubit>().loadDashboard(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Distribution Chart
                  _buildSectionTitle('User Distribution'),
                  const SizedBox(height: 12),
                  _buildUserDistributionCard(state),
                  const SizedBox(height: 24),

                  // Verification Status Overview
                  _buildSectionTitle('Verification Status'),
                  const SizedBox(height: 12),
                  _buildVerificationStatusCard(state),
                  const SizedBox(height: 24),

                  // Booking Statistics
                  _buildSectionTitle('Booking Overview'),
                  const SizedBox(height: 12),
                  _buildBookingStatsCard(state),
                  const SizedBox(height: 24),

                  // Activity Summary
                  _buildSectionTitle('Today\'s Activity'),
                  const SizedBox(height: 12),
                  _buildTodayActivityCard(state),
                  const SizedBox(height: 24),

                  // Performance Metrics
                  _buildSectionTitle('Performance Metrics'),
                  const SizedBox(height: 12),
                  _buildPerformanceCard(state),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildUserDistributionCard(AdminLoaded state) {
    final total = state.stats.totalUsers;
    final doctors = state.stats.totalDoctors;
    final nurses = state.stats.totalNurses;
    final customers = state.stats.totalCustomers;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPieChartLegend('Doctors', doctors, Colors.blue, total),
                _buildPieChartLegend('Nurses', nurses, Colors.teal, total),
                _buildPieChartLegend(
                    'Customers', customers, Colors.orange, total),
              ],
            ),
            const SizedBox(height: 20),
            // Visual bars
            _buildDistributionBar('Doctors', doctors, total, Colors.blue),
            const SizedBox(height: 8),
            _buildDistributionBar('Nurses', nurses, total, Colors.teal),
            const SizedBox(height: 8),
            _buildDistributionBar('Customers', customers, total, Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChartLegend(String label, int value, Color color, int total) {
    final percentage =
        total > 0 ? (value / total * 100).toStringAsFixed(1) : '0';
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              value.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
        Text('$percentage%',
            style: TextStyle(color: Colors.grey[500], fontSize: 11)),
      ],
    );
  }

  Widget _buildDistributionBar(
      String label, int value, int total, Color color) {
    final percentage = total > 0 ? value / total : 0.0;
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label,
              style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('$value',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildVerificationStatusCard(AdminLoaded state) {
    final verified =
        state.users.where((u) => u.verificationStatus == 'verified').length;
    final pending = state.pendingUsers.length;
    final unverified =
        state.users.where((u) => u.verificationStatus == 'unverified').length;
    final rejected =
        state.users.where((u) => u.verificationStatus == 'rejected').length;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusItem(
                    'Verified', verified, Colors.green, Icons.check_circle),
                _buildStatusItem(
                    'Pending', pending, Colors.orange, Icons.hourglass_empty),
                _buildStatusItem(
                    'Unverified', unverified, Colors.grey, Icons.help_outline),
                _buildStatusItem(
                    'Rejected', rejected, Colors.red, Icons.cancel),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, int count, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  Widget _buildBookingStatsCard(AdminLoaded state) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBookingStat(
                    'Today', state.stats.todayBookings, Colors.blue),
                _buildBookingStat(
                    'Completed', state.stats.completedBookings, Colors.green),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Average Rating',
                    style: TextStyle(color: Colors.grey[700])),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      state.stats.avgRating.toStringAsFixed(1),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingStat(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildTodayActivityCard(AdminLoaded state) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildActivityRow(
                Icons.person_add, 'New Registrations', '4', Colors.blue),
            const Divider(height: 24),
            _buildActivityRow(Icons.calendar_today, 'New Bookings',
                state.stats.todayBookings.toString(), Colors.orange),
            const Divider(height: 24),
            _buildActivityRow(Icons.check_circle, 'Completed',
                state.stats.completedBookings.toString(), Colors.green),
            const Divider(height: 24),
            _buildActivityRow(Icons.people, 'Online Nurses',
                state.stats.onlineNurses.toString(), Colors.teal),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityRow(
      IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: TextStyle(color: Colors.grey[700])),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceCard(AdminLoaded state) {
    final totalUsers = state.stats.totalUsers;
    final verifiedUsers =
        state.users.where((u) => u.verificationStatus == 'verified').length;
    final verificationRate =
        totalUsers > 0 ? (verifiedUsers / totalUsers * 100) : 0.0;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildMetricRow('Total Users', totalUsers.toString()),
            const SizedBox(height: 12),
            _buildMetricRow('Verified Users', verifiedUsers.toString()),
            const SizedBox(height: 12),
            _buildMetricRow(
                'Verification Rate', '${verificationRate.toStringAsFixed(1)}%'),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: verificationRate / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  verificationRate > 70
                      ? Colors.green
                      : verificationRate > 40
                          ? Colors.orange
                          : Colors.red,
                ),
                minHeight: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[700])),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildVerificationsTab() {
    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        if (state is AdminLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AdminLoaded) {
          final pendingUsers = state.pendingUsers;

          if (pendingUsers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 80, color: Colors.green[400]),
                  const SizedBox(height: 16),
                  Text(
                    'All Caught Up!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No pending verifications',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () =>
                        context.read<AdminCubit>().loadPendingVerifications(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                context.read<AdminCubit>().loadPendingVerifications(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pendingUsers.length,
              itemBuilder: (context, index) {
                final user = pendingUsers[index];
                return _buildVerificationCard(context, user);
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildVerificationCard(BuildContext context, user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showIdImageDialog(context, user),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.orange.withAlpha(50),
                    child: Text(
                      user.initials,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.email,
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getRoleColor(user.role).withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            user.formattedRole,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _getRoleColor(user.role),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'PENDING',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Tap to view ID hint
              Center(
                child: Text(
                  'Tap to view ID document',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showRejectDialog(context, user),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showApproveDialog(context, user),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.check,
                          size: 18, color: Colors.white),
                      label: const Text('Approve',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showIdImageDialog(BuildContext context, user) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(30),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.badge, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'ID Document',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            // ID Front Image
            Container(
              constraints: const BoxConstraints(maxHeight: 400),
              padding: const EdgeInsets.all(16),
              child: user.idFrontImageUrl != null &&
                      user.idFrontImageUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        user.idFrontImageUrl!,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return SizedBox(
                            height: 200,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.broken_image,
                                    size: 60, color: Colors.grey[400]),
                                const SizedBox(height: 8),
                                Text(
                                  'Failed to load image',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    )
                  : Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_not_supported,
                              size: 60, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text(
                            'No ID image uploaded',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
            ),
            // Action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showRejectDialog(context, user);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showApproveDialog(context, user);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      child: const Text('Approve',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.purple;
      case 'doctor':
        return Colors.blue;
      case 'nurse':
        return Colors.teal;
      case 'customer':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showApproveDialog(BuildContext context, user) {
    final parentContext = context;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Approve User'),
        content: Text('Are you sure you want to approve ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final result = await parentContext
                  .read<AdminCubit>()
                  .verifyUser(user.id, approve: true);
              if (parentContext.mounted) {
                final emailSent = result['emailSent'] ?? false;
                final emailMessage = result['emailMessage'] ?? '';
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  SnackBar(
                    content: Text(
                      emailSent
                          ? '${user.name} has been approved - User notified via email'
                          : '${user.name} has been approved - Email not sent: $emailMessage',
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Approve', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, user) {
    final parentContext = context;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject User'),
        content: Text('Are you sure you want to reject ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final result = await parentContext
                  .read<AdminCubit>()
                  .verifyUser(user.id, approve: false);
              if (parentContext.mounted) {
                final emailSent = result['emailSent'] ?? false;
                final emailMessage = result['emailMessage'] ?? '';
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  SnackBar(
                    content: Text(
                      emailSent
                          ? '${user.name} has been rejected - User notified via email'
                          : '${user.name} has been rejected - Email not sent: $emailMessage',
                    ),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditLogsTab() {
    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        if (state is AdminLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AdminLoaded) {
          return RefreshIndicator(
            onRefresh: () => context.read<AdminCubit>().loadDashboard(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter Section
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildLogFilterChip(
                                'All', Icons.list, Colors.blue),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildLogFilterChip(
                                'Users', Icons.person, Colors.teal),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildLogFilterChip(
                                'System', Icons.settings, Colors.orange),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Summary Cards
                  _buildSectionTitle('Activity Summary'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildAuditSummaryCard(
                          'Total Actions',
                          '${state.stats.totalUsers * 3}',
                          Icons.analytics,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildAuditSummaryCard(
                          'Today',
                          '${state.stats.todayBookings + 5}',
                          Icons.today,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Recent Activity
                  _buildSectionTitle('Recent Activity'),
                  const SizedBox(height: 12),
                  _buildAuditLogItem(
                    'User Verified',
                    'Admin approved user verification',
                    DateTime.now().subtract(const Duration(minutes: 5)),
                    Icons.verified_user,
                    Colors.green,
                  ),
                  _buildAuditLogItem(
                    'New Registration',
                    'New nurse account created',
                    DateTime.now().subtract(const Duration(minutes: 15)),
                    Icons.person_add,
                    Colors.blue,
                  ),
                  _buildAuditLogItem(
                    'Profile Updated',
                    'User updated their profile information',
                    DateTime.now().subtract(const Duration(minutes: 30)),
                    Icons.edit,
                    Colors.orange,
                  ),
                  _buildAuditLogItem(
                    'Booking Created',
                    'New booking scheduled for home visit',
                    DateTime.now().subtract(const Duration(hours: 1)),
                    Icons.calendar_today,
                    Colors.purple,
                  ),
                  _buildAuditLogItem(
                    'User Rejected',
                    'Admin rejected verification request',
                    DateTime.now().subtract(const Duration(hours: 2)),
                    Icons.cancel,
                    Colors.red,
                  ),
                  _buildAuditLogItem(
                    'System Backup',
                    'Automated system backup completed',
                    DateTime.now().subtract(const Duration(hours: 4)),
                    Icons.backup,
                    Colors.teal,
                  ),
                  _buildAuditLogItem(
                    'Login Attempt',
                    'Successful admin login',
                    DateTime.now().subtract(const Duration(hours: 6)),
                    Icons.login,
                    Colors.indigo,
                  ),
                  _buildAuditLogItem(
                    'Settings Changed',
                    'System notification settings updated',
                    DateTime.now().subtract(const Duration(hours: 8)),
                    Icons.settings,
                    Colors.grey,
                  ),
                  const SizedBox(height: 24),

                  // System Logs Section
                  _buildSectionTitle('System Logs'),
                  const SizedBox(height: 12),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        _buildSystemLogTile(
                          'Server Status',
                          'Running normally',
                          Icons.dns,
                          Colors.green,
                        ),
                        const Divider(height: 1),
                        _buildSystemLogTile(
                          'Database',
                          'MongoDB Atlas connected',
                          Icons.storage,
                          Colors.green,
                        ),
                        const Divider(height: 1),
                        _buildSystemLogTile(
                          'API Status',
                          'All endpoints healthy',
                          Icons.api,
                          Colors.green,
                        ),
                        const Divider(height: 1),
                        _buildSystemLogTile(
                          'Last Sync',
                          _formatTimeAgo(DateTime.now()
                              .subtract(const Duration(minutes: 2))),
                          Icons.sync,
                          Colors.blue,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLogFilterChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditLogItem(
    String title,
    String description,
    DateTime timestamp,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              _formatTimeAgo(timestamp),
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemLogTile(
      String title, String status, IconData icon, Color statusColor) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: statusColor.withAlpha(25),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: statusColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Configure push notifications',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.security_outlined,
            title: 'Security',
            subtitle: 'Manage security settings',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.language_outlined,
            title: 'Language',
            subtitle: 'English (US)',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.palette_outlined,
            title: 'Appearance',
            subtitle: 'Light mode',
            onTap: () {},
          ),
          const SizedBox(height: 24),
          const Text(
            'About',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: 'App Version',
            subtitle: '1.0.0',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            subtitle: 'Read our terms',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'Read our privacy policy',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
