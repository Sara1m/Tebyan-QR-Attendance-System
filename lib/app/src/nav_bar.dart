import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import 'colors.dart';

class NavItem {
  const NavItem(this.icon, this.text);
  final IconData icon;
  final String text;
}

/// Floating bottom navigation bar.
class AppNavBar extends StatelessWidget {
  const AppNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChange,
    required this.items,
  });

  final int selectedIndex;
  final ValueChanged<int> onTabChange;
  final List<NavItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 4, 16, 14),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primaryColor.withOpacity(.12),
                      blurRadius: 24,
                      offset: const Offset(0, 8))
                ],
              ),
              child: GNav(
                selectedIndex: selectedIndex,
                onTabChange: onTabChange,
                curve: Curves.easeOutCubic,
                duration: const Duration(milliseconds: 350),
                gap: 8,
                color: Colors.grey[600],
                activeColor: Colors.white,
                iconSize: 22,
                tabBackgroundGradient: AppColors.heroGradient,
                tabBorderRadius: 18,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                tabs: items
                    .map((i) => GButton(icon: i.icon, text: i.text))
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
