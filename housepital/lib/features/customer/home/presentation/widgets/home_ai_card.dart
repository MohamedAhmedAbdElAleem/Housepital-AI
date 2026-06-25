import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../chatbot/presentation/pages/chatbot_page.dart';
import '../../../../../generated/l10n/app_localizations.dart';

class HomeAICard extends StatefulWidget {
  const HomeAICard({super.key});

  @override
  State<HomeAICard> createState() => _HomeAICardState();
}

class _HomeAICardState extends State<HomeAICard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.heavyImpact();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatbotPage()),
          );
        },
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF2A1B4E), // Deep Cyber Violet
                      const Color(0xFF130B26),
                    ]
                  : [
                      const Color(0xFF7C3AED), // Premium Violet
                      const Color(0xFF5B21B6),
                    ],
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? const Color(0xFF7C3AED) : const Color(0xFF5B21B6))
                    .withAlpha(isDark ? 30 : 70),
                blurRadius: 24,
                spreadRadius: 1,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: Colors.white.withAlpha(isDark ? 10 : 20),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // Rotating psychology background watermark
              Positioned(
                right: -30,
                top: -30,
                child: RotationTransition(
                  turns: _controller,
                  child: Icon(
                    Icons.psychology_rounded,
                    size: 170,
                    color: Colors.white.withAlpha(isDark ? 4 : 8),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Row(
                  children: [
                    // Icon Container
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(isDark ? 12 : 20),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withAlpha(isDark ? 15 : 30),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.psychology_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Text details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Text(
                                l10n.aiHealthAssistant,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444), // Vibrant Red
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  l10n.newLabel,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.aiAdviceSubtitle,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: Colors.white.withAlpha(180),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Action arrow button
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(isDark ? 10 : 20),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withAlpha(isDark ? 8 : 15),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
