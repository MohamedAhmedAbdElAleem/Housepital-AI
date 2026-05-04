import 'package:flutter/material.dart';

class BookingsTypeFilter extends StatelessWidget {
  final int selectedType;
  final ValueChanged<int> onTypeChanged;

  const BookingsTypeFilter({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    const types = [
      ('الكل', Icons.apps_rounded),
      ('تمريض', Icons.medical_services_rounded),
      ('عيادة', Icons.local_hospital_rounded),
    ];

    // Jewel-toned gradient definitions for each filter
    const gradients = [
      [Color(0xFF2ECC71), Color(0xFF219150)],    // Healing green
      [Color(0xFF2ECC71), Color(0xFF219150)],    // Nursing green
      [Color(0xFF3498BB), Color(0xFF256C85)],    // Clinic blue
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: List.generate(types.length, (i) {
          final selected = selectedType == i;
          final (label, icon) = types[i];
          final gradientColors = gradients[i];

          return Expanded(
            child: GestureDetector(
              onTap: () => onTypeChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: selected
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: gradientColors,
                        )
                      : null,
                  color: selected ? null : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: selected
                      ? null
                      : Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: gradientColors[0].withAlpha(80),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: selected ? Colors.white : const Color(0xFF94A3B8),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color:
                            selected ? Colors.white : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
