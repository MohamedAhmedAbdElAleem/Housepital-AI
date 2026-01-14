class DoctorModel {
  final String? id;
  final String userId;
  final String licenseNumber;
  final String specialization;
  final int yearsOfExperience;
  final List<String> qualifications;
  final String? bio;
  final String? gender;
  final String? nationalIdUrl;
  final String? licenseUrl;
  final String verificationStatus;
  final String? rejectionReason;
  // Booking Settings
  final String bookingMode; // 'slots' or 'queue'
  final int minAdvanceBookingHours;
  final bool rushBookingEnabled;
  final int rushBookingPremiumPercent;
  // Metrics
  final num reliabilityRate;
  final num rating;
  final int totalRatings;

  DoctorModel({
    this.id,
    required this.userId,
    required this.licenseNumber,
    required this.specialization,
    required this.yearsOfExperience,
    this.qualifications = const [],
    this.bio,
    this.gender,
    this.nationalIdUrl,
    this.licenseUrl,
    this.verificationStatus = 'pending',
    this.rejectionReason,
    this.bookingMode = 'slots',
    this.minAdvanceBookingHours = 3,
    this.rushBookingEnabled = false,
    this.rushBookingPremiumPercent = 25,
    this.reliabilityRate = 100,
    this.rating = 0,
    this.totalRatings = 0,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['_id'],
      userId: json['user'] is Map ? json['user']['_id'] : (json['user'] ?? ''),
      licenseNumber: json['licenseNumber'] ?? '',
      specialization: json['specialization'] ?? '',
      yearsOfExperience: json['yearsOfExperience'] ?? 0,
      qualifications: json['qualifications'] != null
          ? List<String>.from(json['qualifications'])
          : [],
      bio: json['bio'],
      gender: json['gender'],
      nationalIdUrl: json['nationalIdUrl'],
      licenseUrl: json['licenseUrl'],
      verificationStatus: json['verificationStatus'] ?? 'pending',
      rejectionReason: json['rejectionReason'],
      bookingMode: json['bookingMode'] ?? 'slots',
      minAdvanceBookingHours: json['minAdvanceBookingHours'] ?? 3,
      rushBookingEnabled: json['rushBookingEnabled'] ?? false,
      rushBookingPremiumPercent: json['rushBookingPremiumPercent'] ?? 25,
      reliabilityRate: json['reliabilityRate'] ?? 100,
      rating: json['rating'] ?? 0,
      totalRatings: json['totalRatings'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'user': userId,
      'licenseNumber': licenseNumber,
      'specialization': specialization,
      'yearsOfExperience': yearsOfExperience,
      'qualifications': qualifications,
      if (bio != null) 'bio': bio,
      if (gender != null) 'gender': gender,
      if (nationalIdUrl != null) 'nationalIdUrl': nationalIdUrl,
      if (licenseUrl != null) 'licenseUrl': licenseUrl,
      'verificationStatus': verificationStatus,
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
      'bookingMode': bookingMode,
      'minAdvanceBookingHours': minAdvanceBookingHours,
      'rushBookingEnabled': rushBookingEnabled,
      'rushBookingPremiumPercent': rushBookingPremiumPercent,
    };
  }
}
