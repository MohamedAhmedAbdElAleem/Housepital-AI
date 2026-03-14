import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/providers/notification_provider.dart';
import '../../../../notifications/presentation/pages/notifications_page.dart';

class NurseHomePage extends StatelessWidget {
  const NurseHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2ECC71),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Nurse Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              final count = provider.unreadCount;
              return IconButton(
                icon: Badge(
                  isLabelVisible: count > 0,
                  label: Text(count > 9 ? '9+' : count.toString()),
                  child: const Icon(Icons.notifications_outlined),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => ChangeNotifierProvider.value(
                            value: provider,
                            child: const NotificationsPage(),
                          ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_services_rounded,
              size: 80,
              color: Color(0xFF2ECC71),
            ),
            SizedBox(height: 24),
            Text(
              'Nurse Home Page',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Coming Soon',
              style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}
