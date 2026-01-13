import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
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

      debugPrint('📤 GET $url');

      final response = await client
          .get(url, headers: headers)
          .timeout(ApiConstants.connectionTimeout);

      debugPrint(
        '📥 Response [${response.statusCode}]: ${response.body.length > 500 ? response.body.substring(0, 500) : response.body}',
      );

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

      debugPrint('📤 POST $url');
      debugPrint('   Headers: $headers');
      debugPrint('   Body: $body');

      final response = await client
          .post(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConstants.connectionTimeout);

      debugPrint('📥 Response [${response.statusCode}]: ${response.body}');

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

      debugPrint('📤 PUT $url');
      debugPrint('   Body: $body');

      final response = await client
          .put(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConstants.connectionTimeout);

      debugPrint('📥 Response [${response.statusCode}]: ${response.body}');

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

  /// PATCH request
  Future<dynamic> patch(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final headers = await _getHeaders();

      final response = await client
          .patch(
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
    } else if (statusCode == 403) {
      // Forbidden - Token invalid or expired
      final data = jsonDecode(response.body);
      throw UnauthorizedException(
        data['message'] ?? 'Access forbidden - please login again',
      );
    } else if (statusCode == 404) {
      // Not Found
      throw NotFoundException('Resource not found');
    } else if (statusCode >= 500) {
      // Server Error
      final data = jsonDecode(response.body);
      throw ServerException(data['message'] ?? 'Server error');
    } else {
      // For other status codes, try to get the message from response
      try {
        final data = jsonDecode(response.body);
        throw ServerException(
          data['message'] ?? 'Error with status code: $statusCode',
        );
      } catch (_) {
        throw ServerException('Unexpected error with status code: $statusCode');
      }
    }
  }

  /// POST Multipart request (e.g. for image upload)
  Future<dynamic> postMultipart(
    String endpoint, {
    Map<String, String>? fields,
    File? file,
    String? fileField,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final headers = await _getHeaders();
      // Content-Type is set automatically by MultipartRequest
      headers.remove('Content-Type');

      debugPrint('📤 POST MULTIPART $url');
      debugPrint('   Fields: $fields');
      debugPrint('   File: $fileField -> ${file?.path}');

      var request = http.MultipartRequest('POST', url);
      request.headers.addAll(headers);

      if (fields != null) {
        request.fields.addAll(fields);
      }

      if (file != null && fileField != null) {
        final stream = http.ByteStream(file.openRead());
        final length = await file.length();
        final multipartFile = http.MultipartFile(
          fileField,
          stream,
          length,
          filename: file.path.split('/').last,
        );
        request.files.add(multipartFile);
      }

      final streamedResponse = await client
          .send(request)
          .timeout(ApiConstants.connectionTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('📥 Response [${response.statusCode}]: ${response.body}');

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

  /// Dispose client
  void dispose() {
    client.close();
  }
}
