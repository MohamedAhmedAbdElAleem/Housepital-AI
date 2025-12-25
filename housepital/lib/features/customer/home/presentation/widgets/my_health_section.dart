import 'package:flutter/material.dart';
import '../pages/my_health_details_page.dart';

class MyHealthSection extends StatelessWidget {
  const MyHealthSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.favorite,
              color: Color(0xFFEF4444),
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'My Health',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyHealthDetailsPage(),
                  ),
                );
              },
              child: const Text(
                'View All',
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
        SizedBox(
          height: 130,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: const [
              HealthCard(
                icon: Icons.medication,
                iconColor: Color(0xFF8B5CF6),
                title: 'Take Metformin',
                subtitle: 'Now - 8:00 PM',
                status: 'Due Now',
              ),
              SizedBox(width: 12),
              HealthCard(
                icon: Icons.monitor_heart,
                iconColor: Color(0xFFEF4444),
                title: 'Check Blood Pressure',
                subtitle: 'Due at 6:00 PM',
                status: 'Upcoming',
              ),
              SizedBox(width: 12),
              HealthCard(
                icon: Icons.local_drink,
                iconColor: Color(0xFF3B82F6),
                title: 'Drink Water',
                subtitle: 'Every 2 hours',
                status: 'Ongoing',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class HealthCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String status;

  const HealthCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'due now':
        statusColor = const Color(0xFFEF4444);
        break;
      case 'upcoming':
        statusColor = const Color(0xFFF59E0B);
        break;
      case 'ongoing':
        statusColor = const Color(0xFF3B82F6);
        break;
      default:
        statusColor = const Color(0xFF64748B);
    }

    return Container(
      width: 180,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
