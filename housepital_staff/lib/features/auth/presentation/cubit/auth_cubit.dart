import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../../core/utils/token_manager.dart';
import '../../../../core/error/exceptions.dart';

// States
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final AuthUser user;
  AuthAuthenticated(this.user);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// Cubit
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository;

  AuthCubit({required this.repository}) : super(AuthInitial());

  // Removed selectedRole parameter
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final request = LoginRequest(email: email, password: password);
      final response = await repository.login(request);

      if (response.success && response.user != null) {
        if (response.token != null) {
          await TokenManager.saveToken(response.token!);
        }
        await TokenManager.saveUserId(response.user!.id);
        await TokenManager.saveUserRole(response.user!.role);

        emit(AuthAuthenticated(response.user!));
      } else {
        emit(AuthError(response.message));
      }
    } on AppException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('An unexpected error occurred'));
    }
  }

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    try {
      final token = await TokenManager.getToken();
      if (token != null) {
        // Token exists, fetch user details to restore session
        final user = await repository.getCurrentUser();
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthInitial());
      }
    } catch (e) {
      // If fetching user fails (e.g. token expired), clear session
      await logout();
    }
  }

  Future<void> logout() async {
    await TokenManager.deleteToken();
    await TokenManager.deleteUserId();
    await TokenManager.deleteUserRole();
    emit(AuthInitial());
  }
}
