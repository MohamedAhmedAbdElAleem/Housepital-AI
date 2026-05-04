import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ChatbotQuickActions extends StatelessWidget {
  final Function(String, IconData) onActionTap;
  final VoidCallback onImageActionTap;

  const ChatbotQuickActions({
    super.key,
    required this.onActionTap,
    required this.onImageActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final actions = [
      ('🩹 عندي جرح', Icons.healing_rounded),
      ('💉 محتاج حقنة', Icons.medication_rounded),
      ('👴 رعاية كبار', Icons.elderly_rounded),
      ('📷 ابعت صورة', Icons.camera_alt_rounded),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        child: Row(
          children:
              actions.map((action) {
                final isCamera = action.$2 == Icons.camera_alt_rounded;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      if (isCamera) {
                        onImageActionTap();
                      } else {
                        onActionTap(action.$1, action.$2);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isCamera
                                ? const Color(0xFF667EEA).withAlpha(40)
                                : (isDark
                                    ? const Color(0xFF191919)
                                    : const Color(0xFFFDFDFD)),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color:
                              isCamera
                                  ? const Color(0xFF667EEA)
                                  : const Color(0xFF667EEA).withAlpha(50),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(isCamera ? 20 : 10),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            action.$2,
                            size: 20,
                            color:
                                isCamera
                                    ? const Color(0xFF667EEA)
                                    : (isDark
                                        ? AppColors.light50
                                        : AppColors.dark500),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            action.$1,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color:
                                  isCamera
                                      ? const Color(0xFF667EEA)
                                      : (isDark
                                          ? AppColors.light50
                                          : AppColors.dark500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}
