class ClinicModel {
  final String? id;
  final String doctorId;
  final String name;
  final String? description;
  final ClinicAddress address;
  final String? phone;
  final List<String> images;
  final List<WorkingHour> workingHours;
  final int slotDurationMinutes;
  final int maxPatientsPerSlot;
  final String bookingMode; // 'slots' or 'queue'
  final List<String> verificationDocuments;
  final bool isActive;
  final String verificationStatus;
  final String? rejectionReason;

  ClinicModel({
    this.id,
    required this.doctorId,
    required this.name,
    this.description,
    required this.address,
    this.phone,
    this.images = const [],
    this.workingHours = const [],
    this.slotDurationMinutes = 30,
    this.maxPatientsPerSlot = 1,
    this.bookingMode = 'slots',
    this.verificationDocuments = const [],
    this.isActive = true,
    this.verificationStatus = 'pending',
    this.rejectionReason,
  });

  factory ClinicModel.fromJson(Map<String, dynamic> json) {
    return ClinicModel(
      id: json['_id'],
      doctorId: json['doctor'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      address: ClinicAddress.fromJson(json['address'] ?? {}),
      phone: json['phone'],
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      workingHours: json['workingHours'] != null
          ? (json['workingHours'] as List)
                .map((e) => WorkingHour.fromJson(e))
                .toList()
          : [],
      slotDurationMinutes: json['slotDurationMinutes'] ?? 30,
      maxPatientsPerSlot: json['maxPatientsPerSlot'] ?? 1,
      bookingMode: json['bookingMode'] ?? 'slots',
      verificationDocuments: json['verificationDocuments'] != null
          ? List<String>.from(json['verificationDocuments'])
          : [],
      isActive: json['isActive'] ?? true,
      verificationStatus: json['verificationStatus'] ?? 'pending',
      rejectionReason: json['rejectionReason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'doctor': doctorId,
      'name': name,
      if (description != null) 'description': description,
      'address': address.toJson(),
      if (phone != null) 'phone': phone,
      'images': images,
      'workingHours': workingHours.map((e) => e.toJson()).toList(),
      'slotDurationMinutes': slotDurationMinutes,
      'maxPatientsPerSlot': maxPatientsPerSlot,
      'bookingMode': bookingMode,
      'verificationDocuments': verificationDocuments,
      'isActive': isActive,
      'verificationStatus': verificationStatus,
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
    };
  }
}

class ClinicAddress {
  final String street;
  final String? area;
  final String city;
  final String state;
  final String? zipCode;
  final String? landmark;

  ClinicAddress({
    required this.street,
    this.area,
    required this.city,
    required this.state,
    this.zipCode,
    this.landmark,
  });

  factory ClinicAddress.fromJson(Map<String, dynamic> json) {
    return ClinicAddress(
      street: json['street'] ?? '',
      area: json['area'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zipCode: json['zipCode'],
      landmark: json['landmark'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      if (area != null) 'area': area,
      'city': city,
      'state': state,
      if (zipCode != null) 'zipCode': zipCode,
      if (landmark != null) 'landmark': landmark,
    };
  }
}

class WorkingHour {
  final String day;
  final bool isOpen;
  final String? openTime;
  final String? closeTime;
  final String? breakStart;
  final String? breakEnd;

  WorkingHour({
    required this.day,
    this.isOpen = true,
    this.openTime,
    this.closeTime,
    this.breakStart,
    this.breakEnd,
  });

  factory WorkingHour.fromJson(Map<String, dynamic> json) {
    return WorkingHour(
      day: json['day'] ?? '',
      isOpen: json['isOpen'] ?? true,
      openTime: json['openTime'],
      closeTime: json['closeTime'],
      breakStart: json['breakStart'],
      breakEnd: json['breakEnd'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'isOpen': isOpen,
      if (openTime != null) 'openTime': openTime,
      if (closeTime != null) 'closeTime': closeTime,
      if (breakStart != null) 'breakStart': breakStart,
      if (breakEnd != null) 'breakEnd': breakEnd,
    };
  }
}
