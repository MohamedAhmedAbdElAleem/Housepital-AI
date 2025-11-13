enum UserType { customer, nurse, doctor, admin }

extension UserTypeExtension on UserType {
  String get name {
    switch (this) {
      case UserType.customer:
        return 'Customer';
      case UserType.nurse:
        return 'Nurse';
      case UserType.doctor:
        return 'Doctor';
      case UserType.admin:
        return 'Admin';
    }
  }

  String get value {
    switch (this) {
      case UserType.customer:
        return 'customer';
      case UserType.nurse:
        return 'nurse';
      case UserType.doctor:
        return 'doctor';
      case UserType.admin:
        return 'admin';
    }
  }
}
