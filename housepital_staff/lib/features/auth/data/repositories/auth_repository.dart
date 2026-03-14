import '../datasources/auth_remote_datasource.dart';

// ========== Models ==========
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final String role;
  final String? mobile;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.mobile,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'password': password,
    'role': role,
    'mobile': mobile ?? '', // Use empty string if mobile is not provided
  };
}

class AuthResponse {
  final bool success;
  final String message;
  final String? token;
  final AuthUser? user;

  AuthResponse({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      token: json['token'],
      user: json['user'] != null ? AuthUser.fromJson(json['user']) : null,
    );
  }
}

class AuthUser {
  final String id;
  final String role;
  final String name;
  final String email;

  AuthUser({
    required this.id,
    required this.role,
    required this.name,
    required this.email,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] ?? json['_id'] ?? '',
      role: json['role'] ?? 'customer',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

// ========== Repository ==========
abstract class AuthRepository {
  Future<AuthResponse> login(LoginRequest request);
  Future<AuthResponse> register(RegisterRequest request);
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    return await remoteDataSource.login(request);
  }

  @override
  Future<AuthResponse> register(RegisterRequest request) async {
    return await remoteDataSource.register(request);
  }
}
