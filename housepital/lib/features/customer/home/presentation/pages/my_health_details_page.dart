import 'package:flutter/material.dart';

class MyHealthDetailsPage extends StatelessWidget {
  const MyHealthDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
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
          'My Health Schedule',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader('Medications', Icons.medication),
          const SizedBox(height: 12),
          _buildHealthItem(
            icon: Icons.medication,
            iconColor: const Color(0xFF8B5CF6),
            title: 'Metformin',
            subtitle: '500mg - After dinner',
            time: '8:00 PM',
            status: 'Pending',
          ),
          const SizedBox(height: 12),
          _buildHealthItem(
            icon: Icons.medication,
            iconColor: const Color(0xFF8B5CF6),
            title: 'Aspirin',
            subtitle: '100mg - After breakfast',
            time: '9:00 AM',
            status: 'Completed',
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Appointments', Icons.calendar_today),
          const SizedBox(height: 12),
          _buildHealthItem(
            icon: Icons.calendar_today,
            iconColor: const Color(0xFF3B82F6),
            title: 'Dermatology Checkup',
            subtitle: 'Dr. Sarah Ahmed',
            time: 'Tomorrow, 10:00 AM',
            status: 'Upcoming',
          ),
          const SizedBox(height: 12),
          _buildHealthItem(
            icon: Icons.calendar_today,
            iconColor: const Color(0xFF3B82F6),
            title: 'General Checkup',
            subtitle: 'Dr. Mohamed Ali',
            time: 'Dec 1, 2:00 PM',
            status: 'Upcoming',
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Vital Signs', Icons.monitor_heart),
          const SizedBox(height: 12),
          _buildHealthItem(
            icon: Icons.monitor_heart,
            iconColor: const Color(0xFFEF4444),
            title: 'Blood Pressure',
            subtitle: 'Last recorded today',
            time: '120/80 mmHg',
            status: 'Normal',
          ),
          const SizedBox(height: 12),
          _buildHealthItem(
            icon: Icons.thermostat,
            iconColor: const Color(0xFFF59E0B),
            title: 'Body Temperature',
            subtitle: 'Last recorded today',
            time: '36.8°C',
            status: 'Normal',
          ),
          const SizedBox(height: 12),
          _buildHealthItem(
            icon: Icons.favorite,
            iconColor: const Color(0xFFEC4899),
            title: 'Heart Rate',
            subtitle: 'Last recorded today',
            time: '72 bpm',
            status: 'Normal',
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Exercises', Icons.fitness_center),
          const SizedBox(height: 12),
          _buildHealthItem(
            icon: Icons.directions_walk,
            iconColor: const Color(0xFF10B981),
            title: 'Morning Walk',
            subtitle: '30 minutes',
            time: '6:00 AM',
            status: 'Completed',
          ),
          const SizedBox(height: 12),
          _buildHealthItem(
            icon: Icons.fitness_center,
            iconColor: const Color(0xFF10B981),
            title: 'Yoga Session',
            subtitle: '20 minutes',
            time: '5:00 PM',
            status: 'Pending',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF17C47F),
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
    required String status,
  }) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'completed':
        statusColor = const Color(0xFF10B981);
        break;
      case 'pending':
        statusColor = const Color(0xFFF59E0B);
        break;
      case 'upcoming':
        statusColor = const Color(0xFF3B82F6);
        break;
      default:
        statusColor = const Color(0xFF64748B);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
