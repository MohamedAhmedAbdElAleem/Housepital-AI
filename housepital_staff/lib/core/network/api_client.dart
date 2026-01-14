import 'dart:io';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../utils/token_manager.dart';
import '../error/exceptions.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenManager.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          // Use IPv4 loopback for Android emulator access to localhost
          if (Platform.isAndroid && options.baseUrl.contains('localhost')) {
            options.baseUrl = options.baseUrl.replaceFirst(
              'localhost',
              '10.0.2.2',
            );
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Handle network errors generically
          return handler.next(e);
        },
      ),
    );
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<dynamic> post(String path, {dynamic body}) async {
    try {
      final response = await _dio.post(path, data: body);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<dynamic> put(String path, {dynamic body}) async {
    try {
      final response = await _dio.put(path, data: body);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<dynamic> patch(String path, {dynamic body}) async {
    try {
      final response = await _dio.patch(path, data: body);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<dynamic> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  dynamic _handleResponse(Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data;
    } else if (response.statusCode == 400) {
      throw ValidationException(response.data['message'] ?? 'Bad Request');
    } else if (response.statusCode == 401) {
      throw UnauthorizedException(response.data['message'] ?? 'Unauthorized');
    } else if (response.statusCode == 403) {
      throw ForbiddenException(response.data['message'] ?? 'Forbidden');
    } else if (response.statusCode == 404) {
      throw NotFoundException(response.data['message'] ?? 'Not Found');
    } else {
      throw ServerException(response.data['message'] ?? 'Server Error');
    }
  }

  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return NetworkException('No internet connection');
      case DioExceptionType.badResponse:
        return ServerException('Server returned invalid response');
      default:
        return ServerException('Something went wrong: ${error.message}');
    }
  }
}
