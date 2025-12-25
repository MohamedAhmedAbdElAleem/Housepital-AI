import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_constants.dart';
import '../error/exceptions.dart';
import '../utils/token_manager.dart';

class ApiService {
  final http.Client client;

  ApiService({http.Client? client}) : client = client ?? http.Client();

  /// Get headers with authentication token
  Future<Map<String, String>> _getHeaders() async {
    final headers = Map<String, String>.from(ApiConstants.headers);
    final token = await TokenManager.getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// GET request
  Future<dynamic> get(String endpoint) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final headers = await _getHeaders();

      final response = await client
          .get(url, headers: headers)
          .timeout(ApiConstants.connectionTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('No internet connection');
    } on http.ClientException {
      throw NetworkException('Failed to connect to server');
    } on UnauthorizedException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on NetworkException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  /// POST request
  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final headers = await _getHeaders();

      final response = await client
          .post(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConstants.connectionTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('No internet connection');
    } on http.ClientException {
      throw NetworkException('Failed to connect to server');
    } on UnauthorizedException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on NetworkException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  /// PUT request
  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final headers = await _getHeaders();

      final response = await client
          .put(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConstants.connectionTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('No internet connection');
    } on http.ClientException {
      throw NetworkException('Failed to connect to server');
    } on UnauthorizedException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on NetworkException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  /// DELETE request
  Future<dynamic> delete(String endpoint) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');

      final response = await client
          .delete(url, headers: ApiConstants.headers)
          .timeout(ApiConstants.connectionTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('No internet connection');
    } on http.ClientException {
      throw NetworkException('Failed to connect to server');
    } on UnauthorizedException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on NetworkException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  /// Handle HTTP response
  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      // Success
      if (response.body.isEmpty) {
        return null;
      }
      return jsonDecode(response.body);
    } else if (statusCode == 400) {
      // Bad Request - Validation errors
      final data = jsonDecode(response.body);
      throw ValidationException(
        data['message'] ?? 'Validation failed',
        errors: data['errors'],
      );
    } else if (statusCode == 401) {
      // Unauthorized
      final data = jsonDecode(response.body);
      throw UnauthorizedException(data['message'] ?? 'Unauthorized');
    } else if (statusCode == 404) {
      // Not Found
      throw NotFoundException('Resource not found');
    } else if (statusCode >= 500) {
      // Server Error
      final data = jsonDecode(response.body);
      throw ServerException(data['message'] ?? 'Server error');
    } else {
      throw ServerException('Unexpected error with status code: $statusCode');
    }
  }

  /// Dispose client
  void dispose() {
    client.close();
  }
}
