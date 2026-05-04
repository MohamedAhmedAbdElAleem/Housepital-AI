import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NursingServicesSearch extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final Function(String) onChanged;
  final VoidCallback onClear;

  const NursingServicesSearch({
    super.key,
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF2ECC71);
    const textPrimary = Color(0xFF1A202C);
    const textMuted = Color(0xFFA0AEC0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withAlpha(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(fontFamily: 'Inter', fontSize: 15, color: textPrimary),
        decoration: InputDecoration(
          hintText: 'Search for services...',
          hintStyle: const TextStyle(fontFamily: 'Inter', color: textMuted, fontSize: 15),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primary.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.search_rounded,
                color: primary,
                size: 20,
              ),
            ),
          ),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: textMuted.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: textMuted,
                      size: 16,
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onClear();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
