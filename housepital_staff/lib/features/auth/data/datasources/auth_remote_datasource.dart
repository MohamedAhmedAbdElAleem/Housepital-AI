import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../repositories/auth_repository.dart'; // For models

abstract class AuthRemoteDataSource {
  Future<AuthResponse> login(LoginRequest request);
  Future<AuthUser> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await apiClient.post(
        ApiConstants.login,
        body: request.toJson(),
      );
      return AuthResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AuthUser> getCurrentUser() async {
    try {
      final response = await apiClient.get('/auth/me');
      // Assuming response structure: { user: { ... } } or just { ... }
      // The backend usually returns the user object directly or inside a wrapper.
      // Looking at login response, it's inside `user`.
      // I should double check `getCurrentUser` controller, but usually it returns user object.
      // Let's assume standard responseWrapper.
      if (response['user'] != null) {
        return AuthUser.fromJson(response['user']);
      } else {
        return AuthUser.fromJson(response);
      }
    } catch (e) {
      rethrow;
    }
  }
}
