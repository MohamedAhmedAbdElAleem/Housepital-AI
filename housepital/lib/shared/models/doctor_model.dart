import 'service_model.dart';
import 'clinic_model.dart';

class DoctorModel {
  final String id;
  final String userId;
  final String name;
  final String specialization;
  final String profilePicture;
  final double consultationPrice;
  final String bio;
  final int experienceYears;
  final double rating;
  final int reviewCount;
  final List<ServiceModel> services;
  final List<ClinicModel> clinics;

  DoctorModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.specialization,
    required this.profilePicture,
    required this.consultationPrice,
    required this.bio,
    required this.experienceYears,
    required this.rating,
    required this.reviewCount,
    this.services = const [],
    this.clinics = const [],
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    var userData = json['user'] ?? {};
    
    // Parse Services if available
    var servicesList = <ServiceModel>[];
    if (json['services'] != null) {
      servicesList = (json['services'] as List)
          .map((e) => ServiceModel.fromJson(e))
          .toList();
    }

    // Parse Clinics if available
    var clinicsList = <ClinicModel>[];
    if (json['clinics'] != null) {
      clinicsList = (json['clinics'] as List)
          .map((e) => ClinicModel.fromJson(e))
          .toList();
    }

    return DoctorModel(
      id: json['_id'] ?? '',
      userId: userData['_id'] ?? '',
      name: userData['name'] ?? 'Doctor',
      specialization: json['specialization'] ?? '',
      profilePicture: userData['profilePictureUrl'] ?? '',
      consultationPrice: (json['consultationFee'] ?? 0).toDouble(),
      bio: json['bio'] ?? '',
      experienceYears: json['experienceYears'] ?? 0,
      rating: 0.0,
      reviewCount: 0,
      services: servicesList,
      clinics: clinicsList,
    );
  }
}
