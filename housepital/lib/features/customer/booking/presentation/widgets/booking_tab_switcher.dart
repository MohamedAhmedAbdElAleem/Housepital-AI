import 'package:flutter/material.dart';

class BookingTabSwitcher extends StatelessWidget {
  final int activeTab; // 0 = Active & Upcoming, 1 = History
  final Function(int) onTabChanged;

  const BookingTabSwitcher({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1C24) : const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(12),
        border: isDark ? Border.all(color: Colors.white.withAlpha(10)) : null,
      ),
      child: Row(
        children: [_buildTab(0, 'Active & Upcoming', isDark), _buildTab(1, 'History', isDark)],
      ),
    );
  }

  Widget _buildTab(int tabIndex, String label, bool isDark) {
    final isActive = activeTab == tabIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTabChanged(tabIndex),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive
                ? (isDark ? const Color(0xFF2A2831) : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive && !isDark
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive
                  ? (isDark ? const Color(0xFFF2F2F5) : const Color(0xFF1E293B))
                  : (isDark ? const Color(0xFF5F5C68) : const Color(0xFF6B7280)),
            ),
          ),
        ),
      ),
    );
  }
}
