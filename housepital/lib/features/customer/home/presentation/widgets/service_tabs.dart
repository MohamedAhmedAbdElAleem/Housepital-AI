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
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEF4),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              title: 'Home Nursing',
              icon: Icons.home_rounded,
              isSelected: selectedTab == 'Home Nursing',
              onTap: () => onTabChanged('Home Nursing'),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _TabButton(
              title: 'Clinics',
              icon: Icons.local_hospital_rounded,
              isSelected: selectedTab == 'Clinics',
              onTap: () => onTabChanged('Clinics'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatefulWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_TabButton> createState() => _TabButtonState();
}

class _TabButtonState extends State<_TabButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: widget.isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            boxShadow:
                widget.isSelected
                    ? [
                      BoxShadow(
                        color: const Color(0xFF00D47F).withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                child: Icon(
                  widget.icon,
                  size: 18,
                  color:
                      widget.isSelected
                          ? const Color(0xFF00B870)
                          : const Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                  color:
                      widget.isSelected
                          ? const Color(0xFF00B870)
                          : const Color(0xFF64748B),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
