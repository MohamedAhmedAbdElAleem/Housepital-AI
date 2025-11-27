import 'package:flutter/material.dart';
import '../../../services/presentation/pages/service_details_page.dart';
import '../pages/all_nursing_services_page.dart';

class PopularServicesGrid extends StatelessWidget {
  const PopularServicesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Popular Nursing Services',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AllNursingServicesPage(),
                  ),
                );
              },
              child: const Text(
                'View all',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF17C47F),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.85,
          children: [
            ServiceCard(
              icon: Icons.healing,
              iconColor: const Color(0xFFEF4444),
              title: 'Wound Care',
              price: '150 EGP',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ServiceDetailsPage(
                    title: 'Wound Care',
                    price: '150 EGP',
                    duration: '30-45 min',
                    icon: Icons.healing,
                    iconColor: Color(0xFFEF4444),
                    description: 'Professional wound care and dressing services provided by certified nurses. We ensure proper wound cleaning, medication application, and regular monitoring to promote faster healing and prevent infections.',
                    includes: [
                      'Professional wound assessment',
                      'Sterile dressing and bandaging',
                      'Wound cleaning and medication',
                      'Regular follow-up visits',
                      'Progress monitoring and reporting',
                    ],
                  ),
                ),
              ),
            ),
            ServiceCard(
              icon: Icons.medication_liquid,
              iconColor: const Color(0xFF3B82F6),
              title: 'Injections',
              price: '50 EGP',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ServiceDetailsPage(
                    title: 'Injections',
                    price: '50 EGP',
                    duration: '15-20 min',
                    icon: Icons.medication_liquid,
                    iconColor: Color(0xFF3B82F6),
                    description: 'Safe and painless injection services at your home. Our trained nurses administer all types of injections including IV, IM, and subcutaneous injections with proper sterilization and care.',
                    includes: [
                      'All types of injections (IV, IM, SC)',
                      'Proper sterilization',
                      'Medication administration',
                      'Post-injection care instructions',
                      'Emergency support if needed',
                    ],
                  ),
                ),
              ),
            ),
            ServiceCard(
              icon: Icons.elderly,
              iconColor: const Color(0xFF8B5CF6),
              title: 'Elderly Care',
              price: '200 EGP/hr',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ServiceDetailsPage(
                    title: 'Elderly Care',
                    price: '200 EGP/hr',
                    duration: '1-4 hours',
                    icon: Icons.elderly,
                    iconColor: Color(0xFF8B5CF6),
                    description: 'Comprehensive care for elderly patients including assistance with daily activities, medication management, vital signs monitoring, and companionship. Our nurses are specially trained in geriatric care.',
                    includes: [
                      'Daily activity assistance',
                      'Medication management',
                      'Vital signs monitoring',
                      'Personal hygiene care',
                      'Companionship and emotional support',
                    ],
                  ),
                ),
              ),
            ),
            ServiceCard(
              icon: Icons.monitor_heart,
              iconColor: const Color(0xFF10B981),
              title: 'Post-Op Care',
              price: '300 EGP',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ServiceDetailsPage(
                    title: 'Post-Op Care',
                    price: '300 EGP',
                    duration: '45-60 min',
                    icon: Icons.monitor_heart,
                    iconColor: Color(0xFF10B981),
                    description: 'Post-operative care services to ensure smooth recovery after surgery. Includes wound care, medication administration, pain management, and monitoring for complications.',
                    includes: [
                      'Surgical wound care',
                      'Pain management',
                      'Medication administration',
                      'Vital signs monitoring',
                      'Complication detection and reporting',
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ServiceCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String price;
  final VoidCallback? onTap;

  const ServiceCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.price,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
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
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
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
              price,
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
  }
}
