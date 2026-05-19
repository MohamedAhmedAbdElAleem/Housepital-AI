import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../data/models/booking_model.dart';
import '../../data/models/visit_report_data.dart';

// ─────────────────────────────────────────────────────────────────────────────
// VisitReportPdfService
//
// Generates a clean, professional A4 PDF from a completed visit's data.
// ─────────────────────────────────────────────────────────────────────────────

class VisitReportPdfService {
  // ── Colours (Modern Theme) ────────────────────────────────────────────────

  static const _primary = PdfColor.fromInt(0xFF003366); // Dark Navy
  static const _accent = PdfColor.fromInt(0xFF2664EC);  // Primary Blue
  static const _success = PdfColor.fromInt(0xFF2E7D32);
  static const _warning = PdfColor.fromInt(0xFFEF6C00);
  static const _error = PdfColor.fromInt(0xFFC62828);
  static const _textPrimary = PdfColor.fromInt(0xFF212121);
  static const _textSecondary = PdfColor.fromInt(0xFF757575);
  static const _bg = PdfColor.fromInt(0xFFFAFAFA);
  static const _divider = PdfColor.fromInt(0xFFEEEEEE);
  
  static const _successBg = PdfColor.fromInt(0xFFE8F5E9);
  static const _warningBg = PdfColor.fromInt(0xFFFFF3E0);
  static const _errorBg = PdfColor.fromInt(0xFFFFEBEE);
  static const _accentBg = PdfColor.fromInt(0xFFE3F2FD);

  // ── Public API ────────────────────────────────────────────────────────────

  Future<void> preview(
    NurseBooking booking,
    VisitReportData report,
    String nurseName,
    Duration visitDuration,
  ) async {
    final doc = await _build(booking, report, nurseName, visitDuration);
    await Printing.layoutPdf(
      onLayout: (_) async => doc.save(),
      name: _fileName(booking),
    );
  }

  Future<void> share(
    NurseBooking booking,
    VisitReportData report,
    String nurseName,
    Duration visitDuration,
  ) async {
    final doc = await _build(booking, report, nurseName, visitDuration);
    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: _fileName(booking),
    );
  }

  // ── Builder ───────────────────────────────────────────────────────────────

  Future<pw.Document> _build(
    NurseBooking booking,
    VisitReportData report,
    String nurseName,
    Duration visitDuration,
  ) async {
    final doc = pw.Document(
      title: 'Visit Report – ${booking.patientName}',
      author: nurseName,
      creator: 'Housepital App',
    );

    final font = await PdfGoogleFonts.interRegular();
    final fontBold = await PdfGoogleFonts.interBold();
    final fontSemiBold = await PdfGoogleFonts.interSemiBold();

    final now = DateTime.now();
    final visitStart = booking.visitStartedAt ?? now;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        header: (ctx) => _pageHeader(ctx, booking, nurseName, visitStart, fontBold, fontSemiBold),
        footer: (ctx) => _pageFooter(ctx, nurseName, now, font),
        build: (ctx) => [
          _sectionPatientStatus(report, font, fontBold, fontSemiBold),
          pw.SizedBox(height: 20),
          _sectionVitals(report, font, fontBold, fontSemiBold),
          pw.SizedBox(height: 20),
          _sectionCareProvided(report, visitDuration, font, fontBold, fontSemiBold),
          pw.SizedBox(height: 20),
          _sectionNotes(report, font, fontBold, fontSemiBold),
          if (report.followUpRequired) ...[
            pw.SizedBox(height: 20),
            _sectionFollowUp(report, font, fontBold, fontSemiBold),
          ],
          pw.SizedBox(height: 32),
          _signatureRow(nurseName, now, font, fontSemiBold),
        ],
      ),
    );

    return doc;
  }

  // ── Page Header ───────────────────────────────────────────────────────────

  pw.Widget _pageHeader(
    pw.Context ctx,
    NurseBooking booking,
    String nurseName,
    DateTime visitStart,
    pw.Font bold,
    pw.Font semiBold,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('HOUSEPITAL', 
                  style: pw.TextStyle(font: bold, fontSize: 18, color: _primary, letterSpacing: 1.2)),
                pw.Text('Home Healthcare Excellence', 
                  style: pw.TextStyle(fontSize: 8, color: _accent, letterSpacing: 0.5)),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('VISIT REPORT', 
                  style: pw.TextStyle(font: bold, fontSize: 14, color: _accent)),
                pw.Text('ID: ${booking.id.toUpperCase().substring(0, 8)}', 
                  style: const pw.TextStyle(fontSize: 8, color: _textSecondary)),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 12),
        pw.Divider(color: _primary, thickness: 1.5),
        pw.SizedBox(height: 16),
        
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: _infoBlock('PATIENT DETAILS', [
                ('Name', booking.patientName),
                ('Date', DateFormat('dd MMM yyyy').format(visitStart)),
                ('Time', DateFormat('hh:mm a').format(visitStart)),
                if (booking.address != null) ('Location', booking.address!.fullAddress),
              ], bold, semiBold),
            ),
            pw.SizedBox(width: 40),
            pw.Expanded(
              child: _infoBlock('NURSE DETAILS', [
                ('Name', nurseName),
                ('Service', booking.serviceName),
                ('Status', 'Completed'),
              ], bold, semiBold),
            ),
          ],
        ),
        pw.SizedBox(height: 24),
      ],
    );
  }

  pw.Widget _infoBlock(String title, List<(String, String)> items, pw.Font bold, pw.Font semiBold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(font: bold, fontSize: 9, color: _primary, letterSpacing: 1)),
        pw.SizedBox(height: 6),
        ...items.map((i) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 3),
          child: pw.RichText(text: pw.TextSpan(children: [
            pw.TextSpan(text: '${i.$1}: ', style: pw.TextStyle(font: semiBold, fontSize: 8, color: _textSecondary)),
            pw.TextSpan(text: i.$2, style: pw.TextStyle(font: semiBold, fontSize: 8, color: _textPrimary)),
          ])),
        )),
      ],
    );
  }

  // ── Page Footer ───────────────────────────────────────────────────────────

  pw.Widget _pageFooter(pw.Context ctx, String nurseName, DateTime now, pw.Font font) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 10),
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: _divider))),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Housepital Digital Health Record • ${DateFormat('yyyy').format(now)}', 
            style: pw.TextStyle(font: font, fontSize: 7, color: _textSecondary)),
          pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}', 
            style: pw.TextStyle(font: font, fontSize: 7, color: _textSecondary)),
        ],
      ),
    );
  }

  // ── Sections ──────────────────────────────────────────────────────────────

  pw.Widget _sectionPatientStatus(VisitReportData r, pw.Font font, pw.Font bold, pw.Font semiBold) {
    final condColor = _conditionPdfColor(r.overallCondition);
    final condBg = _conditionPdfBg(r.overallCondition);

    return _modernSection('PATIENT STATUS', [
      _kv('Condition', _badge(r.overallCondition.toUpperCase(), condColor, condBg, semiBold), font),
      _kv('Consciousness', _val(_capitalize(r.consciousnessLevel), semiBold), font),
      _kv('Pain Level', _val('${r.painLevel}/10 — ${_painLabel(r.painLevel)}', semiBold), font),
      _kv('Mobility', _val(r.mobility.isEmpty ? 'Not recorded' : r.mobility.map(_capitalize).join(', '), semiBold), font),
    ], 2, bold);
  }

  pw.Widget _sectionVitals(VisitReportData r, pw.Font font, pw.Font bold, pw.Font semiBold) {
    final vitals = <_VitalInfo>[
      _VitalInfo('Blood Pressure', r.bpSystolic != null ? '${r.bpSystolic}/${r.bpDiastolic} mmHg' : '—', r.bpStatus),
      _VitalInfo('Heart Rate', r.heartRate != null ? '${r.heartRate} bpm' : '—', r.heartRateStatus),
      _VitalInfo('Temperature', r.temperature != null ? '${r.temperature} °C' : '—', r.temperatureStatus),
      _VitalInfo('SpO₂', r.oxygenSaturation != null ? '${r.oxygenSaturation}%' : '—', r.spo2Status),
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('VITAL SIGNS', bold),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: vitals.map((v) => _vitalBox(v, font, bold, semiBold)).toList(),
        ),
      ],
    );
  }

  pw.Widget _sectionCareProvided(VisitReportData r, Duration duration, pw.Font font, pw.Font bold, pw.Font semiBold) {
    return _modernSection('CARE PROVIDED', [
      _kv('Duration', _val(_fmtDuration(duration), semiBold), font),
      _kv('Patient Cooperation', _val(_capitalize(r.patientCooperation), semiBold), font),
      _kv('Services', pw.Text(r.servicesPerformed.join(', '), style: pw.TextStyle(font: semiBold, fontSize: 9, color: _primary)), font),
    ], 2, bold);
  }

  pw.Widget _sectionNotes(VisitReportData r, pw.Font font, pw.Font bold, pw.Font semiBold) {
    if (r.clinicalObservations.isEmpty && r.patientFamilyConcerns.isEmpty) return pw.SizedBox();

    return _modernSection('NOTES & OBSERVATIONS', [
      if (r.clinicalObservations.isNotEmpty) _kv('Clinical Observations', _longText(r.clinicalObservations, font), font),
      if (r.patientFamilyConcerns.isNotEmpty) _kv('Family Concerns', _longText(r.patientFamilyConcerns, font), font),
    ], 1, bold);
  }

  pw.Widget _sectionFollowUp(VisitReportData r, pw.Font font, pw.Font bold, pw.Font semiBold) {
    final urgColor = _urgencyColor(r.followUpUrgency);
    final urgBg = _urgencyBg(r.followUpUrgency);

    return _modernSection('FOLLOW-UP', [
      _kv('Urgency', _badge(_urgencyLabel(r.followUpUrgency), urgColor, urgBg, semiBold), font),
      if (r.recommendedActions.isNotEmpty) _kv('Recommendations', _val(r.recommendedActions.map(_actionLabel).join(', '), semiBold), font),
      if (r.alertMessage.isNotEmpty) _kv('Alert', pw.Text(r.alertMessage, style: pw.TextStyle(font: semiBold, fontSize: 9, color: _error)), font),
    ], 1, bold);
  }

  // ── Modern UI Components ──────────────────────────────────────────────────

  pw.Widget _modernSection(String title, List<pw.Widget> children, int columns, pw.Font bold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle(title, bold),
        pw.SizedBox(height: 8),
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: _bg,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            border: pw.Border.all(color: _divider),
          ),
          child: pw.Table(
            children: _buildTableRows(children, columns),
          ),
        ),
      ],
    );
  }

  List<pw.TableRow> _buildTableRows(List<pw.Widget> widgets, int columns) {
    final rows = <pw.TableRow>[];
    for (var i = 0; i < widgets.length; i += columns) {
      final rowWidgets = <pw.Widget>[];
      for (var j = 0; j < columns; j++) {
        if (i + j < widgets.length) {
          rowWidgets.add(pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 4),
            child: widgets[i + j],
          ));
        } else {
          rowWidgets.add(pw.SizedBox());
        }
      }
      rows.add(pw.TableRow(children: rowWidgets));
    }
    return rows;
  }

  pw.Widget _sectionTitle(String title, pw.Font bold) => pw.Text(
    title, style: pw.TextStyle(font: bold, fontSize: 10, color: _primary, letterSpacing: 1));

  pw.Widget _kv(String label, pw.Widget value, pw.Font font) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(label, style: pw.TextStyle(font: font, fontSize: 7, color: _textSecondary)),
      pw.SizedBox(height: 4),
      value,
    ],
  );

  pw.Widget _val(String text, pw.Font semiBold) => pw.Text(text, 
    style: pw.TextStyle(font: semiBold, fontSize: 9, color: _textPrimary));

  pw.Widget _longText(String text, pw.Font font) => pw.Text(text, 
    style: pw.TextStyle(font: font, fontSize: 9, color: _textPrimary, lineSpacing: 2));

  pw.Widget _vitalBox(_VitalInfo v, pw.Font font, pw.Font bold, pw.Font semiBold) {
    final (statusLabel, statusColor, chipBg) = _vitalStatusStyle(v.status);
    return pw.Container(
      width: 110,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: _bg,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
        border: pw.Border.all(color: _divider),
      ),
      child: pw.Column(
        children: [
          pw.Text(v.label, style: pw.TextStyle(font: font, fontSize: 7, color: _textSecondary)),
          pw.SizedBox(height: 6),
          pw.Text(v.value, style: pw.TextStyle(font: bold, fontSize: 13, color: _primary)),
          pw.SizedBox(height: 6),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: pw.BoxDecoration(color: chipBg, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))),
            child: pw.Text(statusLabel, style: pw.TextStyle(font: semiBold, fontSize: 6, color: statusColor)),
          ),
        ],
      ),
    );
  }

  pw.Widget _badge(String label, PdfColor color, PdfColor bg, pw.Font semiBold) =>
    pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: pw.BoxDecoration(color: bg, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6))),
      child: pw.Text(label, style: pw.TextStyle(font: semiBold, fontSize: 7, color: color)),
    );

  pw.Widget _signatureRow(String nurseName, DateTime date, pw.Font font, pw.Font semiBold) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('NURSE SIGNATURE', style: pw.TextStyle(font: semiBold, fontSize: 8, color: _textSecondary)),
            pw.SizedBox(height: 24),
            pw.Container(width: 180, height: 1, color: _primary),
            pw.SizedBox(height: 4),
            pw.Text(nurseName, style: pw.TextStyle(font: semiBold, fontSize: 10, color: _primary)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('REPORT GENERATED', style: pw.TextStyle(font: semiBold, fontSize: 8, color: _textSecondary)),
            pw.SizedBox(height: 4),
            pw.Text(DateFormat('dd MMM yyyy, hh:mm a').format(date), 
              style: pw.TextStyle(font: semiBold, fontSize: 9, color: _textPrimary)),
          ],
        ),
      ],
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _fileName(NurseBooking b) {
    final date = DateFormat('yyyyMMdd').format(b.visitStartedAt ?? DateTime.now());
    final safe = b.patientName.replaceAll(' ', '_');
    return 'VisitReport_${safe}_$date.pdf';
  }

  String _capitalize(String? s) {
    if (s == null || s.isEmpty) return 'N/A';
    return s[0].toUpperCase() + s.substring(1).replaceAll('_', ' ');
  }

  String _painLabel(int v) => switch (v) {
    0 => 'None',
    <= 2 => 'Minimal',
    <= 4 => 'Mild',
    <= 6 => 'Moderate',
    <= 8 => 'Severe',
    _ => 'Worst',
  };

  String _fmtDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  String _urgencyLabel(String v) => switch (v) {
    'within_48h' => 'Within 48h',
    'urgent'     => 'Urgent',
    'emergency'  => 'Emergency',
    _            => 'Routine',
  };

  String _actionLabel(String v) => switch (v) {
    'doctor_consult'    => 'Doctor Consult',
    'lab_tests'         => 'Lab Tests',
    'medication_review' => 'Medication Review',
    'physio'            => 'Physiotherapy',
    'hospital_admission'=> 'Hospital Admission',
    'family_education'  => 'Family Education',
    _                   => _capitalize(v),
  };

  PdfColor _conditionPdfColor(String v) => switch (v) {
    'excellent' || 'stable' => _success,
    'fair'                  => _warning,
    'poor' || 'critical'    => _error,
    _                       => _accent,
  };

  PdfColor _conditionPdfBg(String v) => switch (v) {
    'excellent' || 'stable' => _successBg,
    'fair'                  => _warningBg,
    'poor' || 'critical'    => _errorBg,
    _                       => _accentBg,
  };

  PdfColor _urgencyColor(String v) => switch (v) {
    'emergency'  => _error,
    'urgent'     => _warning,
    'within_48h' => _accent,
    _            => _success,
  };

  PdfColor _urgencyBg(String v) => switch (v) {
    'emergency'  => _errorBg,
    'urgent'     => _warningBg,
    'within_48h' => _accentBg,
    _            => _successBg,
  };

  (String, PdfColor, PdfColor) _vitalStatusStyle(VitalStatus s) => switch (s) {
    VitalStatus.normal   => ('NORMAL',   _success, _successBg),
    VitalStatus.high     => ('HIGH',     _warning, _warningBg),
    VitalStatus.low      => ('LOW',      _accent, _accentBg),
    VitalStatus.critical => ('CRITICAL', _error,   _errorBg),
    VitalStatus.unknown  => ('N/A',      _textSecondary, _divider),
  };
}

class _VitalInfo {
  final String label;
  final String value;
  final VitalStatus status;
  const _VitalInfo(this.label, this.value, this.status);
}
