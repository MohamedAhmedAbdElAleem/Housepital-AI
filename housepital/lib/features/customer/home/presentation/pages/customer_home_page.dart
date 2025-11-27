import 'package:flutter/material.dart';
import '../widgets/location_header.dart';
import '../widgets/greeting_search_card.dart';
import '../widgets/ai_assistant_card.dart';
import '../widgets/premium_card.dart';
import '../widgets/my_health_section.dart';
import '../widgets/service_tabs.dart';
import '../widgets/popular_services_grid.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  int _currentIndex = 0;
  String _selectedTab = 'Home Nursing';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      // -------------------------------
      // ⭐ All content inside one ScrollView
      // -------------------------------
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // -------------------------------
            // 🌿 Green Header Section
            // -------------------------------
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF17C47F), Color(0xFF14B374)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    children: const [
                      LocationHeader(),
                      SizedBox(height: 20),
                      GreetingSearchCard(),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // -------------------------------
            // 🤖 AI Assistant Card
            // -------------------------------
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: AIAssistantCard(),
            ),

            const SizedBox(height: 16),

            // -------------------------------
            // ⭐ Premium Plan Card
            // -------------------------------
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: PremiumCard(),
            ),

            const SizedBox(height: 24),

            // -------------------------------
            // ❤️ My Health
            // -------------------------------
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: MyHealthSection(),
            ),

            const SizedBox(height: 24),

            // -------------------------------
            // 🔄 Service Tabs (Home Nursing / Clinics)
            // -------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ServiceTabs(
                selectedTab: _selectedTab,
                onTabChanged: (tab) {
                  setState(() {
                    _selectedTab = tab;
                  });
                },
              ),
            ),

            const SizedBox(height: 20),

            // -------------------------------
            // 🏥 Popular Services Grid
            // -------------------------------
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: PopularServicesGrid(),
            ),

            const SizedBox(height: 100), // space for bottom nav bar
          ],
        ),
      ),

      // -------------------------------
      // 📱 Bottom Navigation Bar
      // -------------------------------
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
