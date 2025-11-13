// Service Model
class ServiceModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final int duration; // in minutes
  final bool suppliesIncluded;
  final List<String> requiredSupplies;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.duration,
    required this.suppliesIncluded,
    required this.requiredSupplies,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      duration: json['duration'] ?? 0,
      suppliesIncluded: json['suppliesIncluded'] ?? false,
      requiredSupplies: List<String>.from(json['requiredSupplies'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'duration': duration,
      'suppliesIncluded': suppliesIncluded,
      'requiredSupplies': requiredSupplies,
    };
  }
}
