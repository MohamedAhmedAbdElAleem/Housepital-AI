class ServiceModel {
  final String? id;
  final String name;
  final String? nameAr;
  final String? description;
  final String? descriptionAr;
  final String type;
  final String category;
  final String providerId;
  final String providerModel;
  final List<String> clinics;
  final double price;
  final String currency;
  final int durationMinutes;
  final bool requiresTools;
  // final List<ServiceTool> toolsList; // Simplified for customer app for now
  final double estimatedToolsDeposit;
  final bool requiresPrescription;
  final bool isActive;

  ServiceModel({
    this.id,
    required this.name,
    this.nameAr,
    this.description,
    this.descriptionAr,
    this.type = 'clinic',
    required this.category,
    required this.providerId,
    required this.providerModel,
    this.clinics = const [],
    required this.price,
    this.currency = 'EGP',
    required this.durationMinutes,
    this.requiresTools = false,
    // this.toolsList = const [],
    this.estimatedToolsDeposit = 0,
    this.requiresPrescription = false,
    this.isActive = true,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['_id'],
      name: json['name'],
      nameAr: json['nameAr'],
      description: json['description'],
      descriptionAr: json['descriptionAr'],
      type: json['type'] ?? 'clinic',
      category: json['category'],
      providerId: json['providerId'],
      providerModel: json['providerModel'],
      clinics: json['clinics'] != null
          ? List<String>.from(json['clinics'])
          : [],
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'EGP',
      durationMinutes: json['durationMinutes'] ?? 0,
      requiresTools: json['requiresTools'] ?? false,
      estimatedToolsDeposit: (json['estimatedToolsDeposit'] ?? 0).toDouble(),
      requiresPrescription: json['requiresPrescription'] ?? false,
      isActive: json['isActive'] ?? true,
    );
  }
}
