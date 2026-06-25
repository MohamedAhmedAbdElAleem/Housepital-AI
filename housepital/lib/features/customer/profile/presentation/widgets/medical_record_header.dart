import 'package:flutter/material.dart';

class MedicalRecordHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback onSearch;

  const MedicalRecordHeader({
    super.key,
    required this.title,
    required this.onBack,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0D9488), // Teal 600
            Color(0xFF0F766E), // Teal 700
            Color(0xFF115E59), // Teal 800
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onBack,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onSearch,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.search_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
