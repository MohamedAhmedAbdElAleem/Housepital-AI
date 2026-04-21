class BookingUtils {
  static String normalizeStatus(dynamic value) {
    final raw = (value ?? '').toString().trim().toLowerCase();

    switch (raw) {
      case 'on_the_way':
        return 'on-the-way';
      case 'in_progress':
        return 'in-progress';
      case 'no_show':
        return 'no-show';
      case 'accepted':
        return 'confirmed';
      default:
        return raw;
    }
  }

  static String formatScheduledTime(String? dateStr) {
    if (dateStr == null) return 'ASAP';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day + 1);

      String dayStr;
      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        dayStr = 'Today';
      } else if (date.year == tomorrow.year &&
          date.month == tomorrow.month &&
          date.day == tomorrow.day) {
        dayStr = 'Tomorrow';
      } else {
        final months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        dayStr = '${date.day} ${months[date.month - 1]}';
      }

      final hour =
          date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
      final period = date.hour >= 12 ? 'PM' : 'AM';
      final minute = date.minute.toString().padLeft(2, '0');

      return '$dayStr, $hour:$minute $period';
    } catch (e) {
      return dateStr;
    }
  }

  static bool isLateCancel(String status) {
    final normalized = normalizeStatus(status);
    return normalized == 'confirmed' ||
        normalized == 'clinic_confirmed' ||
        normalized == 'nurse_waiting' ||
        normalized == 'assigned' ||
        normalized == 'on-the-way' ||
        normalized == 'arrived' ||
        normalized == 'in-progress';
  }

  static List<String> get activeStatuses => [
        'pending',
        'searching',
      'offers_pending',
      'nurse_accepted',
        'confirmed',
        'assigned',
        'on-the-way',
        'arrived',
        'in-progress',
        'nurse_waiting',
        'nurse_emergency',
        'clinic_confirmed',
      ];

  static List<String> get historyStatuses => ['completed', 'cancelled', 'no-show'];

  static bool isTrackableStatus(String status) {
    final normalized = normalizeStatus(status);
    return normalized == 'confirmed' ||
        normalized == 'assigned' ||
        normalized == 'on-the-way' ||
        normalized == 'arrived' ||
        normalized == 'in-progress';
  }
}
