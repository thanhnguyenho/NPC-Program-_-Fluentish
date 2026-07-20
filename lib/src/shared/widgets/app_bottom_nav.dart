import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../theme/fluentish_theme_colors.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  static const items = [
    AppBottomNavItem(icon: Icons.home_outlined, label: 'Home'),
    AppBottomNavItem(icon: Icons.translate, label: 'Language'),
    AppBottomNavItem(icon: Icons.volume_up_outlined, label: 'Soundboard'),
    AppBottomNavItem(icon: Icons.groups_2_outlined, label: 'Community'),
    AppBottomNavItem(icon: Icons.person_outline, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(AppSpacing.bottomNavRadius);
    final colors = context.fluentishColors;

    return SafeArea(
      top: false,
      child: SizedBox(
        height: AppSpacing.bottomNavHeight,
        child: Material(
          borderRadius: borderRadius,
          clipBehavior: Clip.antiAlias,
          color: colors.header,
          child: Row(
            children: [
              for (var index = 0; index < items.length; index++)
                Expanded(
                  child: _BottomNavTile(
                    isSelected: index == currentIndex,
                    item: items[index],
                    onTap: () => onItemSelected(index),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppBottomNavItem {
  const AppBottomNavItem({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}

class _BottomNavTile extends StatelessWidget {
  const _BottomNavTile({
    required this.isSelected,
    required this.item,
    required this.onTap,
  });

  final bool isSelected;
  final AppBottomNavItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.fluentishColors;
    return InkWell(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: isSelected ? 1 : 0.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, color: colors.onHeader, size: 24),
            const SizedBox(height: AppSpacing.xxs),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                item.label,
                maxLines: 1,
                style: AppTextStyles.navLabel.copyWith(color: colors.onHeader),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
