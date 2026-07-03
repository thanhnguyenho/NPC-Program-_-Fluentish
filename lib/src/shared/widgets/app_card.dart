import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.height,
    this.margin,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.width,
  });

  final Widget child;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(AppSpacing.cardRadius);

    return Container(
      height: height,
      margin: margin,
      width: width,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: borderRadius,
        boxShadow: const [
          BoxShadow(
            blurRadius: 14,
            color: AppColors.shadow,
            offset: Offset(0, 5),
          ),
        ],
        color: AppColors.cardSurface,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
