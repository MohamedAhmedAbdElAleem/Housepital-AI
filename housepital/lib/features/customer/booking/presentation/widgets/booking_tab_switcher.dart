import 'package:flutter/material.dart';

class BookingTabSwitcher extends StatelessWidget {
  final int activeTab; // 0 = Active & Upcoming, 1 = History
  final Function(int) onTabChanged;

  const BookingTabSwitcher({
    Key? key,
    required this.activeTab,
    required this.onTabChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [_buildTab(0, 'Active & Upcoming'), _buildTab(1, 'History')],
      ),
    );
  }

  Widget _buildTab(int tabIndex, String label) {
    final isActive = activeTab == tabIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTabChanged(tabIndex),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow:
                isActive
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
              color:
                  isActive ? const Color(0xFF1E293B) : const Color(0xFF6B7280),
            ),
          ),
        ),
      ),
    );
  }
}
