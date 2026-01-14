class AppointmentModel {
  final String id;
  final String serviceId;
  final String serviceName;
  final double servicePrice;
  final String patientId;
  final String patientName;
  final String? patientProfilePicture;
  final String timeOption; // 'asap', 'schedule'
  final DateTime? scheduledDate;
  final String? scheduledTime;
  final String status; // 'pending', 'confirmed', 'completed', 'cancelled'
  final String paymentStatus;
  final String? notes;
  final String? clinicId;
  final String? clinicName;
  final String? type;

  AppointmentModel({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.servicePrice,
    required this.patientId,
    required this.patientName,
    this.patientProfilePicture,
    required this.timeOption,
    this.scheduledDate,
    this.scheduledTime,
    required this.status,
    required this.paymentStatus,
    this.notes,
    this.clinicId,
    this.clinicName,
    this.type,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    // Parse patient details if populated
    String pName = json['patientName'] ?? 'Unknown';
    String? pPic;
    if (json['patientId'] is Map) {
      pName = json['patientId']['name'] ?? pName;
      pPic = json['patientId']['profilePictureUrl'];
    }

    // Parse clinic details if populated
    String? cName;
    if (json['clinicId'] is Map) {
      cName = json['clinicId']['name'];
    }

    return AppointmentModel(
      id: json['_id'] ?? '',
      serviceId: json['serviceId'] is Map ? json['serviceId']['_id'] : (json['serviceId'] ?? ''),
      serviceName: json['serviceName'] ?? '',
      servicePrice: (json['servicePrice'] ?? 0).toDouble(),
      patientId: json['patientId'] is Map ? json['patientId']['_id'] : (json['patientId'] ?? ''),
      patientName: pName,
      patientProfilePicture: pPic,
      timeOption: json['timeOption'] ?? 'schedule',
      scheduledDate: json['scheduledDate'] != null ? DateTime.parse(json['scheduledDate']) : null,
      scheduledTime: json['scheduledTime'],
      status: json['status'] ?? 'pending',
      paymentStatus: json['paymentStatus'] ?? 'pending',
      notes: json['notes'],
      clinicId: json['clinicId'] is Map ? json['clinicId']['_id'] : (json['clinicId'] ?? ''),
      clinicName: cName,
      type: json['type'],
    );
  }
}
