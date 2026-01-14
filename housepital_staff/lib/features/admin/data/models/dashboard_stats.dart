class DashboardStats {
  final int totalUsers;
  final int totalDoctors;
  final int totalNurses;
  final int totalCustomers;
  final int onlineNurses;
  final int todayBookings;
  final int completedBookings;
  final int pendingVerifications;
  final double avgRating;

  DashboardStats({
    required this.totalUsers,
    required this.totalDoctors,
    required this.totalNurses,
    required this.totalCustomers,
    required this.onlineNurses,
    required this.todayBookings,
    required this.completedBookings,
    required this.pendingVerifications,
    required this.avgRating,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    final users = json['users'] ?? {};
    final byRole = users['byRole'] ?? {};
    final doctorStats = byRole['doctor'] ?? {};
    final nurseStats = byRole['nurse'] ?? {};
    final customerStats = byRole['customer'] ?? {};
    final providers = json['providers'] ?? {};
    final nursesProvider = providers['nurses'] ?? {};
    final today = json['today'] ?? {};
    final bookings = json['bookings'] ?? {};
    final pending = json['pendingVerifications'] ?? {};

    // Use only the users pending count (all users including doctors/nurses are in User model)
    // Don't add nurses + doctors as they may be duplicates from separate models
    final usersPending = (pending['users'] ?? 0) as int;

    return DashboardStats(
      totalUsers: users['total'] ?? 0,
      totalDoctors: doctorStats['total'] ?? 0,
      totalNurses: nurseStats['total'] ?? 0,
      totalCustomers: customerStats['total'] ?? 0,
      onlineNurses: nursesProvider['online'] ?? 0,
      todayBookings: today['newBookings'] ?? 0,
      completedBookings: today['completedBookings'] ?? 0,
      pendingVerifications: usersPending,
      avgRating: (bookings['avgRating'] ?? 0).toDouble(),
    );
  }

  factory DashboardStats.empty() {
    return DashboardStats(
      totalUsers: 0,
      totalDoctors: 0,
      totalNurses: 0,
      totalCustomers: 0,
      onlineNurses: 0,
      todayBookings: 0,
      completedBookings: 0,
      pendingVerifications: 0,
      avgRating: 0.0,
    );
  }
}
