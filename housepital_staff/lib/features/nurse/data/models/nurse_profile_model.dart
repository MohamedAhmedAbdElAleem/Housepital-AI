class NurseProfile {
  final String? id;
  final String? userId;
  final String? licenseNumber;
  final String? specialization;
  final int? yearsOfExperience;
  final List<String> skills;
  final String? bio;
  final String? gender;
  final String? nationalIdUrl;
  final String? degreeUrl;
  final String? licenseUrl;
  final String profileStatus;
  final String verificationStatus;
  final String? rejectionReason;
  final BankAccount? bankAccount;
  final EWallet? eWallet;

  final bool isOnline;
  final WorkZone? workZone;

  NurseProfile({
    this.id,
    this.userId,
    this.licenseNumber,
    this.specialization,
    this.yearsOfExperience,
    this.skills = const [],
    this.bio,
    this.gender,
    this.nationalIdUrl,
    this.degreeUrl,
    this.licenseUrl,
    this.profileStatus = 'incomplete',
    this.verificationStatus = 'pending',
    this.rejectionReason,
    this.bankAccount,
    this.eWallet,
    this.isOnline = false,
    this.workZone,
  });

  factory NurseProfile.fromJson(Map<String, dynamic> json) {
    return NurseProfile(
      id: json['_id'] ?? json['id'],
      userId: json['user']?['_id'] ?? json['user'],
      licenseNumber: json['licenseNumber'],
      specialization: json['specialization'],
      yearsOfExperience: json['yearsOfExperience'],
      skills: json['skills'] != null ? List<String>.from(json['skills']) : [],
      bio: json['bio'],
      gender: json['gender'],
      nationalIdUrl: json['nationalIdUrl'],
      degreeUrl: json['degreeUrl'],
      licenseUrl: json['licenseUrl'],
      profileStatus: json['profileStatus'] ?? 'incomplete',
      verificationStatus: json['verificationStatus'] ?? 'pending',
      rejectionReason: json['rejectionReason'],
      bankAccount:
          json['bankAccount'] != null
              ? BankAccount.fromJson(json['bankAccount'])
              : null,
      eWallet:
          json['eWallet'] != null ? EWallet.fromJson(json['eWallet']) : null,
      isOnline: json['isOnline'] ?? false,
      workZone:
          json['workZone'] != null ? WorkZone.fromJson(json['workZone']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (licenseNumber != null) 'licenseNumber': licenseNumber,
      if (specialization != null) 'specialization': specialization,
      if (yearsOfExperience != null) 'yearsOfExperience': yearsOfExperience,
      'skills': skills,
      if (bio != null) 'bio': bio,
      if (gender != null) 'gender': gender,
      if (nationalIdUrl != null) 'nationalIdUrl': nationalIdUrl,
      if (degreeUrl != null) 'degreeUrl': degreeUrl,
      if (licenseUrl != null) 'licenseUrl': licenseUrl,
      if (bankAccount != null) 'bankAccount': bankAccount!.toJson(),
      if (eWallet != null) 'eWallet': eWallet!.toJson(),
      'isOnline': isOnline,
      if (workZone != null) 'workZone': workZone!.toJson(),
    };
  }

  NurseProfile copyWith({
    String? id,
    String? userId,
    String? licenseNumber,
    String? specialization,
    int? yearsOfExperience,
    List<String>? skills,
    String? bio,
    String? gender,
    String? nationalIdUrl,
    String? degreeUrl,
    String? licenseUrl,
    String? profileStatus,
    String? verificationStatus,
    String? rejectionReason,
    BankAccount? bankAccount,
    EWallet? eWallet,
    bool? isOnline,
    WorkZone? workZone,
  }) {
    return NurseProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      specialization: specialization ?? this.specialization,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      skills: skills ?? this.skills,
      bio: bio ?? this.bio,
      gender: gender ?? this.gender,
      nationalIdUrl: nationalIdUrl ?? this.nationalIdUrl,
      degreeUrl: degreeUrl ?? this.degreeUrl,
      licenseUrl: licenseUrl ?? this.licenseUrl,
      profileStatus: profileStatus ?? this.profileStatus,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      bankAccount: bankAccount ?? this.bankAccount,
      eWallet: eWallet ?? this.eWallet,
      isOnline: isOnline ?? this.isOnline,
      workZone: workZone ?? this.workZone,
    );
  }
}

class WorkZone {
  final double latitude;
  final double longitude;
  final double radiusKm;
  final String address;

  WorkZone({
    this.latitude = 0,
    this.longitude = 0,
    this.radiusKm = 10,
    this.address = 'Unknown',
  });

  factory WorkZone.fromJson(Map<String, dynamic> json) {
    // Backend returns "center": { "coordinates": [long, lat] }
    // We simplify for frontend
    final coords =
        json['center'] != null ? json['center']['coordinates'] : [0.0, 0.0];
    return WorkZone(
      latitude:
          coords is List && coords.length > 1
              ? (coords[1] as num).toDouble()
              : 0.0,
      longitude:
          coords is List && coords.length > 0
              ? (coords[0] as num).toDouble()
              : 0.0,
      radiusKm: (json['radiusKm'] as num?)?.toDouble() ?? 10.0,
      address:
          json['address'] ??
          'My Zone', // Assuming backend might send this or we fetch it
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'center': {
        'type': 'Point',
        'coordinates': [longitude, latitude],
      },
      'radiusKm': radiusKm,
      'address': address,
    };
  }
}

class BankAccount {
  final String? bankName;
  final String? accountNumber;
  final String? accountHolderName;

  BankAccount({this.bankName, this.accountNumber, this.accountHolderName});

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      bankName: json['bankName'],
      accountNumber: json['accountNumber'],
      accountHolderName: json['accountHolderName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (bankName != null) 'bankName': bankName,
      if (accountNumber != null) 'accountNumber': accountNumber,
      if (accountHolderName != null) 'accountHolderName': accountHolderName,
    };
  }
}

class EWallet {
  final String? provider;
  final String? number;

  EWallet({this.provider, this.number});

  factory EWallet.fromJson(Map<String, dynamic> json) {
    return EWallet(provider: json['provider'], number: json['number']);
  }

  Map<String, dynamic> toJson() {
    return {
      if (provider != null) 'provider': provider,
      if (number != null) 'number': number,
    };
  }
}

class ProfileStatus {
  final String profileStatus;
  final bool profileExists;
  final int completionPercentage;
  final String verificationStatus;
  final String? rejectionReason;

  ProfileStatus({
    required this.profileStatus,
    required this.profileExists,
    required this.completionPercentage,
    required this.verificationStatus,
    this.rejectionReason,
  });

  factory ProfileStatus.fromJson(Map<String, dynamic> json) {
    return ProfileStatus(
      profileStatus: json['profileStatus'] ?? 'incomplete',
      profileExists: json['profileExists'] ?? false,
      completionPercentage: json['completionPercentage'] ?? 0,
      verificationStatus: json['verificationStatus'] ?? 'pending',
      rejectionReason: json['rejectionReason'],
    );
  }
}
