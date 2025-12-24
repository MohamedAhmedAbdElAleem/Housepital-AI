import '../../../../core/error/exceptions.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/register_request.dart';
import '../models/login_request.dart';
import '../models/auth_response.dart';

abstract class AuthRepository {
  Future<AuthResponse> register(RegisterRequest request);
  Future<AuthResponse> login(LoginRequest request);
  Future<AuthResponse> getCurrentUser();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      return await remoteDataSource.register(request);
    } on ValidationException {
      rethrow;
    } on NetworkException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        'Unexpected error during registration: ${e.toString()}',
      );
    }
  }

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      return await remoteDataSource.login(request);
    } on UnauthorizedException {
      rethrow;
    } on NetworkException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Unexpected error during login: ${e.toString()}');
    }
  }

  @override
  Future<AuthResponse> getCurrentUser() async {
    try {
      return await remoteDataSource.getCurrentUser();
    } on UnauthorizedException {
      rethrow;
    } on NetworkException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        'Unexpected error getting current user: ${e.toString()}',
      );
    }
  }
}
