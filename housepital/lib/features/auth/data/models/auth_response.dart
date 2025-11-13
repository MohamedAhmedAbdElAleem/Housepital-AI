import 'user_model.dart';

class AuthResponse {
  final bool success;
  final String message;
  final UserModel? user;
  final String? token;
  final List<ValidationError>? errors;

  AuthResponse({
    required this.success,
    required this.message,
    this.user,
    this.token,
    this.errors,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      token: json['token'],
      errors:
          json['errors'] != null
              ? (json['errors'] as List)
                  .map((e) => ValidationError.fromJson(e))
                  .toList()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'user': user?.toJson(),
      'token': token,
      'errors': errors?.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'AuthResponse(success: $success, message: $message, user: $user, errors: $errors)';
  }
}

class ValidationError {
  final String field;
  final String message;

  ValidationError({required this.field, required this.message});

  factory ValidationError.fromJson(Map<String, dynamic> json) {
    return ValidationError(
      field: json['field'] ?? '',
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'field': field, 'message': message};
  }

  @override
  String toString() {
    return 'ValidationError(field: $field, message: $message)';
  }
}
