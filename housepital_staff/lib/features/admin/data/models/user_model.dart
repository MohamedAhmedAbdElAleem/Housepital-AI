class UserModel {
  final String id;
  final String name;
  final String email;
  final String? mobile;
  final String role;
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;
  final String? profileImage;
  final String? verificationStatus;
  final String? idFrontImageUrl;
  final String? idBackImageUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.mobile,
    required this.role,
    required this.isVerified,
    required this.isActive,
    required this.createdAt,
    this.profileImage,
    this.verificationStatus,
    this.idFrontImageUrl,
    this.idBackImageUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown',
      email: json['email'] ?? '',
      mobile: json['mobile'],
      role: json['role'] ?? 'customer',
      isVerified: json['isVerified'] ?? false,
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      profileImage: json['profileImage'],
      verificationStatus: json['verificationStatus'],
      idFrontImageUrl: json['idFrontImageUrl'],
      idBackImageUrl: json['idBackImageUrl'],
    );
  }

  bool get isPending => verificationStatus == 'pending' || !isVerified;

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String get formattedRole {
    return role[0].toUpperCase() + role.substring(1);
  }
}
