import 'package:flutter/material.dart';
import 'dart:ui';

class ChatbotInputArea extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onSubmitted;
  final VoidCallback onImagePick;
  final bool isAnalyzing;

  const ChatbotInputArea({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
    required this.onImagePick,
    this.isAnalyzing = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF9F9F9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Camera Button (Glassmorphic)
          GestureDetector(
            onTap: isAnalyzing ? null : onImagePick,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color:
                        isAnalyzing
                            ? Colors.grey[200]
                            : const Color(0xFF667EEA).withAlpha(30),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          isAnalyzing
                              ? Colors.grey[300]!
                              : const Color(0xFF667EEA).withAlpha(50),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: isAnalyzing ? Colors.grey : const Color(0xFF667EEA),
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Input Field
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF191919) : const Color(0xFFFDFDFD),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color:
                      isDark
                          ? Colors.white.withAlpha(10)
                          : Colors.black.withAlpha(5),
                ),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color:
                      isDark
                          ? const Color(0xFFFDFDFD)
                          : const Color(0xFF232323),
                ),
                decoration: InputDecoration(
                  hintText: 'Ask me anything...',
                  hintStyle: TextStyle(
                    color:
                        isDark
                            ? const Color(0xFFA7A7A7)
                            : const Color(0xFF9CA3AF),
                    fontFamily: 'Inter',
                  ),
                  hintTextDirection: TextDirection.rtl,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
                onSubmitted: onSubmitted,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Send Button
          GestureDetector(
            onTap: () => onSubmitted(controller.text),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF764BA2).withAlpha(60),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
