import 'package:flutter/material.dart';
import '../../../services/presentation/pages/service_details_page.dart';

class AllNursingServicesPage extends StatelessWidget {
  const AllNursingServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final services = [
      _ServiceData(
        '1', 'Wound Care', '150 EGP', '30-45 min', Icons.healing, const Color(0xFFEF4444),
        'Professional wound care and dressing services provided by certified nurses. We ensure proper wound cleaning, medication application, and regular monitoring to promote faster healing and prevent infections.',
        ['Professional wound assessment', 'Sterile dressing and bandaging', 'Wound cleaning and medication', 'Regular follow-up visits', 'Progress monitoring and reporting'],
      ),
      _ServiceData(
        '2', 'Injections', '50 EGP', '15-20 min', Icons.medication_liquid, const Color(0xFF3B82F6),
        'Safe and painless injection services at your home. Our trained nurses administer all types of injections including IV, IM, and subcutaneous injections with proper sterilization and care.',
        ['All types of injections (IV, IM, SC)', 'Proper sterilization', 'Medication administration', 'Post-injection care instructions', 'Emergency support if needed'],
      ),
      _ServiceData(
        '3', 'Elderly Care', '200 EGP/hr', '1-4 hours', Icons.elderly, const Color(0xFF8B5CF6),
        'Comprehensive care for elderly patients including assistance with daily activities, medication management, vital signs monitoring, and companionship. Our nurses are specially trained in geriatric care.',
        ['Daily activity assistance', 'Medication management', 'Vital signs monitoring', 'Personal hygiene care', 'Companionship and emotional support'],
      ),
      _ServiceData(
        '4', 'Post-Op Care', '300 EGP', '45-60 min', Icons.monitor_heart, const Color(0xFF10B981),
        'Post-operative care services to ensure smooth recovery after surgery. Includes wound care, medication administration, pain management, and monitoring for complications.',
        ['Surgical wound care', 'Pain management', 'Medication administration', 'Vital signs monitoring', 'Complication detection and reporting'],
      ),
      _ServiceData(
        '5', 'Baby Care', '180 EGP/hr', '2-3 hours', Icons.baby_changing_station, const Color(0xFFF59E0B),
        'Professional newborn and infant care services including feeding, bathing, monitoring, and health assessments by trained pediatric nurses.',
        ['Newborn care and monitoring', 'Feeding assistance', 'Bathing and hygiene', 'Development assessment', 'Parent education and support'],
      ),
      _ServiceData(
        '6', 'IV Therapy', '250 EGP', '45-60 min', Icons.local_hospital, const Color(0xFFEC4899),
        'Intravenous fluid and medication therapy administered safely at home by certified nurses.',
        ['IV line insertion', 'Medication administration', 'Fluid therapy', 'Vital signs monitoring', 'Complication prevention'],
      ),
      _ServiceData(
        '7', 'Catheter Care', '120 EGP', '30-40 min', Icons.medical_services, const Color(0xFF06B6D4),
        'Professional catheter insertion, maintenance, and care services ensuring comfort and preventing infections.',
        ['Catheter insertion', 'Regular maintenance', 'Infection prevention', 'Patient education', 'Emergency support'],
      ),
      _ServiceData(
        '8', 'Vital Signs Check', '80 EGP', '20-30 min', Icons.monitor_weight, const Color(0xFF84CC16),
        'Complete vital signs monitoring including blood pressure, temperature, heart rate, and oxygen levels with detailed reporting.',
        ['Blood pressure measurement', 'Temperature check', 'Heart rate monitoring', 'Oxygen saturation', 'Detailed health report'],
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF17C47F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'All Nursing Services',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ServiceDetailsPage(
                    title: service.title,
                    price: service.price,
                    duration: service.duration,
                    icon: service.icon,
                    iconColor: service.iconColor,
                    description: service.description,
                    includes: service.includes,
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: service.iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      service.icon,
                      color: service.iconColor,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    service.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      service.price,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF059669),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ServiceData {
  final String id;
  final String title;
  final String price;
  final String duration;
  final IconData icon;
  final Color iconColor;
  final String description;
  final List<String> includes;

  _ServiceData(this.id, this.title, this.price, this.duration, this.icon, this.iconColor, this.description, this.includes);
}
