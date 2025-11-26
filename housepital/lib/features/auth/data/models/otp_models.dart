class OTPRequest {
  final String contact;
  final String contactType;
  final String purpose;

  OTPRequest({
    required this.contact,
    required this.contactType,
    required this.purpose,
  });

  Map<String, dynamic> toJson() {
    return {'contact': contact, 'contactType': contactType, 'purpose': purpose};
  }
}

class OTPVerifyRequest {
  final String contact;
  final String code;
  final String? otpId;

  OTPVerifyRequest({required this.contact, required this.code, this.otpId});

  Map<String, dynamic> toJson() {
    return {
      'contact': contact,
      'code': code,
      if (otpId != null) 'otpId': otpId,
    };
  }
}

class OTPResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  OTPResponse({required this.success, required this.message, this.data});

  factory OTPResponse.fromJson(Map<String, dynamic> json) {
    return OTPResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }
}
