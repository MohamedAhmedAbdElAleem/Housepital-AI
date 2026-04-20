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

        // Save doctor-specific verification data
        if (response.user!.role == 'doctor') {
          if (response.user!.hasProfile == true) {
            await TokenManager.saveHasProfile(true);
            await TokenManager.saveVerificationStatus(
              response.user!.verificationStatus ?? 'pending',
            );
            await TokenManager.saveRejectionReason(
              response.user!.rejectionReason,
            );
          } else {
            await TokenManager.saveHasProfile(false);
          }
        }

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

  Future<void> register({
    required String name,
    required String email,
    required String mobile,
    required String password,
    required String role,
  }) async {
    print('🔐 Starting registration...');
    print('   Name: $name');
    print('   Email: $email');
    print('   Mobile: $mobile');
    print('   Role: $role');

    emit(AuthLoading());
    try {
      final request = RegisterRequest(
        name: name,
        email: email,
        password: password,
        role: role,
        mobile: mobile,
      );

      print('📤 Sending registration request...');
      final response = await repository.register(request);

      print('📥 Registration response received:');
      print('   Success: ${response.success}');
      print('   Message: ${response.message}');

      if (response.success && response.user != null) {
        print('✅ Registration successful!');
        if (response.token != null) {
          await TokenManager.saveToken(response.token!);
          print('   Token saved');
        }
        await TokenManager.saveUserId(response.user!.id);
        await TokenManager.saveUserRole(response.user!.role);
        print('   User data saved');

        emit(AuthAuthenticated(response.user!));
      } else {
        print('❌ Registration failed: ${response.message}');
        emit(AuthError(response.message));
      }
    } on AppException catch (e) {
      print('❌ AppException: ${e.message}');
      emit(AuthError(e.message));
    } catch (e) {
      print('❌ Unexpected error: $e');
      emit(AuthError('An unexpected error occurred'));
    }
  }

  Future<void> logout() async {
    await TokenManager.deleteToken();
    await TokenManager.deleteUserId();
    await TokenManager.deleteUserRole();
    emit(AuthInitial());
  }
}
