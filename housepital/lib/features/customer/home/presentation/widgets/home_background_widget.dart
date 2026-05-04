import 'package:flutter/material.dart';

class HomeBackgroundWidget extends StatefulWidget {
  const HomeBackgroundWidget({super.key});

  @override
  State<HomeBackgroundWidget> createState() => _HomeBackgroundWidgetState();
}

class _HomeBackgroundWidgetState extends State<HomeBackgroundWidget> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // In dark mode, we use the theme's primary color but keep the opacity very low
    // so it doesn't wash out the dark background.
    final topBlobColor = theme.colorScheme.primary;
    final bottomBlobColor = theme.colorScheme.secondary;

    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            // Top right blob (Primary)
            Positioned(
              top: -120,
              right: -80,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, _) {
                  return Transform.scale(
                    scale: 1 + (_pulseController.value * 0.05),
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            topBlobColor.withAlpha(isDark ? 50 : 60), // Increased alpha
                            topBlobColor.withAlpha(0),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Top left blob (Secondary)
            Positioned(
              top: 50,
              left: -100,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      bottomBlobColor.withAlpha(isDark ? 40 : 45), // More color!
                      bottomBlobColor.withAlpha(0),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom accent
            Positioned(
              bottom: 150,
              right: -60, // Changed to right to balance
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      topBlobColor.withAlpha(isDark ? 30 : 35),
                      topBlobColor.withAlpha(0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
