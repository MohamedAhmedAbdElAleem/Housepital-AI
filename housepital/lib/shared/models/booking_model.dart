// Booking/Request Model
class BookingModel {
  final String id;
  final String serviceId;
  final String customerId;
  final String? providerId; // nurse or doctor id
  final String status; // pending, accepted, completed, cancelled
  final DateTime scheduledDate;
  final String notes;
  final bool suppliesIncluded;
  final double totalPrice;

  BookingModel({
    required this.id,
    required this.serviceId,
    required this.customerId,
    this.providerId,
    required this.status,
    required this.scheduledDate,
    required this.notes,
    required this.suppliesIncluded,
    required this.totalPrice,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? '',
      serviceId: json['serviceId'] ?? '',
      customerId: json['customerId'] ?? '',
      providerId: json['providerId'],
      status: json['status'] ?? 'pending',
      scheduledDate: DateTime.parse(json['scheduledDate']),
      notes: json['notes'] ?? '',
      suppliesIncluded: json['suppliesIncluded'] ?? false,
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceId': serviceId,
      'customerId': customerId,
      'providerId': providerId,
      'status': status,
      'scheduledDate': scheduledDate.toIso8601String(),
      'notes': notes,
      'suppliesIncluded': suppliesIncluded,
      'totalPrice': totalPrice,
    };
  }
}
