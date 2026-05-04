import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeNewsOffersCarousel extends StatelessWidget {
  const HomeNewsOffersCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF191919) : const Color(0xFFFDFDFD);
    final primaryTextColor = isDark ? const Color(0xFFFDFDFD) : const Color(0xFF232323);
    final secondaryTextColor = isDark ? const Color(0xFFA7A7A7) : const Color(0xFF555555);

    final offers = [
      {
        'title': '20% off General Checkups',
        'subtitle': 'Valid until end of month',
        'color': const Color(0xFF2ECC71).withAlpha(25),
        'icon': Icons.local_hospital,
        'iconColor': const Color(0xFF2ECC71),
      },
      {
        'title': 'Free Dietitian Consult',
        'subtitle': 'With premium subscription',
        'color': const Color(0xFF3498BB).withAlpha(25),
        'icon': Icons.restaurant_menu,
        'iconColor': const Color(0xFF3498BB),
      },
      {
        'title': 'Winter Flu Shots Available',
        'subtitle': 'Book home visit now',
        'color': const Color(0xFFFB8A00).withAlpha(25),
        'icon': Icons.vaccines,
        'iconColor': const Color(0xFFFB8A00),
      }
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Semantics(
              header: true,
              child: Text(
                'News & Offers',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: primaryTextColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              scrollDirection: Axis.horizontal,
              itemCount: offers.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final offer = offers[index];
                return Semantics(
                  button: true,
                  label: '${offer['title']}, ${offer['subtitle']}',
                  child: Container(
                    width: 280,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          (offer['iconColor'] as Color).withAlpha(isDark ? 200 : 255),
                          (offer['iconColor'] as Color).withAlpha(isDark ? 150 : 200),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: (offer['iconColor'] as Color).withAlpha(isDark ? 60 : 80),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Large watermark icon
                        Positioned(
                          right: -10,
                          bottom: -10,
                          child: Icon(
                            offer['icon'] as IconData,
                            size: 100,
                            color: Colors.white.withAlpha(isDark ? 20 : 40),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              HapticFeedback.lightImpact();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Offer: ${offer['title']} - Details coming soon')),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(40),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.white.withAlpha(50)),
                                    ),
                                    child: Icon(
                                      offer['icon'] as IconData,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          offer['title'] as String,
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          offer['subtitle'] as String,
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white.withAlpha(220),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
