class ServiceModel {
  final String? id;
  final String name;
  final String? nameAr;
  final String? description;
  final String? descriptionAr;
  final String type; // 'home_nursing' or 'clinic'
  final String category;
  final String providerId;
  final String providerModel; // 'Nurse' or 'Doctor'
  final List<String> clinicIds;
  final num price;
  final String currency;
  final int durationMinutes;

  // Tools
  final bool requiresTools;
  final List<ServiceTool> toolsList;
  final num estimatedToolsDeposit;

  final bool requiresPrescription;
  final bool isActive;

  ServiceModel({
    this.id,
    required this.name,
    this.nameAr,
    this.description,
    this.descriptionAr,
    required this.type,
    required this.category,
    required this.providerId,
    required this.providerModel,
    this.clinicIds = const [],
    required this.price,
    this.currency = 'EGP',
    required this.durationMinutes,
    this.requiresTools = false,
    this.toolsList = const [],
    this.estimatedToolsDeposit = 0,
    this.requiresPrescription = false,
    this.isActive = true,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['_id'],
      name: json['name'] ?? '',
      nameAr: json['nameAr'],
      description: json['description'],
      descriptionAr: json['descriptionAr'],
      type: json['type'] ?? '',
      category: json['category'] ?? '',
      providerId: json['providerId'] ?? '',
      providerModel: json['providerModel'] ?? 'Doctor',
      clinicIds: json['clinics'] != null
          ? List<String>.from(
              json['clinics'].map((e) => e is String ? e : e['_id']),
            )
          : [],
      price: json['price'] ?? 0,
      currency: json['currency'] ?? 'EGP',
      durationMinutes: json['durationMinutes'] ?? 0,
      requiresTools: json['requiresTools'] ?? false,
      toolsList: json['toolsList'] != null
          ? (json['toolsList'] as List)
                .map((e) => ServiceTool.fromJson(e))
                .toList()
          : [],
      estimatedToolsDeposit: json['estimatedToolsDeposit'] ?? 0,
      requiresPrescription: json['requiresPrescription'] ?? false,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      if (nameAr != null) 'nameAr': nameAr,
      if (description != null) 'description': description,
      if (descriptionAr != null) 'descriptionAr': descriptionAr,
      'type': type,
      'category': category,
      'providerId': providerId,
      'providerModel': providerModel,
      'clinics': clinicIds,
      'price': price,
      'currency': currency,
      'durationMinutes': durationMinutes,
      'requiresTools': requiresTools,
      'toolsList': toolsList.map((e) => e.toJson()).toList(),
      'estimatedToolsDeposit': estimatedToolsDeposit,
      'requiresPrescription': requiresPrescription,
      'isActive': isActive,
    };
  }
}

class ServiceTool {
  final String name;
  final num estimatedCost;

  ServiceTool({required this.name, required this.estimatedCost});

  factory ServiceTool.fromJson(Map<String, dynamic> json) {
    return ServiceTool(
      name: json['name'] ?? '',
      estimatedCost: json['estimatedCost'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'estimatedCost': estimatedCost};
  }
}
