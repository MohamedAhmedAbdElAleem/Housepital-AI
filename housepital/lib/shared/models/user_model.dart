// User Model
class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String userType; // customer, nurse, doctor, admin
  final String? profileImage;
  final bool isVerified;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.userType,
    this.profileImage,
    required this.isVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      userType: json['userType'] ?? 'customer',
      profileImage: json['profileImage'],
      isVerified: json['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'userType': userType,
      'profileImage': profileImage,
      'isVerified': isVerified,
    };
  }
}
