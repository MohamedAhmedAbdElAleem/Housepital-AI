import '../../../../core/network/api_service.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/otp_models.dart';

abstract class OTPRemoteDataSource {
  Future<OTPResponse> requestOTP(OTPRequest request);
  Future<OTPResponse> verifyOTP(OTPVerifyRequest request);
  Future<OTPResponse> resendOTP(String contact);
}

class OTPRemoteDataSourceImpl implements OTPRemoteDataSource {
  final ApiService apiService;

  OTPRemoteDataSourceImpl({required this.apiService});

  @override
  Future<OTPResponse> requestOTP(OTPRequest request) async {
    try {
      final response = await apiService.post(
        ApiConstants.otpRequest,
        body: request.toJson(),
      );

      return OTPResponse.fromJson(response);
    } on UnauthorizedException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on NetworkException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to request OTP: ${e.toString()}');
    }
  }

  @override
  Future<OTPResponse> verifyOTP(OTPVerifyRequest request) async {
    try {
      final response = await apiService.post(
        ApiConstants.otpVerify,
        body: request.toJson(),
      );

      return OTPResponse.fromJson(response);
    } on UnauthorizedException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on NetworkException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to verify OTP: ${e.toString()}');
    }
  }

  @override
  Future<OTPResponse> resendOTP(String contact) async {
    try {
      final response = await apiService.post(
        ApiConstants.otpResend,
        body: {'contact': contact},
      );

      return OTPResponse.fromJson(response);
    } on UnauthorizedException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on NetworkException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to resend OTP: ${e.toString()}');
    }
  }
}
