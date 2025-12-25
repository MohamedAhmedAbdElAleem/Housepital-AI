import 'package:flutter/material.dart';

class ServiceTabs extends StatelessWidget {
  final String selectedTab;
  final Function(String) onTabChanged;

  const ServiceTabs({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              title: 'Home Nursing',
              isSelected: selectedTab == 'Home Nursing',
              onTap: () => onTabChanged('Home Nursing'),
            ),
          ),
          Expanded(
            child: _TabButton(
              title: 'Clinics',
              isSelected: selectedTab == 'Clinics',
              onTap: () => onTabChanged('Clinics'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD1FAE5) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? const Color(0xFF059669) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}
