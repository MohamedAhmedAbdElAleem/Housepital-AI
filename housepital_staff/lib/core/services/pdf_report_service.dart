import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PdfReportService {
  static Future<bool> generateAndShowReport({
    required Map<String, dynamic> dashboardData,
  }) async {
    try {
      final pdfBytes = await _generatePdfBytes(dashboardData);

      if (pdfBytes != null) {
        await Printing.layoutPdf(
          onLayout: (format) async => pdfBytes,
          name:
              'Housepital_Admin_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}',
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Error showing PDF: $e');
      return false;
    }
  }

  static Future<Uint8List?> _generatePdfBytes(
    Map<String, dynamic> dashboardData,
  ) async {
    try {
      final pdf = pw.Document();

      // Try to load logo
      pw.MemoryImage? logoImage;
      try {
        final ByteData logoData = await rootBundle.load(
          'assets/images/Logo.png',
        );
        logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
      } catch (e) {
        print('Could not load logo: $e');
      }

      // Extract data
      final users = dashboardData['users'] ?? {};
      final bookings = dashboardData['bookings'] ?? {};
      final today = dashboardData['today'] ?? {};
      final financial = dashboardData['financial'] ?? {};
      final providers = dashboardData['providers'] ?? {};
      final topNurses = dashboardData['topNurses'] as List? ?? [];

      final dateFormat = DateFormat('MMMM d, yyyy');
      final timeFormat = DateFormat('h:mm a');
      final now = DateTime.now();

      // Colors
      final primaryColor = PdfColor.fromHex('#2ECC71');
      final secondaryColor = PdfColor.fromHex('#3498BB');

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          header:
              (context) =>
                  _buildHeader(logoImage, primaryColor, now, dateFormat),
          footer: (context) => _buildFooter(context),
          build:
              (context) => [
                pw.SizedBox(height: 10),

                // Title
                pw.Center(
                  child: pw.Text(
                    'Admin Dashboard Report',
                    style: pw.TextStyle(
                      fontSize: 26,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Center(
                  child: pw.Text(
                    'Generated on ${dateFormat.format(now)} at ${timeFormat.format(now)}',
                    style: pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
                  ),
                ),
                pw.SizedBox(height: 25),

                // Overview
                _sectionTitle('Overview Statistics', primaryColor),
                pw.SizedBox(height: 10),
                _statsRow([
                  _statItem(
                    'Total Users',
                    '${users['total'] ?? 0}',
                    secondaryColor,
                  ),
                  _statItem(
                    'Total Bookings',
                    '${bookings['total'] ?? 0}',
                    primaryColor,
                  ),
                  _statItem(
                    'Completed',
                    '${bookings['completed'] ?? 0}',
                    PdfColors.green,
                  ),
                ]),
                pw.SizedBox(height: 20),

                // Today
                _sectionTitle('Today\'s Activity', primaryColor),
                pw.SizedBox(height: 10),
                _statsRow([
                  _statItem(
                    'New Bookings',
                    '${today['newBookings'] ?? 0}',
                    secondaryColor,
                  ),
                  _statItem(
                    'Active',
                    '${today['activeBookings'] ?? 0}',
                    PdfColors.orange,
                  ),
                  _statItem(
                    'Completed',
                    '${today['completedBookings'] ?? 0}',
                    primaryColor,
                  ),
                ]),
                pw.SizedBox(height: 20),

                // Financial
                _sectionTitle('Financial Summary', primaryColor),
                pw.SizedBox(height: 10),
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: primaryColor),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                    children: [
                      pw.Column(
                        children: [
                          pw.Text(
                            'Today\'s Revenue',
                            style: pw.TextStyle(
                              fontSize: 11,
                              color: PdfColors.grey600,
                            ),
                          ),
                          pw.Text(
                            '${financial['today']?['revenue'] ?? 0} EGP',
                            style: pw.TextStyle(
                              fontSize: 22,
                              fontWeight: pw.FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      pw.Container(
                        width: 1,
                        height: 40,
                        color: PdfColors.grey400,
                      ),
                      pw.Column(
                        children: [
                          pw.Text(
                            'Monthly Revenue',
                            style: pw.TextStyle(
                              fontSize: 11,
                              color: PdfColors.grey600,
                            ),
                          ),
                          pw.Text(
                            '${financial['thisMonth']?['revenue'] ?? 0} EGP',
                            style: pw.TextStyle(
                              fontSize: 22,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.green700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Staff
                _sectionTitle('Staff Overview', primaryColor),
                pw.SizedBox(height: 10),
                _statsRow([
                  _statItem(
                    'Total Nurses',
                    '${providers['nurses']?['total'] ?? 0}',
                    primaryColor,
                  ),
                  _statItem(
                    'Online Now',
                    '${providers['nurses']?['online'] ?? 0}',
                    PdfColors.orange,
                  ),
                  _statItem(
                    'Total Doctors',
                    '${providers['doctors']?['total'] ?? 0}',
                    secondaryColor,
                  ),
                ]),
                pw.SizedBox(height: 20),

                // Top Performers
                if (topNurses.isNotEmpty) ...[
                  _sectionTitle('Top Performers', primaryColor),
                  pw.SizedBox(height: 10),
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey400),
                    children: [
                      pw.TableRow(
                        decoration: pw.BoxDecoration(color: primaryColor),
                        children:
                            ['#', 'Name', 'Rating', 'Visits', 'Earnings']
                                .map(
                                  (h) => pw.Padding(
                                    padding: const pw.EdgeInsets.all(6),
                                    child: pw.Text(
                                      h,
                                      style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColors.white,
                                      ),
                                      textAlign: pw.TextAlign.center,
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                      ...topNurses.asMap().entries.map((e) {
                        final i = e.key;
                        final n = e.value;
                        return pw.TableRow(
                          children:
                              [
                                    '${i + 1}',
                                    n['name'] ?? '',
                                    '${n['rating'] ?? 0}',
                                    '${n['visits'] ?? 0}',
                                    '${n['earnings'] ?? 0} EGP',
                                  ]
                                  .map(
                                    (c) => pw.Padding(
                                      padding: const pw.EdgeInsets.all(6),
                                      child: pw.Text(
                                        c,
                                        textAlign: pw.TextAlign.center,
                                      ),
                                    ),
                                  )
                                  .toList(),
                        );
                      }),
                    ],
                  ),
                ],
              ],
        ),
      );

      return pdf.save();
    } catch (e, stack) {
      print('Error generating PDF bytes: $e');
      print('Stack: $stack');
      return null;
    }
  }

  static pw.Widget _buildHeader(
    pw.MemoryImage? logo,
    PdfColor primaryColor,
    DateTime now,
    DateFormat dateFormat,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: primaryColor, width: 2)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Row(
            children: [
              if (logo != null)
                pw.Image(logo, width: 45, height: 45)
              else
                pw.Container(
                  width: 45,
                  height: 45,
                  decoration: pw.BoxDecoration(
                    color: primaryColor,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      'H',
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ),
                ),
              pw.SizedBox(width: 10),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Housepital',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  pw.Text(
                    'Healthcare at Your Doorstep',
                    style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                  ),
                ],
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Admin Report',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                dateFormat.format(now),
                style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey400)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            '© ${DateTime.now().year} Housepital',
            style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
          pw.Text(
            'Page ${context.pageNumber}/${context.pagesCount}',
            style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  static pw.Widget _sectionTitle(String title, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        border: pw.Border(left: pw.BorderSide(color: color, width: 3)),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  static pw.Widget _statsRow(List<pw.Widget> items) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
      children: items,
    );
  }

  static pw.Widget _statItem(String label, String value, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            label,
            style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
        ],
      ),
    );
  }
}
