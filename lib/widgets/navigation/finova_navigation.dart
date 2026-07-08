import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class FinovaNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;
  final VoidCallback onAdd;

  const FinovaNavigation({
    super.key,
    required this.currentIndex,
    required this.onChanged,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Total width of the floating navigation bar
    final navWidth = size.width - 32; // 16 margin on each side

    // We have 5 slots: Home (0), Wallets (1), FAB (2 - spacer), Analytics (3), Profile (4)
    final slotWidth = navWidth / 5;

    // Map selected index (0 to 3) to slot index (0, 1, 3, 4)
    int getSlotIndex(int index) {
      if (index >= 2) return index + 1;
      return index;
    }

    final activeSlotIndex = getSlotIndex(currentIndex);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding > 0 ? 4 : 12),
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            // The Glassmorphic bar
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  height: 76,
                  width: navWidth,
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode
                        ? const Color(0xE60D0C1D) // Dark purple translucent
                        : Colors.white.withOpacity(0.85), // Light glass translucent
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: themeProvider.isDarkMode
                          ? Colors.white.withOpacity(0.08)
                          : Colors.black.withOpacity(0.06),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: themeProvider.isDarkMode
                            ? Colors.black.withOpacity(0.3)
                            : Colors.black.withOpacity(0.06),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Sliding Active Pill Indicator (positioned at the bottom of the slot)
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutBack,
                        left: activeSlotIndex * slotWidth + (slotWidth - 24) / 2,
                        bottom: 8,
                        child: Container(
                          width: 24,
                          height: 4,
                          decoration: BoxDecoration(
                            color: themeProvider.primaryColor,
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: themeProvider.primaryColor.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Tabs Row
                      Row(
                        children: [
                          // Home
                          Expanded(
                            child: _NavItemButton(
                              icon: Icons.home_rounded,
                              label: "Home",
                              isSelected: currentIndex == 0,
                              onTap: () => onChanged(0),
                              activeColor: themeProvider.primaryColor,
                            ),
                          ),
                          // Wallets
                          Expanded(
                            child: _NavItemButton(
                              icon: Icons.account_balance_wallet_rounded,
                              label: "Wallets",
                              isSelected: currentIndex == 1,
                              onTap: () => onChanged(1),
                              activeColor: themeProvider.primaryColor,
                            ),
                          ),
                          // Spacer for FAB (will overlay on top)
                          const Expanded(
                            child: SizedBox.shrink(),
                          ),
                          // Analytics
                          Expanded(
                            child: _NavItemButton(
                              icon: Icons.bar_chart_rounded,
                              label: "Analytics",
                              isSelected: currentIndex == 2,
                              onTap: () => onChanged(2),
                              activeColor: themeProvider.primaryColor,
                            ),
                          ),
                          // Profile
                          Expanded(
                            child: _NavItemButton(
                              icon: Icons.person_rounded,
                              label: "Profile",
                              isSelected: currentIndex == 3,
                              onTap: () => onChanged(3),
                              activeColor: themeProvider.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Central Floating Action Button (FAB)
            Positioned(
              top: -24, // Float up by 24 pixels
              child: GestureDetector(
                onTap: onAdd,
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        themeProvider.primaryColor,
                        themeProvider.primaryColor.withOpacity(0.8),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: themeProvider.primaryColor.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                        spreadRadius: 2,
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    size: 34,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItemButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;

  const _NavItemButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.only(bottom: 2),
            child: Icon(
              icon,
              size: isSelected ? 26 : 24,
              color: isSelected
                  ? activeColor
                  : (Provider.of<ThemeProvider>(context).isDarkMode
                      ? Colors.grey.shade400
                      : Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 2),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? activeColor
                  : (Provider.of<ThemeProvider>(context).isDarkMode
                      ? Colors.grey.shade400
                      : Colors.grey.shade600),
              fontFamily: 'Outfit',
            ),
            child: Text(label),
          ),
          const SizedBox(height: 4), // extra buffer for indicator space
        ],
      ),
    );
  }
}
