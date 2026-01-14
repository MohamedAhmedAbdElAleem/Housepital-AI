import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/dashboard_stats.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/admin_repository.dart';

// States
abstract class AdminState {}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminLoaded extends AdminState {
  final DashboardStats stats;
  final List<UserModel> users;
  final List<UserModel> pendingUsers;
  final String selectedFilter;

  AdminLoaded({
    required this.stats,
    required this.users,
    this.pendingUsers = const [],
    this.selectedFilter = 'all',
  });

  AdminLoaded copyWith({
    DashboardStats? stats,
    List<UserModel>? users,
    List<UserModel>? pendingUsers,
    String? selectedFilter,
  }) {
    return AdminLoaded(
      stats: stats ?? this.stats,
      users: users ?? this.users,
      pendingUsers: pendingUsers ?? this.pendingUsers,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }
}

class AdminError extends AdminState {
  final String message;
  AdminError(this.message);
}

// Cubit
class AdminCubit extends Cubit<AdminState> {
  final AdminRepository _repository = AdminRepository();

  AdminCubit() : super(AdminInitial());

  Future<void> loadDashboard() async {
    emit(AdminLoading());
    try {
      final stats = await _repository.getDashboardStats();
      final users = await _repository.getAllUsers();
      final pendingUsers = await _repository.getPendingVerifications();
      emit(AdminLoaded(stats: stats, users: users, pendingUsers: pendingUsers));
    } catch (e) {
      emit(AdminError('Failed to load dashboard: $e'));
    }
  }

  Future<void> filterUsers(String role) async {
    final currentState = state;
    if (currentState is AdminLoaded) {
      emit(AdminLoading());
      try {
        final users = await _repository.getAllUsers(role: role);
        emit(currentState.copyWith(users: users, selectedFilter: role));
      } catch (e) {
        emit(AdminError('Failed to filter users: $e'));
      }
    }
  }

  Future<void> searchUsers(String query) async {
    final currentState = state;
    if (currentState is AdminLoaded) {
      emit(AdminLoading());
      try {
        final users = await _repository.getAllUsers(
          role: currentState.selectedFilter,
          search: query,
        );
        emit(currentState.copyWith(users: users));
      } catch (e) {
        emit(AdminError('Failed to search users: $e'));
      }
    }
  }

  Future<void> refreshStats() async {
    final currentState = state;
    if (currentState is AdminLoaded) {
      try {
        final stats = await _repository.getDashboardStats();
        final pendingUsers = await _repository.getPendingVerifications();
        emit(currentState.copyWith(stats: stats, pendingUsers: pendingUsers));
      } catch (e) {
        // Silently fail on refresh
      }
    }
  }

  /// Returns a map with email status info: {'success': bool, 'emailSent': bool, 'emailMessage': String}
  Future<Map<String, dynamic>> verifyUser(String userId,
      {bool approve = true}) async {
    final currentState = state;
    if (currentState is AdminLoaded) {
      final result = await _repository.verifyUser(userId, approve: approve);
      if (result['success'] == true) {
        // Refresh the lists
        final stats = await _repository.getDashboardStats();
        final pendingUsers = await _repository.getPendingVerifications();
        final users =
            await _repository.getAllUsers(role: currentState.selectedFilter);
        emit(currentState.copyWith(
          stats: stats,
          pendingUsers: pendingUsers,
          users: users,
        ));
      }
      return result;
    }
    return {
      'success': false,
      'emailSent': false,
      'emailMessage': 'Invalid state',
    };
  }

  Future<void> loadPendingVerifications() async {
    final currentState = state;
    if (currentState is AdminLoaded) {
      try {
        final pendingUsers = await _repository.getPendingVerifications();
        emit(currentState.copyWith(pendingUsers: pendingUsers));
      } catch (e) {
        // Silently fail
      }
    }
  }

  Future<void> updateUser(
    String userId, {
    String? name,
    String? email,
    String? mobile,
    String? role,
    String? verificationStatus,
  }) async {
    final currentState = state;
    if (currentState is AdminLoaded) {
      final success = await _repository.updateUser(
        userId,
        name: name,
        email: email,
        mobile: mobile,
        role: role,
        verificationStatus: verificationStatus,
      );
      if (success) {
        // Refresh the lists
        final stats = await _repository.getDashboardStats();
        final pendingUsers = await _repository.getPendingVerifications();
        final users =
            await _repository.getAllUsers(role: currentState.selectedFilter);
        emit(currentState.copyWith(
          stats: stats,
          pendingUsers: pendingUsers,
          users: users,
        ));
      }
    }
  }

  Future<bool> deleteUser(String userId) async {
    final currentState = state;
    if (currentState is AdminLoaded) {
      final success = await _repository.deleteUser(userId);
      if (success) {
        // Refresh the lists
        final stats = await _repository.getDashboardStats();
        final pendingUsers = await _repository.getPendingVerifications();
        final users =
            await _repository.getAllUsers(role: currentState.selectedFilter);
        emit(currentState.copyWith(
          stats: stats,
          pendingUsers: pendingUsers,
          users: users,
        ));
      }
      return success;
    }
    return false;
  }

  Future<bool> deactivateUser(
    String userId, {
    required DateTime startDate,
    required int durationDays,
    String? reason,
  }) async {
    final currentState = state;
    if (currentState is AdminLoaded) {
      final success = await _repository.deactivateUser(
        userId,
        startDate: startDate,
        durationDays: durationDays,
        reason: reason,
      );
      if (success) {
        // Refresh the lists
        final users =
            await _repository.getAllUsers(role: currentState.selectedFilter);
        emit(currentState.copyWith(users: users));
      }
      return success;
    }
    return false;
  }

  Future<bool> reactivateUser(String userId) async {
    final currentState = state;
    if (currentState is AdminLoaded) {
      final success = await _repository.reactivateUser(userId);
      if (success) {
        // Refresh the lists
        final users =
            await _repository.getAllUsers(role: currentState.selectedFilter);
        emit(currentState.copyWith(users: users));
      }
      return success;
    }
    return false;
  }
}
