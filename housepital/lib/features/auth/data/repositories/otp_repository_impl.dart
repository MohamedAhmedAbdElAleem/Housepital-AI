import '../datasources/otp_remote_datasource.dart';
import '../models/otp_models.dart';

abstract class OTPRepository {
  Future<OTPResponse> requestOTP(OTPRequest request);
  Future<OTPResponse> verifyOTP(OTPVerifyRequest request);
  Future<OTPResponse> resendOTP(String contact);
}

class OTPRepositoryImpl implements OTPRepository {
  final OTPRemoteDataSource remoteDataSource;

  OTPRepositoryImpl({required this.remoteDataSource});

  @override
  Future<OTPResponse> requestOTP(OTPRequest request) async {
    return await remoteDataSource.requestOTP(request);
  }

  @override
  Future<OTPResponse> verifyOTP(OTPVerifyRequest request) async {
    return await remoteDataSource.verifyOTP(request);
  }

  @override
  Future<OTPResponse> resendOTP(String contact) async {
    return await remoteDataSource.resendOTP(contact);
  }
}
