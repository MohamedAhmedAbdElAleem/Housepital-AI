import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/visit_report_data.dart';
import '../../../../l10n/app_localizations.dart';

// ─────────────────────────────────────────────────────────────────────────────
// VisitReportForm
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
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionA(l10n),
        const SizedBox(height: 16),
        _sectionB(l10n),
        const SizedBox(height: 16),
        _sectionC(l10n),
        const SizedBox(height: 16),
        _sectionD(l10n),
        const SizedBox(height: 16),
        _sectionE(l10n),
        const SizedBox(height: 16),
        if (!_data.isReadyToSubmit) _validationBanner(l10n),
      ],
    );
  }

  // ─── Section A: Patient Status ────────────────────────────────────────────

  Widget _sectionA(AppLocalizations l10n) {
    return _ReportSection(
      icon: Icons.person_rounded,
      iconColor: AppColors.primary500,
      iconBg: AppColors.primary50,
      title: l10n.patientStatus,
      subtitle: l10n.assessCondition,
      isExpanded: _secAExpanded,
      onToggle: () => setState(() => _secAExpanded = !_secAExpanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel(l10n.overallCondition),
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

          _FieldLabel(l10n.consciousnessLevel),
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

          _FieldLabel('${l10n.painLevel}: ${_data.painLevel}/10 — ${_painLabel(_data.painLevel)}'),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('😊', style: TextStyle(fontSize: 20)),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: _painColor(_data.painLevel),
                    thumbColor: _painColor(_data.painLevel),
                    inactiveTrackColor: Theme.of(context).brightness == Brightness.dark ? AppColors.dark400 : AppColors.light400,
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

          _FieldLabel(l10n.mobility),
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

          _FieldLabel(l10n.woundCondition),
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

  Widget _sectionB(AppLocalizations l10n) {
    return _ReportSection(
      icon: Icons.monitor_heart_rounded,
      iconColor: AppColors.error500,
      iconBg: AppColors.error50,
      title: l10n.vitalSigns,
      subtitle: l10n.requiredBeforeComplete,
      isExpanded: _secBExpanded,
      onToggle: () => setState(() => _secBExpanded = !_secBExpanded),
      child: Column(
        children: [
          _VitalRow(
            label: l10n.bloodPressure,
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

          _VitalRow(
            label: l10n.heartRate,
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

          _VitalRow(
            label: l10n.temperature,
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

          _VitalRow(
            label: l10n.oxygenSaturation,
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

          const SizedBox(height: 12),
          _OptionalVitalsSection(
            rrCtrl: _rrCtrl,
            bgCtrl: _bgCtrl,
            weightCtrl: _weightCtrl,
            onChanged: () => setState(_updateVitals),
          ),

          if (_data.hasAbnormalVitals) ...[
            const SizedBox(height: 12),
            _AbnormalVitalsBanner(data: _data),
          ],
        ],
      ),
    );
  }

  // ─── Section C: Care Provided ─────────────────────────────────────────────

  Widget _sectionC(AppLocalizations l10n) {
    return _ReportSection(
      icon: Icons.medical_services_rounded,
      iconColor: AppColors.secondary500,
      iconBg: AppColors.secondary50,
      title: l10n.careProvided,
      subtitle: l10n.whatWasDone,
      isExpanded: _secCExpanded,
      onToggle: () => setState(() => _secCExpanded = !_secCExpanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel(l10n.servicesPerformed),
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

          _FieldLabel(l10n.medicationsGiven),
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
            label: Text(l10n.addMedication),
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

          _FieldLabel(l10n.proceduresPerformed),
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

          _FieldLabel(l10n.patientCooperation),
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
                ? AppColors.primary600
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

  Widget _sectionD(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return _ReportSection(
      icon: Icons.description_rounded,
      iconColor: AppColors.warning600,
      iconBg: AppColors.warning50,
      title: l10n.notesObservations,
      subtitle: l10n.assessCondition,
      isExpanded: _secDExpanded,
      onToggle: () => setState(() => _secDExpanded = !_secDExpanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel(l10n.clinicalObservations),
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

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(l10n.familyPresent),
                    Text(
                      'Was someone with the patient?',
                      style: TextStyle(
                          fontSize: 12, color: theme.colorScheme.onSurface.withAlpha(150)),
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
                activeColor: AppColors.primary500,
              ),
            ],
          ),
          const SizedBox(height: 16),

          _FieldLabel(l10n.homeEnvironment),
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

          _FieldLabel(l10n.familyConcerns),
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

  Widget _sectionE(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return _ReportSection(
      icon: Icons.notifications_active_rounded,
      iconColor: AppColors.error500,
      iconBg: AppColors.error50,
      title: l10n.followUpAlerts,
      subtitle: l10n.nextSteps,
      isExpanded: _secEExpanded,
      onToggle: () => setState(() => _secEExpanded = !_secEExpanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(l10n.followUpRequired),
                    Text(
                      'Should this patient be seen again soon?',
                      style: TextStyle(
                          fontSize: 12, color: theme.colorScheme.onSurface.withAlpha(150)),
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

            _FieldLabel(l10n.urgencyLevel),
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
                    return AppColors.primary500;
                }
              },
            ),
            const SizedBox(height: 16),

            _FieldLabel(l10n.recommendedActions),
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

            _FieldLabel(l10n.alertCareTeam),
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

  Widget _validationBanner(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final missing = <String>[];
    if (_data.bpSystolic == null || _data.bpDiastolic == null) {
      missing.add(l10n.bloodPressure);
    }
    if (_data.heartRate == null) missing.add(l10n.heartRate);
    if (_data.temperature == null) missing.add(l10n.temperature);
    if (_data.oxygenSaturation == null) missing.add(l10n.oxygenSaturation);
    if (_data.servicesPerformed.isEmpty) missing.add(l10n.servicesPerformed);

    if (missing.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning50.withAlpha(isDark ? 40 : 255),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning300.withAlpha(100)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_rounded,
              color: isDark ? AppColors.warning300 : AppColors.warning600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Complete required fields to submit:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.warning200 : AppColors.warning700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  missing.join(', '),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.warning200.withAlpha(200) : AppColors.warning700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _conditionColor(String v) {
    switch (v) {
      case 'excellent':
        return AppColors.primary600;
      case 'stable':
        return AppColors.primary400;
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
        return AppColors.primary600;
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
        return AppColors.primary500;
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
    if (v <= 2) return AppColors.primary500;
    if (v <= 5) return AppColors.warning500;
    if (v <= 7) return AppColors.warning600;
    return AppColors.error500;
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Sub-widgets
// ═════════════════════════════════════════════════════════════════════════════

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outline.withAlpha(isDark ? 50 : 100)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 40 : 10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: iconBg.withAlpha(isDark ? 30 : 255),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: isDark ? AppColors.primary300 : iconColor, size: 22),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withAlpha(150),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: theme.colorScheme.onSurface.withAlpha(100),
                    ),
                  ),
                ],
              ),
            ),
          ),

          AnimatedCrossFade(
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: theme.colorScheme.outline.withAlpha(50), height: 1),
                  const SizedBox(height: 20),
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
        color: Theme.of(context).colorScheme.onSurface.withAlpha(200),
      ),
    );
  }
}

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
              color: isSelected ? color : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? color : theme.colorScheme.outline.withAlpha(isDark ? 50 : 100),
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
                color: isSelected ? Colors.white : theme.colorScheme.onSurface.withAlpha(200),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
              color: isSelected ? AppColors.primary500 : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primary500 : theme.colorScheme.outline.withAlpha(isDark ? 50 : 100),
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
                    color: isSelected ? Colors.white : theme.colorScheme.onSurface.withAlpha(200),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(isDark ? 80 : 255),
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
                  color: theme.colorScheme.onSurface.withAlpha(150),
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
        return AppColors.primary500;
      case VitalStatus.unknown:
        return Colors.grey.withAlpha(100);
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final VitalStatus status;
  final String unit;
  const _StatusBadge({required this.status, required this.unit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final (label, color, bg) = switch (status) {
      VitalStatus.normal => ('✅ Normal', AppColors.primary700, AppColors.primary50),
      VitalStatus.high => ('⚠️ High', AppColors.warning700, AppColors.warning50),
      VitalStatus.low => ('⬇️ Low', AppColors.info700, AppColors.info50),
      VitalStatus.critical => ('🚨 Critical', AppColors.error700, AppColors.error50),
      VitalStatus.unknown => ('— Enter $unit', AppColors.light700, AppColors.light300),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg.withAlpha(isDark ? 40 : 255),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isDark ? color.withAlpha(200) : color,
        ),
      ),
    );
  }
}

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
    final theme = Theme.of(context);

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
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withAlpha(100)),
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w300,
          color: theme.colorScheme.onSurface.withAlpha(50),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
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
    final l10n = AppLocalizations.of(context)!;
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
                _expanded ? l10n.hideOptional : l10n.showOptional,
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
                  label: 'mg/dL',
                  maxLength: 4,
                  onChanged: (_) => widget.onChanged(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _VitalTextField(
                  controller: widget.weightCtrl,
                  hint: '70',
                  label: 'kg',
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

class _AbnormalVitalsBanner extends StatelessWidget {
  final VisitReportData data;
  const _AbnormalVitalsBanner({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
        color: (isCritical ? AppColors.error50 : AppColors.warning50).withAlpha(isDark ? 40 : 255),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: (isCritical ? AppColors.error300 : AppColors.warning300).withAlpha(100),
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
                      ? '🚨 Critical vitals detected'
                      : '⚠️ Abnormal vitals detected',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isCritical
                        ? (isDark ? AppColors.error200 : AppColors.error700)
                        : (isDark ? AppColors.warning200 : AppColors.warning700),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  abnormal.join(', '),
                  style: TextStyle(
                    fontSize: 12,
                    color: isCritical
                        ? (isDark ? AppColors.error200.withAlpha(200) : AppColors.error600)
                        : (isDark ? AppColors.warning200.withAlpha(200) : AppColors.warning700),
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
      'قياس العلامات الحيوية',
      'العناية بالجروح',
      'إعطاء الأدوية',
      'العناية بالوريد',
      'تثقيف المريض',
      'تقييم الألم',
      'المساعدة في الحركة',
    ];
    for (final s in extras) {
      if (!base.contains(s)) base.add(s);
    }
    return base;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                    ? AppColors.primary50.withAlpha(isDark ? 40 : 255)
                    : theme.colorScheme.surfaceContainerHighest.withAlpha(isDark ? 80 : 255),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary500
                      : theme.colorScheme.outline.withAlpha(isDark ? 50 : 100),
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
                        ? AppColors.primary500
                        : theme.colorScheme.onSurface.withAlpha(100),
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
                            ? (isDark ? AppColors.primary300 : AppColors.primary700)
                            : theme.colorScheme.onSurface,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextField(
      controller: controller,
      maxLines: maxLines,
      minLines: 2,
      maxLength: maxLength,
      textCapitalization: TextCapitalization.sentences,
      style: TextStyle(
        fontSize: 14,
        color: theme.colorScheme.onSurface,
        height: 1.5,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: theme.colorScheme.onSurface.withAlpha(100), fontSize: 13),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha(isDark ? 80 : 255),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.outline.withAlpha(50)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primary500, width: 2),
        ),
        contentPadding: const EdgeInsets.all(14),
        counterStyle: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withAlpha(100)),
      ),
      onChanged: onChanged,
    );
  }
}

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(isDark ? 80 : 255),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outline.withAlpha(50)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _miniField(
                  context,
                  widget.row.nameCtrl,
                  'Medication name',
                  widget.onChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _miniField(
                  context,
                  widget.row.doseCtrl,
                  'Dose',
                  widget.onChanged,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: widget.onRemove,
                icon: const Icon(Icons.close_rounded, size: 18),
                color: theme.colorScheme.onSurface.withAlpha(100),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: widget.row.route,
            dropdownColor: theme.colorScheme.surface,
            decoration: InputDecoration(
              labelText: 'Route',
              labelStyle:
                  TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withAlpha(100)),
              filled: true,
              fillColor: theme.colorScheme.surface,
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
      BuildContext context, TextEditingController ctrl, String hint, VoidCallback onChange) {
    final theme = Theme.of(context);
    return TextField(
      controller: ctrl,
      style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withAlpha(100)),
        filled: true,
        fillColor: theme.colorScheme.surface,
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
