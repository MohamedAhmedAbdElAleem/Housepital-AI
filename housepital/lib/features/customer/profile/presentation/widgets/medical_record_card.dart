import 'package:flutter/material.dart';

class MedicalRecordCard extends StatelessWidget {
  final Map<String, dynamic> record;
  final VoidCallback onTap;

  const MedicalRecordCard({
    super.key,
    required this.record,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final booking = record['bookingId'] ?? {};
    final serviceName = booking['serviceName'] ?? 'General Visit';
    final nurse = record['nurseId']?['user']?['name'] ?? 'Care Provider';
    final date = record['createdAt'] != null 
        ? DateTime.parse(record['createdAt']) 
        : DateTime.now();
    
    final type = _getRecordType(serviceName);
    final color = _getTypeColor(type);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _getTypeIcon(type),
                color: color,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    serviceName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nurse,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(date),
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  String _getRecordType(String name) {
    name = name.toLowerCase();
    if (name.contains('lab') || name.contains('test')) return 'lab';
    if (name.contains('rx') || name.contains('prescription')) return 'rx';
    return 'visit';
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'lab': return const Color(0xFF7C3AED);
      case 'rx': return const Color(0xFF3B82F6);
      default: return const Color(0xFF0D9488);
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'lab': return Icons.science_rounded;
      case 'rx': return Icons.medication_rounded;
      default: return Icons.medical_services_rounded;
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }
}
