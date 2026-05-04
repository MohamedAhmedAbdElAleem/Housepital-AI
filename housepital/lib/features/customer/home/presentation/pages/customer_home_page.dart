import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:housepital/features/notifications/presentation/pages/notifications_page.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/home_tab_view.dart';

import '../../../profile/presentation/pages/profile_page.dart';
import '../../../booking/presentation/pages/bookings_page.dart';
import '../../../../chatbot/presentation/pages/chatbot_page.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeTabView(
        onProfileTap: () => setState(() => _currentIndex = 4),
      ),
      const BookingsPage(),
      const ChatbotPage(),
      const NotificationsPage(),
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Theme.of(context).brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == _currentIndex) return;
            setState(() => _currentIndex = index);
          },
        ),
      ),
    );
  }
}
