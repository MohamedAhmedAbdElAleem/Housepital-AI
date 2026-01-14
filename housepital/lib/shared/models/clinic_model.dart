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
  final bool isActive;

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
    this.isActive = true,
  });

  factory ClinicModel.fromJson(Map<String, dynamic> json) {
    // Handle doctor field - can be String ID or populated object
    String doctorIdValue = '';
    final doctorField = json['doctor'];
    if (doctorField is String) {
      doctorIdValue = doctorField;
    } else if (doctorField is Map) {
      doctorIdValue = doctorField['_id'] ?? '';
    }

    return ClinicModel(
      id: json['_id'],
      doctorId: doctorIdValue,
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
      isActive: json['isActive'] ?? true,
    );
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
}
