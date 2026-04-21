import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/visit_report_data.dart';

// ─────────────────────────────────────────────────────────────────────────────
// VisitReportForm
//
// A full-featured, card-based visit report form for the nurse to fill after
// a home visit.  Divided into 5 collapsible sections:
//   A – Patient Status
//   B – Vitals         (required before submission)
//   C – Care Provided  (required before submission)
//   D – Notes & Observations
//   E – Follow-up / Alerts
//
// Usage:
//   VisitReportForm(
//     initialService: booking.serviceName,
//     prefill: prefillData,          // from last visit (optional)
//     onChanged: (data) { ... },
//     onSubmit: (data) { ... },
//   )
// ─────────────────────────────────────────────────────────────────────────────

class VisitReportForm extends StatefulWidget {
  final String initialService;
  final VisitReportData? prefill;
  final ValueChanged<VisitReportData> onChanged;
  final ValueChanged<VisitReportData>? onSubmit;
  final bool isSubmitting;

  const VisitReportForm({
    super.key,
    required this.initialService,
    this.prefill,
    required this.onChanged,
    this.onSubmit,
    this.isSubmitting = false,
  });

  @override
  State<VisitReportForm> createState() => _VisitReportFormState();
}

class _VisitReportFormState extends State<VisitReportForm> {
  late VisitReportData _data;

  // Vitals controllers
  final _bpSysCtrl = TextEditingController();
  final _bpDiaCtrl = TextEditingController();
  final _hrCtrl = TextEditingController();
  final _tempCtrl = TextEditingController();
  final _spo2Ctrl = TextEditingController();
  final _rrCtrl = TextEditingController();
  final _bgCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  // Note controllers
  final _obsCtrl = TextEditingController();
  final _concernsCtrl = TextEditingController();
  final _alertCtrl = TextEditingController();

  // Section expand state
  bool _secAExpanded = true;
  bool _secBExpanded = true;
  bool _secCExpanded = true;
  bool _secDExpanded = false;
  bool _secEExpanded = false;

  // Medications list
  final List<_MedRow> _medRows = [];

  @override
  void initState() {
    super.initState();
    _data = widget.prefill ?? VisitReportData(
      servicesPerformed: [widget.initialService],
    );

    // Prefill text fields
    _bpSysCtrl.text = _data.bpSystolic?.toString() ?? '';
    _bpDiaCtrl.text = _data.bpDiastolic?.toString() ?? '';
    _hrCtrl.text = _data.heartRate?.toString() ?? '';
    _tempCtrl.text = _data.temperature?.toString() ?? '';
    _spo2Ctrl.text = _data.oxygenSaturation?.toString() ?? '';
    _obsCtrl.text = _data.clinicalObservations;
    _concernsCtrl.text = _data.patientFamilyConcerns;
    _alertCtrl.text = _data.alertMessage;
  }

  @override
  void dispose() {
    for (final c in [
      _bpSysCtrl, _bpDiaCtrl, _hrCtrl, _tempCtrl, _spo2Ctrl,
      _rrCtrl, _bgCtrl, _weightCtrl, _obsCtrl, _concernsCtrl, _alertCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _notify() {
    widget.onChanged(_data);
  }

  void _updateVitals() {
    _data = _data.copyWith(
      bpSystolic: int.tryParse(_bpSysCtrl.text),
      bpDiastolic: int.tryParse(_bpDiaCtrl.text),
      heartRate: int.tryParse(_hrCtrl.text),
      temperature: double.tryParse(_tempCtrl.text),
      oxygenSaturation: int.tryParse(_spo2Ctrl.text),
      respiratoryRate: int.tryParse(_rrCtrl.text),
      bloodSugar: int.tryParse(_bgCtrl.text),
      weight: double.tryParse(_weightCtrl.text),
    );
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionA(),
        const SizedBox(height: 16),
        _sectionB(),
        const SizedBox(height: 16),
        _sectionC(),
        const SizedBox(height: 16),
        _sectionD(),
        const SizedBox(height: 16),
        _sectionE(),
        const SizedBox(height: 16),
        if (!_data.isReadyToSubmit) _validationBanner(),
      ],
    );
  }

  // ─── Section A: Patient Status ────────────────────────────────────────────

  Widget _sectionA() {
    return _ReportSection(
      icon: Icons.person_rounded,
      iconColor: AppColors.primary500,
      iconBg: AppColors.primary50,
      title: 'Patient Status',
      subtitle: 'Assess overall condition',
      isExpanded: _secAExpanded,
      onToggle: () => setState(() => _secAExpanded = !_secAExpanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall Condition
          _FieldLabel('Overall Condition *'),
          const SizedBox(height: 8),
          _SingleSelectChips(
            options: const [
              ('Excellent', 'excellent'),
              ('Stable', 'stable'),
              ('Fair', 'fair'),
              ('Poor', 'poor'),
              ('Critical', 'critical'),
            ],
            selected: _data.overallCondition,
            onSelected: (v) {
              setState(() => _data = _data.copyWith(overallCondition: v));
              _notify();
            },
            getColor: _conditionColor,
          ),
          const SizedBox(height: 16),

          // Consciousness
          _FieldLabel('Consciousness Level *'),
          const SizedBox(height: 8),
          _SingleSelectChips(
            options: const [
              ('Alert', 'alert'),
              ('Confused', 'confused'),
              ('Lethargic', 'lethargic'),
              ('Unresponsive', 'unresponsive'),
            ],
            selected: _data.consciousnessLevel,
            onSelected: (v) {
              setState(() => _data = _data.copyWith(consciousnessLevel: v));
              _notify();
            },
            getColor: _consciousnessColor,
          ),
          const SizedBox(height: 16),

          // Pain Slider
          _FieldLabel('Pain Level: ${_data.painLevel}/10 — ${_painLabel(_data.painLevel)}'),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('😊', style: TextStyle(fontSize: 20)),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: _painColor(_data.painLevel),
                    thumbColor: _painColor(_data.painLevel),
                    inactiveTrackColor: AppColors.light400,
                    overlayColor:
                        _painColor(_data.painLevel).withOpacity(0.15),
                    trackHeight: 6,
                  ),
                  child: Slider(
                    value: _data.painLevel.toDouble(),
                    min: 0,
                    max: 10,
                    divisions: 10,
                    onChanged: (v) {
                      setState(
                          () => _data = _data.copyWith(painLevel: v.toInt()));
                      _notify();
                    },
                  ),
                ),
              ),
              const Text('😣', style: TextStyle(fontSize: 20)),
            ],
          ),
          const SizedBox(height: 16),

          // Mobility
          _FieldLabel('Mobility'),
          const SizedBox(height: 8),
          _MultiSelectChips(
            options: const [
              ('Independent', 'independent'),
              ('Needs Help', 'needs_help'),
              ('Bedridden', 'bedridden'),
            ],
            selected: _data.mobility,
            onChanged: (v) {
              setState(() => _data = _data.copyWith(mobility: v));
              _notify();
            },
          ),
          const SizedBox(height: 16),

          // Wound Site
          _FieldLabel('Wound / IV Site Condition'),
          const SizedBox(height: 8),
          _SingleSelectChips(
            options: const [
              ('N/A', 'na'),
              ('Clean', 'clean'),
              ('Redness', 'redness'),
              ('Swelling', 'swelling'),
              ('Discharge', 'discharge'),
            ],
            selected: _data.woundSiteCondition,
            onSelected: (v) {
              setState(() => _data = _data.copyWith(woundSiteCondition: v));
              _notify();
            },
            getColor: _woundColor,
          ),
        ],
      ),
    );
  }

  // ─── Section B: Vitals ────────────────────────────────────────────────────

  Widget _sectionB() {
    return _ReportSection(
      icon: Icons.monitor_heart_rounded,
      iconColor: AppColors.error500,
      iconBg: AppColors.error50,
      title: 'Vital Signs',
      subtitle: 'Required before completing',
      isExpanded: _secBExpanded,
      onToggle: () => setState(() => _secBExpanded = !_secBExpanded),
      child: Column(
        children: [
          // Blood Pressure
          _VitalRow(
            label: 'Blood Pressure',
            unit: 'mmHg',
            status: _data.bpStatus,
            child: Row(
              children: [
                Expanded(
                  child: _VitalTextField(
                    controller: _bpSysCtrl,
                    hint: '120',
                    label: 'SYS',
                    maxLength: 3,
                    onChanged: (_) {
                      setState(_updateVitals);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '/',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
                Expanded(
                  child: _VitalTextField(
                    controller: _bpDiaCtrl,
                    hint: '80',
                    label: 'DIA',
                    maxLength: 3,
                    onChanged: (_) {
                      setState(_updateVitals);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Heart Rate
          _VitalRow(
            label: 'Heart Rate',
            unit: 'bpm',
            status: _data.heartRateStatus,
            child: _VitalTextField(
              controller: _hrCtrl,
              hint: '78',
              label: 'HR',
              maxLength: 3,
              onChanged: (_) => setState(_updateVitals),
            ),
          ),
          const SizedBox(height: 12),

          // Temperature
          _VitalRow(
            label: 'Temperature',
            unit: '°C',
            status: _data.temperatureStatus,
            child: _VitalTextField(
              controller: _tempCtrl,
              hint: '37.0',
              label: 'Temp',
              maxLength: 4,
              allowDecimal: true,
              onChanged: (_) => setState(_updateVitals),
            ),
          ),
          const SizedBox(height: 12),

          // SpO2
          _VitalRow(
            label: 'Oxygen Saturation (SpO₂)',
            unit: '%',
            status: _data.spo2Status,
            child: _VitalTextField(
              controller: _spo2Ctrl,
              hint: '98',
              label: 'SpO₂',
              maxLength: 3,
              onChanged: (_) => setState(_updateVitals),
            ),
          ),

          // Optional vitals (collapsed by default)
          const SizedBox(height: 12),
          _OptionalVitalsSection(
            rrCtrl: _rrCtrl,
            bgCtrl: _bgCtrl,
            weightCtrl: _weightCtrl,
            onChanged: () => setState(_updateVitals),
          ),

          // Abnormal alert
          if (_data.hasAbnormalVitals) ...[
            const SizedBox(height: 12),
            _AbnormalVitalsBanner(data: _data),
          ],
        ],
      ),
    );
  }

  // ─── Section C: Care Provided ─────────────────────────────────────────────

  Widget _sectionC() {
    return _ReportSection(
      icon: Icons.medical_services_rounded,
      iconColor: AppColors.secondary500,
      iconBg: AppColors.secondary50,
      title: 'Care Provided',
      subtitle: 'What was done during the visit',
      isExpanded: _secCExpanded,
      onToggle: () => setState(() => _secCExpanded = !_secCExpanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel('Services Performed *'),
          const SizedBox(height: 8),
          _ServicesChecklist(
            initialService: widget.initialService,
            selected: _data.servicesPerformed,
            onChanged: (v) {
              setState(() => _data = _data.copyWith(servicesPerformed: v));
              _notify();
            },
          ),
          const SizedBox(height: 16),

          // Medications
          _FieldLabel('Medications Given'),
          const SizedBox(height: 8),
          ..._medRows.asMap().entries.map((e) => _MedRowWidget(
                row: e.value,
                onChanged: () => _notify(),
                onRemove: () {
                  setState(() => _medRows.removeAt(e.key));
                  _updateMeds();
                },
              )),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {
              setState(() => _medRows.add(_MedRow()));
            },
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Medication'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary500,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: AppColors.primary500.withOpacity(0.4)),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Procedures
          _FieldLabel('Procedures Performed'),
          const SizedBox(height: 8),
          _MultiSelectChips(
            options: const [
              ('Wound Dressing', 'Wound Dressing'),
              ('IV Cannula', 'IV Cannula Insertion'),
              ('IV Flush', 'IV Flush'),
              ('Catheter Care', 'Catheter Care'),
              ('Injection', 'Injection'),
              ('Blood Draw', 'Blood Draw'),
              ('Nebulization', 'Nebulization'),
              ('Suctioning', 'Suctioning'),
              ('Feeding Tube', 'Feeding Tube Care'),
              ('Fall Assessment', 'Fall Risk Assessment'),
            ],
            selected: _data.procedures,
            onChanged: (v) {
              setState(() => _data = _data.copyWith(procedures: v));
              _notify();
            },
          ),
          const SizedBox(height: 16),

          // Cooperation
          _FieldLabel('Patient Cooperation'),
          const SizedBox(height: 8),
          _SingleSelectChips(
            options: const [
              ('Cooperative', 'cooperative'),
              ('Resistant', 'resistant'),
              ('Unable', 'unable'),
            ],
            selected: _data.patientCooperation,
            onSelected: (v) {
              setState(
                  () => _data = _data.copyWith(patientCooperation: v));
              _notify();
            },
            getColor: (v) => v == 'cooperative'
                ? AppColors.success500
                : v == 'resistant'
                    ? AppColors.warning500
                    : AppColors.error500,
          ),
        ],
      ),
    );
  }

  void _updateMeds() {
    _data = _data.copyWith(
      medications: _medRows
          .map((r) => MedicationEntry(
                name: r.nameCtrl.text,
                dose: r.doseCtrl.text,
                route: r.route,
              ))
          .toList(),
    );
    _notify();
  }

  // ─── Section D: Notes ────────────────────────────────────────────────────

  Widget _sectionD() {
    return _ReportSection(
      icon: Icons.description_rounded,
      iconColor: AppColors.warning600,
      iconBg: AppColors.warning50,
      title: 'Notes & Observations',
      subtitle: 'Optional — clinical details',
      isExpanded: _secDExpanded,
      onToggle: () => setState(() => _secDExpanded = !_secDExpanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel('Clinical Observations'),
          const SizedBox(height: 8),
          _NotesField(
            controller: _obsCtrl,
            hint:
                'e.g. Wound healing well, mild ankle edema noted bilaterally...',
            maxLength: 500,
            onChanged: (v) {
              _data = _data.copyWith(clinicalObservations: v);
              _notify();
            },
          ),
          const SizedBox(height: 16),

          // Family present
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel('Family / Caregiver Present'),
                    Text(
                      'Was someone with the patient?',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _data.familyPresent,
                onChanged: (v) {
                  setState(() => _data = _data.copyWith(familyPresent: v));
                  _notify();
                },
                activeColor: AppColors.success500,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Home environment
          _FieldLabel('Home Environment'),
          const SizedBox(height: 8),
          _MultiSelectChips(
            options: const [
              ('Clean', 'clean'),
              ('Cluttered', 'cluttered'),
              ('Safe', 'safe'),
              ('Unsafe', 'unsafe'),
            ],
            selected: _data.homeEnvironment,
            onChanged: (v) {
              setState(() => _data = _data.copyWith(homeEnvironment: v));
              _notify();
            },
          ),
          const SizedBox(height: 16),

          // Concerns
          _FieldLabel('Patient / Family Concerns'),
          const SizedBox(height: 8),
          _NotesField(
            controller: _concernsCtrl,
            hint: 'e.g. Family concerned about reduced appetite...',
            maxLength: 250,
            maxLines: 3,
            onChanged: (v) {
              _data = _data.copyWith(patientFamilyConcerns: v);
              _notify();
            },
          ),
        ],
      ),
    );
  }

  // ─── Section E: Follow-up ─────────────────────────────────────────────────

  Widget _sectionE() {
    return _ReportSection(
      icon: Icons.notifications_active_rounded,
      iconColor: AppColors.error500,
      iconBg: AppColors.error50,
      title: 'Follow-up & Alerts',
      subtitle: 'Next steps for this patient',
      isExpanded: _secEExpanded,
      onToggle: () => setState(() => _secEExpanded = !_secEExpanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Follow-up toggle
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel('Follow-up Required?'),
                    Text(
                      'Should this patient be seen again soon?',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _data.followUpRequired,
                onChanged: (v) {
                  setState(() => _data = _data.copyWith(followUpRequired: v));
                  _notify();
                },
                activeColor: AppColors.primary500,
              ),
            ],
          ),

          if (_data.followUpRequired) ...[
            const SizedBox(height: 16),

            // Urgency
            _FieldLabel('Urgency Level'),
            const SizedBox(height: 8),
            _SingleSelectChips(
              options: const [
                ('Routine', 'routine'),
                ('Within 48h', 'within_48h'),
                ('Urgent', 'urgent'),
                ('Emergency', 'emergency'),
              ],
              selected: _data.followUpUrgency,
              onSelected: (v) {
                setState(() => _data = _data.copyWith(followUpUrgency: v));
                _notify();
              },
              getColor: (v) {
                switch (v) {
                  case 'emergency':
                    return AppColors.error500;
                  case 'urgent':
                    return AppColors.warning500;
                  case 'within_48h':
                    return AppColors.secondary500;
                  default:
                    return AppColors.success500;
                }
              },
            ),
            const SizedBox(height: 16),

            // Recommended actions
            _FieldLabel('Recommended Actions'),
            const SizedBox(height: 8),
            _MultiSelectChips(
              options: const [
                ('Doctor Consult', 'doctor_consult'),
                ('Lab Tests', 'lab_tests'),
                ('Medication Review', 'medication_review'),
                ('Physiotherapy', 'physio'),
                ('Hospital Admission', 'hospital_admission'),
                ('Family Education', 'family_education'),
              ],
              selected: _data.recommendedActions,
              onChanged: (v) {
                setState(
                    () => _data = _data.copyWith(recommendedActions: v));
                _notify();
              },
            ),
            const SizedBox(height: 16),

            // Alert message
            _FieldLabel('Alert for Care Team'),
            const SizedBox(height: 8),
            _NotesField(
              controller: _alertCtrl,
              hint: 'e.g. BP has been trending high over last 3 visits...',
              maxLength: 200,
              maxLines: 3,
              onChanged: (v) {
                _data = _data.copyWith(alertMessage: v);
                _notify();
              },
            ),
          ],
        ],
      ),
    );
  }

  // ─── Validation ────────────────────────────────────────────────────────────

  Widget _validationBanner() {
    final missing = <String>[];
    if (_data.bpSystolic == null || _data.bpDiastolic == null) {
      missing.add('Blood Pressure');
    }
    if (_data.heartRate == null) missing.add('Heart Rate');
    if (_data.temperature == null) missing.add('Temperature');
    if (_data.oxygenSaturation == null) missing.add('SpO₂');
    if (_data.servicesPerformed.isEmpty) missing.add('Services Performed');

    if (missing.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_rounded,
              color: AppColors.warning600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Complete required fields to submit:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warning700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  missing.join(', '),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.warning700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  Color _conditionColor(String v) {
    switch (v) {
      case 'excellent':
        return AppColors.success500;
      case 'stable':
        return AppColors.success400;
      case 'fair':
        return AppColors.warning500;
      case 'poor':
        return AppColors.error400;
      case 'critical':
        return AppColors.error500;
      default:
        return AppColors.primary500;
    }
  }

  Color _consciousnessColor(String v) {
    switch (v) {
      case 'alert':
        return AppColors.success500;
      case 'confused':
        return AppColors.warning500;
      case 'lethargic':
        return AppColors.error400;
      case 'unresponsive':
        return AppColors.error600;
      default:
        return AppColors.primary500;
    }
  }

  Color _woundColor(String v) {
    switch (v) {
      case 'clean':
        return AppColors.success500;
      case 'redness':
        return AppColors.warning500;
      case 'swelling':
        return AppColors.warning600;
      case 'discharge':
        return AppColors.error500;
      default:
        return AppColors.light700;
    }
  }

  String _painLabel(int v) {
    if (v == 0) return 'No pain';
    if (v <= 2) return 'Minimal';
    if (v <= 4) return 'Mild';
    if (v <= 6) return 'Moderate';
    if (v <= 8) return 'Severe';
    return 'Worst possible';
  }

  Color _painColor(int v) {
    if (v <= 2) return AppColors.success500;
    if (v <= 5) return AppColors.warning500;
    if (v <= 7) return AppColors.warning600;
    return AppColors.error500;
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Sub-widgets
// ═════════════════════════════════════════════════════════════════════════════

// ─── Section card ────────────────────────────────────────────────────────────

class _ReportSection extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Widget child;

  const _ReportSection({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.isExpanded,
    required this.onToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          AnimatedCrossFade(
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: AppColors.light400, height: 1),
                  const SizedBox(height: 16),
                  child,
                ],
              ),
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState: isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

// ─── Field label ─────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.grey[700],
      ),
    );
  }
}

// ─── Single-select chips ──────────────────────────────────────────────────────

class _SingleSelectChips extends StatelessWidget {
  final List<(String label, String value)> options;
  final String selected;
  final ValueChanged<String> onSelected;
  final Color Function(String value) getColor;

  const _SingleSelectChips({
    required this.options,
    required this.selected,
    required this.onSelected,
    required this.getColor,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((o) {
        final isSelected = o.$2 == selected;
        final color = getColor(o.$2);
        return GestureDetector(
          onTap: () => onSelected(o.$2),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? color : AppColors.light500,
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : null,
            ),
            child: Text(
              o.$1,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Multi-select chips ───────────────────────────────────────────────────────

class _MultiSelectChips extends StatelessWidget {
  final List<(String label, String value)> options;
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  const _MultiSelectChips({
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((o) {
        final isSelected = selected.contains(o.$2);
        return GestureDetector(
          onTap: () {
            final newList = List<String>.from(selected);
            if (isSelected) {
              newList.remove(o.$2);
            } else {
              newList.add(o.$2);
            }
            onChanged(newList);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary500 : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primary500 : AppColors.light500,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white),
                  const SizedBox(width: 4),
                ],
                Text(
                  o.$1,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Vital row with status badge ──────────────────────────────────────────────

class _VitalRow extends StatelessWidget {
  final String label;
  final String unit;
  final VitalStatus status;
  final Widget child;

  const _VitalRow({
    required this.label,
    required this.unit,
    required this.status,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.light100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _borderColor,
          width: status == VitalStatus.critical ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              if (status != VitalStatus.unknown)
                _StatusBadge(status: status, unit: unit),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Color get _borderColor {
    switch (status) {
      case VitalStatus.critical:
        return AppColors.error500;
      case VitalStatus.high:
      case VitalStatus.low:
        return AppColors.warning500;
      case VitalStatus.normal:
        return AppColors.success500;
      case VitalStatus.unknown:
        return AppColors.light500;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final VitalStatus status;
  final String unit;
  const _StatusBadge({required this.status, required this.unit});

  @override
  Widget build(BuildContext context) {
    final (label, color, bg) = switch (status) {
      VitalStatus.normal => ('✅ Normal', AppColors.success700, AppColors.success50),
      VitalStatus.high => ('⚠️ High', AppColors.warning700, AppColors.warning50),
      VitalStatus.low => ('⬇️ Low', AppColors.info700, AppColors.info50),
      VitalStatus.critical => ('🚨 Critical', AppColors.error700, AppColors.error50),
      VitalStatus.unknown => ('— Enter $unit', AppColors.light700, AppColors.light300),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ─── Vital text field ─────────────────────────────────────────────────────────

class _VitalTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String label;
  final int maxLength;
  final bool allowDecimal;
  final ValueChanged<String> onChanged;

  const _VitalTextField({
    required this.controller,
    required this.hint,
    required this.label,
    required this.maxLength,
    this.allowDecimal = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType:
          TextInputType.numberWithOptions(decimal: allowDecimal),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
            allowDecimal ? RegExp(r'[\d.]') : RegExp(r'\d')),
        LengthLimitingTextInputFormatter(maxLength),
      ],
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 11, color: Colors.grey[500]),
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w300,
          color: Colors.grey[300],
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      ),
      onChanged: onChanged,
    );
  }
}

// ─── Optional vitals section ──────────────────────────────────────────────────

class _OptionalVitalsSection extends StatefulWidget {
  final TextEditingController rrCtrl;
  final TextEditingController bgCtrl;
  final TextEditingController weightCtrl;
  final VoidCallback onChanged;

  const _OptionalVitalsSection({
    required this.rrCtrl,
    required this.bgCtrl,
    required this.weightCtrl,
    required this.onChanged,
  });

  @override
  State<_OptionalVitalsSection> createState() => _OptionalVitalsSectionState();
}

class _OptionalVitalsSectionState extends State<_OptionalVitalsSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Row(
            children: [
              Icon(
                _expanded ? Icons.remove_circle_outline : Icons.add_circle_outline,
                size: 18,
                color: AppColors.primary500,
              ),
              const SizedBox(width: 6),
              Text(
                _expanded ? 'Hide Optional Vitals' : '+ Respiratory Rate, Blood Sugar, Weight',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.primary500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _VitalTextField(
                  controller: widget.rrCtrl,
                  hint: '16',
                  label: 'RR /min',
                  maxLength: 2,
                  onChanged: (_) => widget.onChanged(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _VitalTextField(
                  controller: widget.bgCtrl,
                  hint: '105',
                  label: 'Blood Sugar mg/dL',
                  maxLength: 4,
                  onChanged: (_) => widget.onChanged(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _VitalTextField(
                  controller: widget.weightCtrl,
                  hint: '70',
                  label: 'Weight kg',
                  maxLength: 5,
                  allowDecimal: true,
                  onChanged: (_) => widget.onChanged(),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ─── Abnormal vitals banner ───────────────────────────────────────────────────

class _AbnormalVitalsBanner extends StatelessWidget {
  final VisitReportData data;
  const _AbnormalVitalsBanner({required this.data});

  @override
  Widget build(BuildContext context) {
    final abnormal = <String>[];
    if (data.bpStatus == VitalStatus.critical ||
        data.bpStatus == VitalStatus.high ||
        data.bpStatus == VitalStatus.low) {
      abnormal.add('Blood Pressure (${data.bpStatus.name})');
    }
    if (data.heartRateStatus == VitalStatus.critical ||
        data.heartRateStatus == VitalStatus.high ||
        data.heartRateStatus == VitalStatus.low) {
      abnormal.add('Heart Rate (${data.heartRateStatus.name})');
    }
    if (data.temperatureStatus != VitalStatus.normal &&
        data.temperatureStatus != VitalStatus.unknown) {
      abnormal.add('Temperature (${data.temperatureStatus.name})');
    }
    if (data.spo2Status != VitalStatus.normal &&
        data.spo2Status != VitalStatus.unknown) {
      abnormal.add('SpO₂ (${data.spo2Status.name})');
    }

    final isCritical = data.bpStatus == VitalStatus.critical ||
        data.heartRateStatus == VitalStatus.critical ||
        data.temperatureStatus == VitalStatus.critical ||
        data.spo2Status == VitalStatus.critical;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCritical ? AppColors.error50 : AppColors.warning50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCritical ? AppColors.error300 : AppColors.warning300,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCritical ? Icons.emergency_rounded : Icons.warning_amber_rounded,
            color: isCritical ? AppColors.error500 : AppColors.warning600,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCritical
                      ? '🚨 Critical vitals detected — alert will be sent'
                      : '⚠️ Abnormal vitals — consider follow-up',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isCritical
                        ? AppColors.error700
                        : AppColors.warning700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  abnormal.join(', '),
                  style: TextStyle(
                    fontSize: 12,
                    color: isCritical
                        ? AppColors.error600
                        : AppColors.warning700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Services checklist ───────────────────────────────────────────────────────

class _ServicesChecklist extends StatefulWidget {
  final String initialService;
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  const _ServicesChecklist({
    required this.initialService,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<_ServicesChecklist> createState() => _ServicesChecklistState();
}

class _ServicesChecklistState extends State<_ServicesChecklist> {
  late List<String> _allServices;

  @override
  void initState() {
    super.initState();
    _allServices = _defaultServices(widget.initialService);
  }

  List<String> _defaultServices(String primaryService) {
    final base = <String>[primaryService];
    final extras = [
      'Vital Signs Measurement',
      'Wound Care',
      'Medication Administration',
      'IV Care',
      'Patient Education',
      'Pain Assessment',
      'Mobility Assistance',
    ];
    for (final s in extras) {
      if (!base.contains(s)) base.add(s);
    }
    return base;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ..._allServices.map((service) {
          final isSelected = widget.selected.contains(service);
          return GestureDetector(
            onTap: () {
              final newList = List<String>.from(widget.selected);
              if (isSelected) {
                newList.remove(service);
              } else {
                newList.add(service);
              }
              widget.onChanged(newList);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.success50
                    : AppColors.light100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? AppColors.success500
                      : AppColors.light500,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: isSelected
                        ? AppColors.success500
                        : Colors.grey[400],
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      service,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected
                            ? AppColors.success700
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ─── Notes text field ─────────────────────────────────────────────────────────

class _NotesField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLength;
  final int maxLines;
  final ValueChanged<String> onChanged;

  const _NotesField({
    required this.controller,
    required this.hint,
    required this.maxLength,
    this.maxLines = 4,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      minLines: 2,
      maxLength: maxLength,
      textCapitalization: TextCapitalization.sentences,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textPrimary,
        height: 1.5,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
        filled: true,
        fillColor: AppColors.light100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.light400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primary500, width: 2),
        ),
        contentPadding: const EdgeInsets.all(14),
        counterStyle: TextStyle(fontSize: 11, color: Colors.grey[400]),
      ),
      onChanged: onChanged,
    );
  }
}

// ─── Medication row state ─────────────────────────────────────────────────────

class _MedRow {
  final nameCtrl = TextEditingController();
  final doseCtrl = TextEditingController();
  String route = 'oral';
}

class _MedRowWidget extends StatefulWidget {
  final _MedRow row;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  const _MedRowWidget({
    required this.row,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  State<_MedRowWidget> createState() => _MedRowWidgetState();
}

class _MedRowWidgetState extends State<_MedRowWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.light100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.light400),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _miniField(
                  widget.row.nameCtrl,
                  'Medication name',
                  widget.onChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _miniField(
                  widget.row.doseCtrl,
                  'Dose',
                  widget.onChanged,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: widget.onRemove,
                icon: const Icon(Icons.close_rounded, size: 18),
                color: Colors.grey[400],
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: widget.row.route,
            decoration: InputDecoration(
              labelText: 'Route',
              labelStyle:
                  TextStyle(fontSize: 12, color: Colors.grey[500]),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              isDense: true,
            ),
            items: const [
              DropdownMenuItem(value: 'oral', child: Text('Oral')),
              DropdownMenuItem(value: 'iv', child: Text('IV')),
              DropdownMenuItem(value: 'im', child: Text('IM')),
              DropdownMenuItem(value: 'sc', child: Text('SC')),
              DropdownMenuItem(value: 'topical', child: Text('Topical')),
              DropdownMenuItem(value: 'other', child: Text('Other')),
            ],
            onChanged: (v) {
              setState(() => widget.row.route = v!);
              widget.onChanged();
            },
          ),
        ],
      ),
    );
  }

  Widget _miniField(
      TextEditingController ctrl, String hint, VoidCallback onChange) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 12, color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        isDense: true,
      ),
      onChanged: (_) => onChange(),
    );
  }
}
