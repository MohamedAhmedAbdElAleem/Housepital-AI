/// Booking model for nursing visits
class NurseBooking {
  final String id;
  final String type;
  final String serviceName;
  final double servicePrice;
  final String patientId;
  final String patientName;
  final String? patientPhone;
  final String? patientEmail;
  final String status;
  final String? notes;
  final String timeOption;
  final DateTime? scheduledDate;
  final String? scheduledTime;
  final BookingAddress? address;
  final String? visitPin;
  final DateTime? visitStartedAt;
  final DateTime? visitEndedAt;
  final DateTime createdAt;

  NurseBooking({
    required this.id,
    required this.type,
    required this.serviceName,
    required this.servicePrice,
    required this.patientId,
    required this.patientName,
    this.patientPhone,
    this.patientEmail,
    required this.status,
    this.notes,
    required this.timeOption,
    this.scheduledDate,
    this.scheduledTime,
    this.address,
    this.visitPin,
    this.visitStartedAt,
    this.visitEndedAt,
    required this.createdAt,
  });

  factory NurseBooking.fromJson(Map<String, dynamic> json) {
    // Parse user data if populated
    String patientName = json['patientName'] ?? 'Unknown Patient';
    String? patientPhone;
    String? patientEmail;

    if (json['userId'] is Map) {
      final user = json['userId'] as Map<String, dynamic>;
      patientName = user['name'] ?? patientName;
      patientPhone = user['mobile'];
      patientEmail = user['email'];
    }

    return NurseBooking(
      id: json['_id'] ?? '',
      type: json['type'] ?? 'home_nursing',
      serviceName: json['serviceName'] ?? 'Unknown Service',
      servicePrice: (json['servicePrice'] ?? 0).toDouble(),
      patientId: json['patientId']?.toString() ?? '',
      patientName: patientName,
      patientPhone: patientPhone,
      patientEmail: patientEmail,
      status: json['status'] ?? 'pending',
      notes: json['notes'],
      timeOption: json['timeOption'] ?? 'asap',
      scheduledDate:
          json['scheduledDate'] != null
              ? DateTime.tryParse(json['scheduledDate'])
              : null,
      scheduledTime: json['scheduledTime'],
      address:
          json['address'] != null
              ? BookingAddress.fromJson(json['address'])
              : null,
      visitPin: json['visitPin'],
      visitStartedAt:
          json['visitStartedAt'] != null
              ? DateTime.tryParse(json['visitStartedAt'])
              : null,
      visitEndedAt:
          json['visitEndedAt'] != null
              ? DateTime.tryParse(json['visitEndedAt'])
              : null,
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
              : DateTime.now(),
    );
  }

  bool get isAsap => timeOption == 'asap';
  bool get isAssigned => status == 'assigned';
  bool get isInProgress => status == 'in-progress';
  bool get isCompleted => status == 'completed';
}

class BookingAddress {
  final String? street;
  final String? area;
  final String? city;
  final String? state;
  final double? lat;
  final double? lng;

  BookingAddress({
    this.street,
    this.area,
    this.city,
    this.state,
    this.lat,
    this.lng,
  });

  factory BookingAddress.fromJson(Map<String, dynamic> json) {
    double? lat;
    double? lng;

    if (json['coordinates'] != null &&
        json['coordinates']['coordinates'] is List) {
      final coords = json['coordinates']['coordinates'] as List;
      if (coords.length >= 2) {
        lng = (coords[0] as num?)?.toDouble();
        lat = (coords[1] as num?)?.toDouble();
      }
    }

    return BookingAddress(
      street: json['street'],
      area: json['area'],
      city: json['city'],
      state: json['state'],
      lat: lat,
      lng: lng,
    );
  }

  String get fullAddress {
    final parts = [
      street,
      area,
      city,
      state,
    ].where((p) => p != null && p.isNotEmpty);
    return parts.isEmpty ? 'Address not provided' : parts.join(', ');
  }
}
