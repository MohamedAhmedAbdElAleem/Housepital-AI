import 'package:flutter/material.dart';
import '../../../../../generated/l10n/app_localizations.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    final types = [
      (l10n.filterAll, Icons.apps_rounded),
      (l10n.filterNursing, Icons.medical_services_rounded),
      (l10n.filterClinic, Icons.local_hospital_rounded),
    ];

    // Jewel-toned gradient definitions for each filter
    const gradients = [
      [Color(0xFF2ECC71), Color(0xFF219150)],    // Healing green
      [Color(0xFF2ECC71), Color(0xFF219150)],    // Nursing green
      [Color(0xFF3498BB), Color(0xFF256C85)],    // Clinic blue
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
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
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: selected
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: gradientColors,
                        )
                      : null,
                  color: selected ? null : (isDark ? Colors.white.withAlpha(15) : Colors.white),
                  borderRadius: BorderRadius.circular(14),
                  border: selected
                      ? null
                      : Border.all(
                          color: isDark ? Colors.white.withAlpha(15) : const Color(0xFFE2E8F0),
                        ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                             color: gradientColors[0].withAlpha(isDark ? 40 : 80),
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
                      color: selected ? Colors.white : (isDark ? Colors.white54 : const Color(0xFF94A3B8)),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? Colors.white
                            : (isDark ? Colors.white70 : const Color(0xFF64748B)),
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
