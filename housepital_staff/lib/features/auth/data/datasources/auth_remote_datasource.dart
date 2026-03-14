import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../repositories/auth_repository.dart'; // For models

abstract class AuthRemoteDataSource {
  Future<AuthResponse> login(LoginRequest request);
  Future<AuthResponse> register(RegisterRequest request);
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
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await apiClient.post(
        ApiConstants.register,
        body: request.toJson(),
      );
      return AuthResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
