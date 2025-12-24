enum ServiceType { scheduled, urgent, regular }

enum ServiceCategory {
  postSurgicalCare,
  elderlyChronicCare,
  injection,
  brokenBones,
  other,
}

enum ProviderType { doctor, nurse }

extension ServiceTypeExtension on ServiceType {
  String get name {
    switch (this) {
      case ServiceType.scheduled:
        return 'Scheduled';
      case ServiceType.urgent:
        return 'Urgent (Emergency)';
      case ServiceType.regular:
        return 'Regular';
    }
  }
}

extension ServiceCategoryExtension on ServiceCategory {
  String get name {
    switch (this) {
      case ServiceCategory.postSurgicalCare:
        return 'Post-Surgical Care';
      case ServiceCategory.elderlyChronicCare:
        return 'Elderly / Chronic Diseases Care';
      case ServiceCategory.injection:
        return 'Injection Service';
      case ServiceCategory.brokenBones:
        return 'Broken Bones';
      case ServiceCategory.other:
        return 'Other';
    }
  }
}
