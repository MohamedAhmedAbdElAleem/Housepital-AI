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
  static const _primary = PdfColor.fromInt(0xFF2664EC);
  static const _success = PdfColor.fromInt(0xFF43A048);
  static const _warning = PdfColor.fromInt(0xFFFB8A00);
  static const _error = PdfColor.fromInt(0xFFF44336);
  static const _textPrimary = PdfColor.fromInt(0xFF232323);
  static const _textMuted = PdfColor.fromInt(0xFF818181);
  static const _bg = PdfColor.fromInt(0xFFF9F9F9);
  static const _divider = PdfColor.fromInt(0xFFEBEBEB);
  static const _headerBg = PdfColor.fromInt(0xFF1746C0);
  static const _successBg = PdfColor.fromInt(0xFFECF6ED);
  static const _warningBg = PdfColor.fromInt(0xFFFFF3E6);
  static const _errorBg = PdfColor.fromInt(0xFFFEECEB);

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

  Future<void> previewFromRaw(Map<String, dynamic> record, String patientName) async {
    final bookingJson = record['bookingId'] is Map ? record['bookingId'] : {};
    final nurseJson = record['nurseId'] is Map ? record['nurseId'] : {};
    final nurseName = nurseJson['user']?['name'] ?? 'Care Provider';

    final booking = NurseBooking(
      id: bookingJson['_id'] ?? record['bookingId']?.toString() ?? '',
      type: 'home_nursing',
      serviceName: bookingJson['serviceName'] ?? 'Home Nursing Visit',
      servicePrice: 0.0,
      patientId: record['patientId']?.toString() ?? '',
      patientName: patientName,
      customerName: 'Customer',
      status: 'completed',
      timeOption: 'scheduled',
      createdAt: record['createdAt'] != null ? (DateTime.tryParse(record['createdAt']) ?? DateTime.now()) : DateTime.now(),
      visitStartedAt: bookingJson['visitStartedAt'] != null ? DateTime.tryParse(bookingJson['visitStartedAt']) : null,
      visitEndedAt: bookingJson['visitEndedAt'] != null ? DateTime.tryParse(bookingJson['visitEndedAt']) : null,
    );

    final report = VisitReportData.fromMap(record);
    final visitDuration = (booking.visitStartedAt != null && booking.visitEndedAt != null)
        ? booking.visitEndedAt!.difference(booking.visitStartedAt!)
        : Duration(minutes: record['visitDurationMinutes'] is num ? (record['visitDurationMinutes'] as num).toInt() : 30);

    await preview(booking, report, nurseName, visitDuration);
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
        margin: const pw.EdgeInsets.all(36),
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        header: (ctx) => _pageHeader(ctx, booking, nurseName, visitStart, fontBold, fontSemiBold),
        footer: (ctx) => _pageFooter(ctx, nurseName, now, font),
        build: (ctx) => [
          _sectionPatientStatus(report, font, fontBold, fontSemiBold),
          pw.SizedBox(height: 16),
          _sectionVitals(report, font, fontBold, fontSemiBold),
          pw.SizedBox(height: 16),
          _sectionCareProvided(report, visitDuration, font, fontBold, fontSemiBold),
          pw.SizedBox(height: 16),
          _sectionNotes(report, font, fontBold, fontSemiBold),
          if (report.followUpRequired) ...[
            pw.SizedBox(height: 16),
            _sectionFollowUp(report, font, fontBold, fontSemiBold),
          ],
          pw.SizedBox(height: 24),
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
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: const pw.BoxDecoration(
            color: _headerBg,
            borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '🏥 HOUSEPITAL',
                    style: pw.TextStyle(
                      font: bold,
                      fontSize: 13,
                      color: PdfColors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'HOME NURSING VISIT REPORT',
                    style: pw.TextStyle(
                      font: semiBold,
                      fontSize: 9,
                      color: PdfColor(1, 1, 1, 0.7),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  _headerMeta('Date', DateFormat('dd MMM yyyy').format(visitStart), bold),
                  pw.SizedBox(height: 3),
                  _headerMeta('Time', DateFormat('hh:mm a').format(visitStart), bold),
                ],
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: pw.BoxDecoration(
            color: _bg,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            border: pw.Border.all(color: _divider),
          ),
          child: pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _metaLabel('PATIENT'),
                    _metaValue(booking.patientName, bold),
                  ],
                ),
              ),
              _vertDivider(),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _metaLabel('NURSE'),
                    _metaValue(nurseName, bold),
                    pw.SizedBox(height: 2),
                    _metaSmall(booking.serviceName),
                  ],
                ),
              ),
              _vertDivider(),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _metaLabel('BOOKING ID'),
                  _metaSmall(
                    booking.id.length > 10
                        ? '...${booking.id.substring(booking.id.length - 8)}'
                        : booking.id,
                  ),
                ],
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 14),
      ],
    );
  }

  // ── Page Footer ───────────────────────────────────────────────────────────

  pw.Widget _pageFooter(
    pw.Context ctx,
    String nurseName,
    DateTime generatedAt,
    pw.Font font,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 8),
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _divider, width: 0.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Generated by Housepital — ${DateFormat('dd MMM yyyy, hh:mm a').format(generatedAt)}',
            style: pw.TextStyle(font: font, fontSize: 8, color: _textMuted),
          ),
          pw.Text(
            'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
            style: pw.TextStyle(font: font, fontSize: 8, color: _textMuted),
          ),
        ],
      ),
    );
  }

  // ── Sections ──────────────────────────────────────────────────────────────

  pw.Widget _sectionPatientStatus(
    VisitReportData r,
    pw.Font font,
    pw.Font bold,
    pw.Font semiBold,
  ) {
    final condColor = _conditionPdfColor(r.overallCondition);
    final condBg = _conditionPdfBg(r.overallCondition);

    return _sectionCard(
      title: 'PATIENT STATUS',
      accentColor: _primary,
      font: font,
      bold: bold,
      child: pw.Column(
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: _kv('Overall Condition',
                  _badge(r.overallCondition.toUpperCase(), condColor, condBg, semiBold),
                  font, bold),
              ),
              pw.Expanded(
                child: _kv('Consciousness',
                  _textVal(_capitalize(r.consciousnessLevel), bold),
                  font, bold),
              ),
              pw.Expanded(
                child: _kv('Pain Level',
                  _textVal('${r.painLevel}/10 — ${_painLabel(r.painLevel)}', bold),
                  font, bold),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: _kv('Mobility',
                  _textVal(
                    r.mobility.isEmpty ? 'Not recorded' : r.mobility.map(_capitalize).join(', '),
                    bold,
                  ),
                  font, bold),
              ),
              pw.Expanded(
                child: _kv('Wound / IV Site',
                  _textVal(r.woundSiteCondition == 'na' ? 'N/A' : _capitalize(r.woundSiteCondition), bold),
                  font, bold),
              ),
              pw.Expanded(child: pw.SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _sectionVitals(
    VisitReportData r,
    pw.Font font,
    pw.Font bold,
    pw.Font semiBold,
  ) {
    final vitals = <_VitalInfo>[
      _VitalInfo('Blood Pressure',
        r.bpSystolic != null ? '${r.bpSystolic}/${r.bpDiastolic} mmHg' : '—',
        r.bpStatus),
      _VitalInfo('Heart Rate',
        r.heartRate != null ? '${r.heartRate} bpm' : '—',
        r.heartRateStatus),
      _VitalInfo('Temperature',
        r.temperature != null ? '${r.temperature} °C' : '—',
        r.temperatureStatus),
      _VitalInfo('SpO₂',
        r.oxygenSaturation != null ? '${r.oxygenSaturation}%' : '—',
        r.spo2Status),
      if (r.respiratoryRate != null)
        _VitalInfo('Resp. Rate', '${r.respiratoryRate} /min', VitalStatus.normal),
      if (r.bloodSugar != null)
        _VitalInfo('Blood Sugar', '${r.bloodSugar} mg/dL', VitalStatus.normal),
      if (r.weight != null)
        _VitalInfo('Weight', '${r.weight} kg', VitalStatus.normal),
    ];

    return _sectionCard(
      title: 'VITAL SIGNS',
      accentColor: _error,
      font: font,
      bold: bold,
      child: pw.Wrap(
        spacing: 8,
        runSpacing: 8,
        children: vitals.map((v) => _vitalChip(v, font, bold, semiBold)).toList(),
      ),
    );
  }

  pw.Widget _vitalChip(
    _VitalInfo v,
    pw.Font font,
    pw.Font bold,
    pw.Font semiBold,
  ) {
    final (statusLabel, statusColor, chipBg) = _vitalStatusStyle(v.status);
    return pw.Container(
      width: 118,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: chipBg,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        border: pw.Border.all(color: statusColor, width: 0.6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(v.label,
            style: pw.TextStyle(font: font, fontSize: 8, color: _textMuted)),
          pw.SizedBox(height: 4),
          pw.Text(v.value,
            style: pw.TextStyle(font: bold, fontSize: 13, color: _textPrimary)),
          pw.SizedBox(height: 3),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: pw.BoxDecoration(
              color: statusColor,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
            ),
            child: pw.Text(statusLabel,
              style: pw.TextStyle(font: semiBold, fontSize: 7, color: PdfColors.white)),
          ),
        ],
      ),
    );
  }

  pw.Widget _sectionCareProvided(
    VisitReportData r,
    Duration duration,
    pw.Font font,
    pw.Font bold,
    pw.Font semiBold,
  ) {
    return _sectionCard(
      title: 'CARE PROVIDED',
      accentColor: PdfColor.fromInt(0xFF3498BB),
      font: font,
      bold: bold,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: _kv('Visit Duration',
                  _textVal(_fmtDuration(duration), bold),
                  font, bold),
              ),
              pw.Expanded(
                child: _kv('Patient Cooperation',
                  _textVal(_capitalize(r.patientCooperation), bold),
                  font, bold),
              ),
              pw.Expanded(child: pw.SizedBox()),
            ],
          ),
          pw.SizedBox(height: 8),
          _kvRaw('Services Performed',
            pw.Wrap(
              spacing: 4,
              runSpacing: 4,
              children: r.servicesPerformed
                .map((s) => _pill(s, _primary, font))
                .toList(),
            ),
            font, bold),
          if (r.procedures.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            _kvRaw('Procedures',
              pw.Wrap(
                spacing: 4,
                runSpacing: 4,
                children: r.procedures
                  .map((s) => _pill(s, PdfColor.fromInt(0xFF3498BB), font))
                  .toList(),
              ),
              font, bold),
          ],
          if (r.medications.isNotEmpty) ...[
            pw.SizedBox(height: 10),
            pw.Text('Medications Given',
              style: pw.TextStyle(font: bold, fontSize: 9, color: _textMuted)),
            pw.SizedBox(height: 4),
            _medicationsTable(r.medications, font, bold),
          ],
        ],
      ),
    );
  }

  pw.Widget _medicationsTable(
    List<MedicationEntry> meds,
    pw.Font font,
    pw.Font bold,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: _divider, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(1.5),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _bg),
          children: ['Medication', 'Dose', 'Route'].map((h) => pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: pw.Text(h,
              style: pw.TextStyle(font: bold, fontSize: 8, color: _textMuted)),
          )).toList(),
        ),
        ...meds.map((m) => pw.TableRow(
          children: [
            _tableCell(m.name.isEmpty ? '—' : m.name, font),
            _tableCell(m.dose.isEmpty ? '—' : m.dose, font),
            _tableCell(_capitalize(m.route), font),
          ],
        )),
      ],
    );
  }

  pw.Widget _sectionNotes(
    VisitReportData r,
    pw.Font font,
    pw.Font bold,
    pw.Font semiBold,
  ) {
    final hasAny = r.clinicalObservations.isNotEmpty ||
        r.patientFamilyConcerns.isNotEmpty ||
        r.homeEnvironment.isNotEmpty ||
        r.familyPresent;

    if (!hasAny) return pw.SizedBox();

    return _sectionCard(
      title: 'NOTES & OBSERVATIONS',
      accentColor: PdfColor.fromInt(0xFFE47E00),
      font: font,
      bold: bold,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (r.clinicalObservations.isNotEmpty) ...[
            _kvRaw('Clinical Observations',
              pw.Text(r.clinicalObservations,
                style: pw.TextStyle(font: font, fontSize: 10, color: _textPrimary, lineSpacing: 3)),
              font, bold),
            pw.SizedBox(height: 8),
          ],
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: _kv('Family Present',
                  _textVal(r.familyPresent ? 'Yes' : 'No', bold),
                  font, bold),
              ),
              if (r.homeEnvironment.isNotEmpty)
                pw.Expanded(
                  child: _kv('Home Environment',
                    _textVal(r.homeEnvironment.map(_capitalize).join(', '), bold),
                    font, bold),
                ),
              pw.Expanded(child: pw.SizedBox()),
            ],
          ),
          if (r.patientFamilyConcerns.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            _kvRaw('Patient / Family Concerns',
              pw.Text(r.patientFamilyConcerns,
                style: pw.TextStyle(font: font, fontSize: 10, color: _textPrimary, lineSpacing: 3)),
              font, bold),
          ],
        ],
      ),
    );
  }

  pw.Widget _sectionFollowUp(
    VisitReportData r,
    pw.Font font,
    pw.Font bold,
    pw.Font semiBold,
  ) {
    final urgColor = _urgencyColor(r.followUpUrgency);
    final urgBg = _urgencyBg(r.followUpUrgency);

    return _sectionCard(
      title: 'FOLLOW-UP & ALERTS',
      accentColor: _error,
      font: font,
      bold: bold,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: _kv('Follow-up Required',
                  _textVal('Yes', bold),
                  font, bold),
              ),
              pw.Expanded(
                child: _kv('Urgency',
                  _badge(_urgencyLabel(r.followUpUrgency), urgColor, urgBg, semiBold),
                  font, bold),
              ),
              pw.Expanded(child: pw.SizedBox()),
            ],
          ),
          if (r.recommendedActions.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            _kvRaw('Recommended Actions',
              pw.Wrap(
                spacing: 4,
                runSpacing: 4,
                children: r.recommendedActions
                  .map((a) => _pill(_actionLabel(a), _error, font))
                  .toList(),
              ),
              font, bold),
          ],
          if (r.alertMessage.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: _errorBg,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                border: pw.Border.all(color: _error, width: 0.5),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('⚠ Alert for Care Team',
                    style: pw.TextStyle(font: bold, fontSize: 9, color: _error)),
                  pw.SizedBox(height: 4),
                  pw.Text(r.alertMessage,
                    style: pw.TextStyle(font: font, fontSize: 10, color: _textPrimary, lineSpacing: 3)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _signatureRow(
    String nurseName,
    DateTime date,
    pw.Font font,
    pw.Font semiBold,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _divider),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Nurse Signature',
                  style: pw.TextStyle(font: semiBold, fontSize: 9, color: _textMuted)),
                pw.SizedBox(height: 6),
                pw.Container(
                  height: 1,
                  width: 140,
                  color: _textPrimary,
                ),
                pw.SizedBox(height: 4),
                pw.Text(nurseName,
                  style: pw.TextStyle(font: semiBold, fontSize: 10, color: _textPrimary)),
                pw.Text('Certified Nurse — Housepital',
                  style: pw.TextStyle(font: font, fontSize: 8, color: _textMuted)),
              ],
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('Report Generated',
                style: pw.TextStyle(font: semiBold, fontSize: 9, color: _textMuted)),
              pw.SizedBox(height: 4),
              pw.Text(DateFormat('dd MMM yyyy').format(date),
                style: pw.TextStyle(font: semiBold, fontSize: 10, color: _textPrimary)),
              pw.Text(DateFormat('hh:mm a').format(date),
                style: pw.TextStyle(font: font, fontSize: 9, color: _textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Modern UI Components ──────────────────────────────────────────────────

  pw.Widget _sectionCard({
    required String title,
    required PdfColor accentColor,
    required pw.Font font,
    required pw.Font bold,
    required pw.Widget child,
  }) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _divider),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: pw.BoxDecoration(
              color: accentColor,
              borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(5),
                topRight: pw.Radius.circular(5),
              ),
            ),
            child: pw.Text(
              title,
              style: pw.TextStyle(font: bold, fontSize: 9, color: PdfColors.white, letterSpacing: 1.2),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(12),
            child: child,
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  pw.Widget _kv(String label, pw.Widget value, pw.Font font, pw.Font bold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label,
          style: pw.TextStyle(font: font, fontSize: 8, color: _textMuted)),
        pw.SizedBox(height: 3),
        value,
      ],
    );
  }

  pw.Widget _kvRaw(String label, pw.Widget value, pw.Font font, pw.Font bold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label,
          style: pw.TextStyle(font: font, fontSize: 8, color: _textMuted)),
        pw.SizedBox(height: 4),
        value,
      ],
    );
  }

  pw.Widget _textVal(String text, pw.Font bold) => pw.Text(
    text,
    style: pw.TextStyle(font: bold, fontSize: 10, color: _textPrimary),
  );

  pw.Widget _badge(String label, PdfColor color, PdfColor bg, pw.Font semiBold) =>
    pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: pw.BoxDecoration(
        color: bg,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
        border: pw.Border.all(color: color, width: 0.5),
      ),
      child: pw.Text(label,
        style: pw.TextStyle(font: semiBold, fontSize: 8, color: color)),
    );

  pw.Widget _pill(String label, PdfColor color, pw.Font font) =>
    pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
        border: pw.Border.all(color: color, width: 0.7),
      ),
      child: pw.Text(label,
        style: pw.TextStyle(font: font, fontSize: 8, color: color)),
    );

  pw.Widget _tableCell(String text, pw.Font font) =>
    pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: pw.Text(text,
        style: pw.TextStyle(font: font, fontSize: 9, color: _textPrimary)),
    );

  pw.Widget _metaLabel(String text) => pw.Text(text,
    style: const pw.TextStyle(fontSize: 7, color: _textMuted, letterSpacing: 0.8));

  pw.Widget _metaValue(String text, pw.Font bold) => pw.Text(text,
    style: pw.TextStyle(font: bold, fontSize: 11, color: _textPrimary));

  pw.Widget _metaSmall(String text) => pw.Text(text,
    style: const pw.TextStyle(fontSize: 8, color: _textMuted));

  pw.Widget _headerMeta(String label, String value, pw.Font bold) =>
    pw.RichText(text: pw.TextSpan(children: [
      pw.TextSpan(text: '$label  ',
        style: pw.TextStyle(font: bold, fontSize: 8, color: PdfColor(1, 1, 1, 0.7))),
      pw.TextSpan(text: value,
        style: pw.TextStyle(font: bold, fontSize: 9, color: PdfColors.white)),
    ]));

  pw.Widget _vertDivider() => pw.Container(
    width: 0.5, height: 36,
    margin: const pw.EdgeInsets.symmetric(horizontal: 12),
    color: _divider,
  );

  String _fileName(NurseBooking b) {
    final date = DateFormat('yyyyMMdd').format(b.visitStartedAt ?? DateTime.now());
    final safe = b.patientName.replaceAll(' ', '_');
    return 'VisitReport_${safe}_$date.pdf';
  }

  String _capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).replaceAll('_', ' ');

  String _painLabel(int v) {
    if (v == 0) return 'None';
    if (v <= 2) return 'Minimal';
    if (v <= 4) return 'Mild';
    if (v <= 6) return 'Moderate';
    if (v <= 8) return 'Severe';
    return 'Worst';
  }

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
    _                       => _primary,
  };

  PdfColor _conditionPdfBg(String v) => switch (v) {
    'excellent' || 'stable' => _successBg,
    'fair'                  => _warningBg,
    'poor' || 'critical'    => _errorBg,
    _                       => PdfColor.fromInt(0xFFE4EBFC),
  };

  PdfColor _urgencyColor(String v) => switch (v) {
    'emergency'  => _error,
    'urgent'     => _warning,
    'within_48h' => PdfColor.fromInt(0xFF3498BB),
    _            => _success,
  };

  PdfColor _urgencyBg(String v) => switch (v) {
    'emergency'  => _errorBg,
    'urgent'     => _warningBg,
    'within_48h' => PdfColor.fromInt(0xFFE6F3F7),
    _            => _successBg,
  };

  (String, PdfColor, PdfColor) _vitalStatusStyle(VitalStatus s) => switch (s) {
    VitalStatus.normal   => ('NORMAL',   _success, _successBg),
    VitalStatus.high     => ('HIGH',     _warning, _warningBg),
    VitalStatus.low      => ('LOW',      _primary, PdfColor.fromInt(0xFFE4EBFC)),
    VitalStatus.critical => ('CRITICAL', _error,   _errorBg),
    VitalStatus.unknown  => ('N/A',      PdfColor.fromInt(0xFFA7A7A7), _bg),
  };
}

class _VitalInfo {
  final String label;
  final String value;
  final VitalStatus status;
  const _VitalInfo(this.label, this.value, this.status);
}
