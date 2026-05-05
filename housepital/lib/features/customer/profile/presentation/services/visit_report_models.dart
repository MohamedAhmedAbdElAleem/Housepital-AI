enum VitalStatus { normal, high, low, critical, unknown }

class MedicationEntry {
  final String name;
  final String dose;
  final String route;

  const MedicationEntry({
    this.name = '',
    this.dose = '',
    this.route = 'oral',
  });

  factory MedicationEntry.fromJson(Map<String, dynamic> json) {
    return MedicationEntry(
      name: json['name'] ?? '',
      dose: json['dose'] ?? '',
      route: json['route'] ?? 'oral',
    );
  }
}

class VisitReportData {
  final String overallCondition;
  final String consciousnessLevel;
  final int painLevel;
  final List<String> mobility;
  final String woundSiteCondition;

  final int? bpSystolic;
  final int? bpDiastolic;
  final int? heartRate;
  final double? temperature;
  final int? oxygenSaturation;
  final int? respiratoryRate;
  final int? bloodSugar;
  final double? weight;

  final List<String> servicesPerformed;
  final List<MedicationEntry> medications;
  final List<String> procedures;
  final String patientCooperation;

  final String clinicalObservations;
  final bool familyPresent;
  final List<String> homeEnvironment;
  final String patientFamilyConcerns;

  final bool followUpRequired;
  final String followUpUrgency;
  final List<String> recommendedActions;
  final String alertMessage;

  const VisitReportData({
    this.overallCondition = 'stable',
    this.consciousnessLevel = 'alert',
    this.painLevel = 0,
    this.mobility = const [],
    this.woundSiteCondition = 'na',
    this.bpSystolic,
    this.bpDiastolic,
    this.heartRate,
    this.temperature,
    this.oxygenSaturation,
    this.respiratoryRate,
    this.bloodSugar,
    this.weight,
    this.servicesPerformed = const [],
    this.medications = const [],
    this.procedures = const [],
    this.patientCooperation = 'cooperative',
    this.clinicalObservations = '',
    this.familyPresent = false,
    this.homeEnvironment = const [],
    this.patientFamilyConcerns = '',
    this.followUpRequired = false,
    this.followUpUrgency = 'routine',
    this.recommendedActions = const [],
    this.alertMessage = '',
  });

  factory VisitReportData.fromMap(Map<String, dynamic> json) {
    final ps = (json['patientStatus'] as Map<String, dynamic>?) ?? {};
    final v = (json['vitals'] as Map<String, dynamic>?) ?? {};
    final cp = (json['careProvided'] as Map<String, dynamic>?) ?? {};
    final n = (json['notes'] as Map<String, dynamic>?) ?? {};
    final fu = (json['followUp'] as Map<String, dynamic>?) ?? {};

    return VisitReportData(
      overallCondition: ps['overallCondition'] ?? 'stable',
      consciousnessLevel: ps['consciousnessLevel'] ?? 'alert',
      painLevel: (ps['painLevel'] as num?)?.toInt() ?? 0,
      mobility: List<String>.from(ps['mobility'] ?? []),
      woundSiteCondition: ps['woundSiteCondition'] ?? 'na',
      
      bpSystolic: (v['bloodPressure']?['systolic'] as num?)?.toInt(),
      bpDiastolic: (v['bloodPressure']?['diastolic'] as num?)?.toInt(),
      heartRate: (v['heartRate']?['value'] as num?)?.toInt() ?? (v['heartRate'] is num ? (v['heartRate'] as num).toInt() : null),
      temperature: (v['temperature']?['value'] as num?)?.toDouble() ?? (v['temperature'] is num ? (v['temperature'] as num).toDouble() : null),
      oxygenSaturation: (v['oxygenSaturation']?['value'] as num?)?.toInt() ?? (v['oxygenSaturation'] is num ? (v['oxygenSaturation'] as num).toInt() : null),
      respiratoryRate: (v['respiratoryRate'] as num?)?.toInt(),
      bloodSugar: (v['bloodSugar'] as num?)?.toInt(),
      weight: (v['weight'] as num?)?.toDouble(),

      servicesPerformed: List<String>.from(cp['servicesPerformed'] ?? []),
      medications: (cp['medications'] as List? ?? []).map((m) => MedicationEntry.fromJson(m)).toList(),
      procedures: List<String>.from(cp['procedures'] ?? []),
      patientCooperation: cp['patientCooperation'] ?? 'cooperative',

      clinicalObservations: n['clinicalObservations'] ?? '',
      familyPresent: n['familyPresent'] ?? false,
      homeEnvironment: List<String>.from(n['homeEnvironment'] ?? []),
      patientFamilyConcerns: n['patientFamilyConcerns'] ?? '',

      followUpRequired: fu['required'] ?? false,
      followUpUrgency: fu['urgency'] ?? 'routine',
      recommendedActions: List<String>.from(fu['recommendedActions'] ?? []),
      alertMessage: fu['alertMessage'] ?? '',
    );
  }

  VitalStatus get bpStatus {
    final s = bpSystolic;
    final d = bpDiastolic;
    if (s == null || d == null) return VitalStatus.unknown;
    if (s < 70 || s > 180 || d > 120) return VitalStatus.critical;
    if (s < 90 || d < 60) return VitalStatus.low;
    if (s > 140 || d > 90) return VitalStatus.high;
    return VitalStatus.normal;
  }

  VitalStatus get heartRateStatus {
    final hr = heartRate;
    if (hr == null) return VitalStatus.unknown;
    if (hr < 40 || hr > 150) return VitalStatus.critical;
    if (hr < 60) return VitalStatus.low;
    if (hr > 100) return VitalStatus.high;
    return VitalStatus.normal;
  }

  VitalStatus get temperatureStatus {
    final t = temperature;
    if (t == null) return VitalStatus.unknown;
    if (t < 35 || t > 39.5) return VitalStatus.critical;
    if (t < 36.1) return VitalStatus.low;
    if (t > 37.5) return VitalStatus.high;
    return VitalStatus.normal;
  }

  VitalStatus get spo2Status {
    final s = oxygenSaturation;
    if (s == null) return VitalStatus.unknown;
    if (s < 90) return VitalStatus.critical;
    if (s < 95) return VitalStatus.low;
    return VitalStatus.normal;
  }
}
