class UserModel {
  final String id;
  final String name;
  final String email;
  final String mobile;
  final bool isVerified;
  final String role;
  final double wallet;
  final int totalVisits;
  final int savedServices;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.isVerified,
    required this.role,
    this.wallet = 0,
    this.totalVisits = 0,
    this.savedServices = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      isVerified: json['isVerified'] ?? false,
      role: json['role'] ?? 'customer',
      wallet: (json['wallet'] ?? 0).toDouble(),
      totalVisits: json['totalVisits'] ?? 0,
      savedServices: json['savedServices'] ?? 0,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'isVerified': isVerified,
      'role': role,
      'wallet': wallet,
      'totalVisits': totalVisits,
      'savedServices': savedServices,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, mobile: $mobile, role: $role, wallet: $wallet)';
  }
}
