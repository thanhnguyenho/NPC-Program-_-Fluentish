import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/fluentish_theme_colors.dart';

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
    final colors = context.fluentishColors;

    return Container(
      height: height,
      margin: margin,
      width: width,
      decoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            color: colors.shadow,
            offset: const Offset(0, 5),
          ),
        ],
        color: colors.surface,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: padding,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
