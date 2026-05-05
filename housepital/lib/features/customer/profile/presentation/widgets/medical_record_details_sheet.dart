import 'package:flutter/material.dart';
import '../services/visit_report_pdf_service.dart';

class MedicalRecordDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> record;

  const MedicalRecordDetailsSheet({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final booking = record['bookingId'] ?? {};
    final serviceName = booking['serviceName'] ?? 'General Visit';
    final nurse = record['nurseId']?['user']?['name'] ?? 'Care Provider';
    final vitals = record['vitals'] ?? {};
    final careProvided = record['careProvided'] ?? {};
    final notes = record['notes'] ?? {};
    final followUp = record['followUp'] ?? {};
    
    final pdfService = VisitReportPdfService();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(serviceName, nurse, pdfService),
                  const SizedBox(height: 32),
                  
                  if (vitals.isNotEmpty) ...[
                    _buildSectionTitle('Vital Signs'),
                    const SizedBox(height: 16),
                    _buildVitalsGrid(vitals),
                    const SizedBox(height: 32),
                  ],

                  _buildSectionTitle('Clinical Notes'),
                  const SizedBox(height: 16),
                  _buildObservationCard(notes['clinicalObservations'] ?? 'No observations recorded.'),
                  const SizedBox(height: 32),

                  _buildSectionTitle('Services Performed'),
                  const SizedBox(height: 16),
                  _buildServicesList(careProvided['servicesPerformed'] ?? []),
                  const SizedBox(height: 32),

                  if (followUp['required'] == true) ...[
                    _buildSectionTitle('Follow-up Instructions'),
                    const SizedBox(height: 16),
                    _buildFollowUpCard(followUp),
                    const SizedBox(height: 32),
                  ],

                  _buildActionButtons(context, pdfService),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String service, String provider, VisitReportPdfService pdfService) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0D9488).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.medical_services_rounded, color: Color(0xFF0D9488), size: 32),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                service,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 4),
              Text(
                'Provided by $provider',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => pdfService.preview(record),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0D9488).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.visibility_outlined, color: Color(0xFF0D9488), size: 20),
          ),
          tooltip: 'Preview PDF',
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
    );
  }

  Widget _buildVitalsGrid(Map<String, dynamic> vitals) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: [
        if (vitals['bloodPressure'] != null) _buildVitalItem('BP', _formatVitalValue(vitals['bloodPressure']), Icons.favorite_rounded),
        if (vitals['heartRate'] != null) _buildVitalItem('Pulse', '${_formatVitalValue(vitals['heartRate'])} bpm', Icons.bolt_rounded),
        if (vitals['temperature'] != null) _buildVitalItem('Temp', '${_formatVitalValue(vitals['temperature'])}°C', Icons.thermostat_rounded),
        if (vitals['spO2'] != null) _buildVitalItem('SpO2', '${_formatVitalValue(vitals['spO2'])}%', Icons.air_rounded),
      ],
    );
  }

  String _formatVitalValue(dynamic value) {
    if (value == null) return '--';
    if (value is String) return value;
    if (value is Map) {
      if (value.containsKey('systolic') && value['diastolic'] != null) {
        return '${value['systolic']}/${value['diastolic']}';
      }
      if (value.containsKey('value')) return value['value'].toString();
      return value.toString();
    }
    return value.toString();
  }

  Widget _buildVitalItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF0D9488)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildObservationCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
      ),
    );
  }

  Widget _buildServicesList(List<dynamic> services) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: services.map((s) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF0D9488).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          s.toString(),
          style: const TextStyle(color: Color(0xFF0D9488), fontWeight: FontWeight.bold, fontSize: 12),
        ),
      )).toList(),
    );
  }

  Widget _buildFollowUpCard(Map<String, dynamic> followUp) {
    final urgency = followUp['urgency'] ?? 'normal';
    final color = urgency == 'emergency' ? Colors.red : Colors.orange;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_rounded, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                '${urgency.toUpperCase()} FOLLOW-UP',
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            followUp['instructions'] ?? 'Follow up as advised by your care provider.',
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, VisitReportPdfService pdfService) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => pdfService.share(record),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              side: const BorderSide(color: Color(0xFF0D9488)),
            ),
            icon: const Icon(Icons.share_rounded, size: 18, color: Color(0xFF0D9488)),
            label: const Text('Share', style: TextStyle(color: Color(0xFF0D9488), fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => pdfService.preview(record),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            icon: const Icon(Icons.download_rounded, size: 18),
            label: const Text('Download', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
