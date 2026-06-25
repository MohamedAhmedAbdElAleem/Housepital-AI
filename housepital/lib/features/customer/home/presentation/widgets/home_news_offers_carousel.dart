import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../generated/l10n/app_localizations.dart';

class HomeNewsOffersCarousel extends StatelessWidget {
  const HomeNewsOffersCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final offers = [
      {
        'title': l10n.offer1Title,
        'subtitle': l10n.offer1Subtitle,
        'icon': Icons.percent_rounded,
        'color': const Color(0xFF667eea),
      },
      {
        'title': l10n.offer2Title,
        'subtitle': l10n.offer2Subtitle,
        'icon': Icons.restaurant_menu_rounded,
        'color': const Color(0xFF764ba2),
      },
      {
        'title': l10n.offer3Title,
        'subtitle': l10n.offer3Subtitle,
        'icon': Icons.vaccines_rounded,
        'color': const Color(0xFF2ECC71),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.newsAndOffers,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 20,
                  color: Color(0xFF667eea),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 160,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: offers.length,
            itemBuilder: (context, index) {
              final offer = offers[index];
              final color = offer['color'] as Color;

              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.05),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Icon(
                        offer['icon'] as IconData,
                        size: 100,
                        color: color.withOpacity(0.05),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              offer['icon'] as IconData,
                              color: color,
                              size: 20,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            offer['title'] as String,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            offer['subtitle'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.grey[400] : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                l10n.offerDetailsSnack(offer['title'] as String),
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
