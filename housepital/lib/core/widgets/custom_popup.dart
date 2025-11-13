import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum PopupType { success, error, warning, info }

class CustomPopup {
  static void show(
    BuildContext context, {
    required String message,
    required PopupType type,
  }) {
    final config = _PopupConfig.getConfig(type);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: config.backgroundColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    config.icon,
                    color: config.backgroundColor,
                    size: 45,
                  ),
                ),

                const SizedBox(height: 20),

                // Title (Warning, Error, Success, Info)
                Text(
                  config.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: config.backgroundColor,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Message
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 28),

                // Confirm Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: config.backgroundColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void success(BuildContext context, String message) {
    show(context, message: message, type: PopupType.success);
  }

  static void error(BuildContext context, String message) {
    show(context, message: message, type: PopupType.error);
  }

  static void warning(BuildContext context, String message) {
    show(context, message: message, type: PopupType.warning);
  }

  static void info(BuildContext context, String message) {
    show(context, message: message, type: PopupType.info);
  }
}

class _PopupConfig {
  final Color backgroundColor;
  final IconData icon;
  final String title;

  _PopupConfig({
    required this.backgroundColor,
    required this.icon,
    required this.title,
  });

  static _PopupConfig getConfig(PopupType type) {
    switch (type) {
      case PopupType.success:
        return _PopupConfig(
          backgroundColor: AppColors.success500,
          icon: Icons.check_circle_rounded,
          title: 'Success',
        );
      case PopupType.error:
        return _PopupConfig(
          backgroundColor: AppColors.error500,
          icon: Icons.error_rounded,
          title: 'Error',
        );
      case PopupType.warning:
        return _PopupConfig(
          backgroundColor: AppColors.warning500,
          icon: Icons.warning_rounded,
          title: 'Warning',
        );
      case PopupType.info:
        return _PopupConfig(
          backgroundColor: AppColors.info,
          icon: Icons.info_rounded,
          title: 'Info',
        );
    }
  }
}
