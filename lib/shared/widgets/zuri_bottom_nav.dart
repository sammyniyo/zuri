import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ZuriBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const ZuriBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ZuriColors.surface,
        boxShadow: ZuriColors.bottomNavShadow,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.explore_outlined,
                activeIcon: Icons.explore_rounded,
                label: 'Explore',
                index: 0,
                current: currentIndex,
                onTap: onTap,
              ),
              _NavItem(
                icon: Icons.map_outlined,
                activeIcon: Icons.map_rounded,
                label: 'Map',
                index: 1,
                current: currentIndex,
                onTap: onTap,
              ),
              _NavItem(
                icon: Icons.bookmark_outline_rounded,
                activeIcon: Icons.bookmark_rounded,
                label: 'Saved',
                index: 2,
                current: currentIndex,
                onTap: onTap,
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Profile',
                index: 3,
                current: currentIndex,
                onTap: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int current;
  final Function(int) onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == current;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? ZuriColors.primaryLight : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? ZuriColors.primary : ZuriColors.textTertiary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight:
                    isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? ZuriColors.primary : ZuriColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
