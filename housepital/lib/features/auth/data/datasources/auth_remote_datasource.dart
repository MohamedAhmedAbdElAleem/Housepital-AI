import '../../../../core/network/api_service.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/register_request.dart';
import '../models/login_request.dart';
import '../models/auth_response.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> register(RegisterRequest request);
  Future<AuthResponse> login(LoginRequest request);
  Future<AuthResponse> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiService apiService;

  AuthRemoteDataSourceImpl({required this.apiService});

  @override
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await apiService.post(
        ApiConstants.register,
        body: request.toJson(),
      );

      return AuthResponse.fromJson(response);
    } on ValidationException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to register: ${e.toString()}');
    }
  }

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await apiService.post(
        ApiConstants.login,
        body: request.toJson(),
      );

      return AuthResponse.fromJson(response);
    } on UnauthorizedException {
      rethrow;
    } on NetworkException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to login: ${e.toString()}');
    }
  }

  @override
  Future<AuthResponse> getCurrentUser() async {
    try {
      final response = await apiService.get(ApiConstants.getCurrentUser);

      return AuthResponse.fromJson(response);
    } on UnauthorizedException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to get current user: ${e.toString()}');
    }
  }
}
