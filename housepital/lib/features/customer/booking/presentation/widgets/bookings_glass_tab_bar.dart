import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../../generated/l10n/app_localizations.dart';

class BookingsGlassTabBar extends StatelessWidget {
  final int selectedTab;
  final int activeCount;
  final ValueChanged<int> onTabChanged;

  const BookingsGlassTabBar({
    super.key,
    required this.selectedTab,
    required this.activeCount,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withAlpha(60) : Colors.white.withAlpha(160),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? Colors.white.withAlpha(10) : Colors.white.withAlpha(200),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isDark ? 20 : 10),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildTab(context, 0, l10n.tabActive, Icons.flash_on_rounded, isDark),
                _buildTab(context, 1, l10n.tabHistory, Icons.history_rounded, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, int index, String label, IconData icon, bool isDark) {
    final isSelected = selectedTab == index;

    final selectedGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [const Color(0xFF1E3C40), const Color(0xFF112224)]
          : [const Color(0xFF26B09B), const Color(0xFF1D8F7D)],
    );

    return Expanded(
      child: GestureDetector(
        onTap: () => onTabChanged(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: isSelected ? selectedGradient : null,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: (isDark ? const Color(0xFF1E3C40) : const Color(0xFF26B09B))
                          .withAlpha(isDark ? 40 : 80),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
            border: isSelected
                ? Border.all(
                    color: Colors.white.withAlpha(isDark ? 10 : 25),
                    width: 1,
                  )
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white54 : const Color(0xFF94A3B8)),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white54 : const Color(0xFF94A3B8)),
                ),
              ),
              if (index == 0 && activeCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withAlpha(50)
                        : (isDark ? const Color(0xFF1E3C40) : const Color(0xFF26B09B)),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withAlpha(isSelected ? 30 : 0),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '$activeCount',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
