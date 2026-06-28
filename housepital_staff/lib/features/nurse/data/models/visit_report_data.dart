/// Data model for structured visit reports.
///
/// Mirrors the backend `VisitReport` MongoDB schema.
class VisitReportData {
  // ── Section A: Patient Status ────────────────────────────────────────────
  final String overallCondition;
  final String consciousnessLevel;
  final int painLevel;
  final List<String> mobility;
  final String woundSiteCondition;

  // ── Section B: Vitals ────────────────────────────────────────────────────
  final int? bpSystolic;
  final int? bpDiastolic;
  final int? heartRate;
  final double? temperature;
  final int? oxygenSaturation;
  final int? respiratoryRate;
  final int? bloodSugar;
  final double? weight;

  // ── Section C: Care Provided ─────────────────────────────────────────────
  final List<String> servicesPerformed;
  final List<MedicationEntry> medications;
  final List<String> procedures;
  final String patientCooperation;

  // ── Section D: Notes ──────────────────────────────────────────────────────
  final String clinicalObservations;
  final bool familyPresent;
  final List<String> homeEnvironment;
  final String patientFamilyConcerns;

  // ── Section E: Follow-up ─────────────────────────────────────────────────
  final bool followUpRequired;
  final String followUpUrgency;
  final List<String> recommendedActions;
  final String alertMessage;

  const VisitReportData({
    // Section A
    this.overallCondition = 'stable',
    this.consciousnessLevel = 'alert',
    this.painLevel = 0,
    this.mobility = const [],
    this.woundSiteCondition = 'na',
    // Section B
    this.bpSystolic,
    this.bpDiastolic,
    this.heartRate,
    this.temperature,
    this.oxygenSaturation,
    this.respiratoryRate,
    this.bloodSugar,
    this.weight,
    // Section C
    this.servicesPerformed = const [],
    this.medications = const [],
    this.procedures = const [],
    this.patientCooperation = 'cooperative',
    // Section D
    this.clinicalObservations = '',
    this.familyPresent = false,
    this.homeEnvironment = const [],
    this.patientFamilyConcerns = '',
    // Section E
    this.followUpRequired = false,
    this.followUpUrgency = 'routine',
    this.recommendedActions = const [],
    this.alertMessage = '',
  });

  VisitReportData copyWith({
    String? overallCondition,
    String? consciousnessLevel,
    int? painLevel,
    List<String>? mobility,
    String? woundSiteCondition,
    int? bpSystolic,
    int? bpDiastolic,
    int? heartRate,
    double? temperature,
    int? oxygenSaturation,
    int? respiratoryRate,
    int? bloodSugar,
    double? weight,
    List<String>? servicesPerformed,
    List<MedicationEntry>? medications,
    List<String>? procedures,
    String? patientCooperation,
    String? clinicalObservations,
    bool? familyPresent,
    List<String>? homeEnvironment,
    String? patientFamilyConcerns,
    bool? followUpRequired,
    String? followUpUrgency,
    List<String>? recommendedActions,
    String? alertMessage,
  }) {
    return VisitReportData(
      overallCondition: overallCondition ?? this.overallCondition,
      consciousnessLevel: consciousnessLevel ?? this.consciousnessLevel,
      painLevel: painLevel ?? this.painLevel,
      mobility: mobility ?? this.mobility,
      woundSiteCondition: woundSiteCondition ?? this.woundSiteCondition,
      bpSystolic: bpSystolic ?? this.bpSystolic,
      bpDiastolic: bpDiastolic ?? this.bpDiastolic,
      heartRate: heartRate ?? this.heartRate,
      temperature: temperature ?? this.temperature,
      oxygenSaturation: oxygenSaturation ?? this.oxygenSaturation,
      respiratoryRate: respiratoryRate ?? this.respiratoryRate,
      bloodSugar: bloodSugar ?? this.bloodSugar,
      weight: weight ?? this.weight,
      servicesPerformed: servicesPerformed ?? this.servicesPerformed,
      medications: medications ?? this.medications,
      procedures: procedures ?? this.procedures,
      patientCooperation: patientCooperation ?? this.patientCooperation,
      clinicalObservations: clinicalObservations ?? this.clinicalObservations,
      familyPresent: familyPresent ?? this.familyPresent,
      homeEnvironment: homeEnvironment ?? this.homeEnvironment,
      patientFamilyConcerns:
          patientFamilyConcerns ?? this.patientFamilyConcerns,
      followUpRequired: followUpRequired ?? this.followUpRequired,
      followUpUrgency: followUpUrgency ?? this.followUpUrgency,
      recommendedActions: recommendedActions ?? this.recommendedActions,
      alertMessage: alertMessage ?? this.alertMessage,
    );
  }

  /// Serialize to the JSON body expected by POST /bookings/:id/complete-with-report
  Map<String, dynamic> toJson() {
    return {
      'patientStatus': {
        'overallCondition': overallCondition,
        'consciousnessLevel': consciousnessLevel,
        'painLevel': painLevel,
        'mobility': mobility,
        'woundSiteCondition': woundSiteCondition,
      },
      'vitals': {
        if (bpSystolic != null || bpDiastolic != null)
          'bloodPressure': {
            'systolic': bpSystolic,
            'diastolic': bpDiastolic,
          },
        if (heartRate != null) 'heartRate': {'value': heartRate},
        if (temperature != null) 'temperature': {'value': temperature},
        if (oxygenSaturation != null)
          'oxygenSaturation': {'value': oxygenSaturation},
        if (respiratoryRate != null) 'respiratoryRate': respiratoryRate,
        if (bloodSugar != null) 'bloodSugar': bloodSugar,
        if (weight != null) 'weight': weight,
      },
      'careProvided': {
        'servicesPerformed': servicesPerformed,
        'medications': medications.map((m) => m.toJson()).toList(),
        'procedures': procedures,
        'patientCooperation': patientCooperation,
      },
      'notes': {
        'clinicalObservations': clinicalObservations,
        'familyPresent': familyPresent,
        'homeEnvironment': homeEnvironment,
        'patientFamilyConcerns': patientFamilyConcerns,
      },
      'followUp': {
        'required': followUpRequired,
        'urgency': followUpUrgency,
        'recommendedActions': recommendedActions,
        'alertMessage': alertMessage,
      },
    };
  }

  /// Build a prefill from the last visit report JSON returned by the API
  factory VisitReportData.fromLastVisit(Map<String, dynamic> json) {
    final ps = (json['patientStatus'] as Map<String, dynamic>?) ?? {};
    final v = (json['vitals'] as Map<String, dynamic>?) ?? {};
    final cp = (json['careProvided'] as Map<String, dynamic>?) ?? {};

    return VisitReportData(
      overallCondition: ps['overallCondition'] ?? 'stable',
      consciousnessLevel: ps['consciousnessLevel'] ?? 'alert',
      painLevel: (ps['painLevel'] as num?)?.toInt() ?? 0,
      mobility: List<String>.from(ps['mobility'] ?? []),
      woundSiteCondition: ps['woundSiteCondition'] ?? 'na',
      bpSystolic:
          (v['bloodPressure']?['systolic'] as num?)?.toInt(),
      bpDiastolic:
          (v['bloodPressure']?['diastolic'] as num?)?.toInt(),
      heartRate: (v['heartRate']?['value'] as num?)?.toInt(),
      temperature: (v['temperature']?['value'] as num?)?.toDouble(),
      oxygenSaturation:
          (v['oxygenSaturation']?['value'] as num?)?.toInt(),
      servicesPerformed: List<String>.from(cp['servicesPerformed'] ?? []),
      patientCooperation: cp['patientCooperation'] ?? 'cooperative',
    );
  }

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
      medications: (cp['medications'] as List? ?? []).map((m) => MedicationEntry.fromJson(Map<String, dynamic>.from(m))).toList(),
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

  // ── Vital status helpers (for inline feedback) ───────────────────────────

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

  bool get hasAbnormalVitals =>
      bpStatus != VitalStatus.normal && bpStatus != VitalStatus.unknown ||
      heartRateStatus != VitalStatus.normal &&
          heartRateStatus != VitalStatus.unknown ||
      temperatureStatus != VitalStatus.normal &&
          temperatureStatus != VitalStatus.unknown ||
      spo2Status != VitalStatus.normal && spo2Status != VitalStatus.unknown;

  bool get isReadyToSubmit =>
      bpSystolic != null &&
      bpDiastolic != null &&
      heartRate != null &&
      temperature != null &&
      oxygenSaturation != null &&
      servicesPerformed.isNotEmpty;
}

// ─── Medication entry ────────────────────────────────────────────────────────

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

  Map<String, dynamic> toJson() => {
        'name': name,
        'dose': dose,
        'route': route,
      };
}

// ─── Vital status enum ───────────────────────────────────────────────────────

enum VitalStatus { normal, high, low, critical, unknown }
