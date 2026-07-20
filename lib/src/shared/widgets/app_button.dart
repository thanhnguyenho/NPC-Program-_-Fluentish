import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../theme/fluentish_theme_colors.dart';

enum AppButtonVariant {
  filled,
  outlined,
}

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = true,
    this.backgroundColor,
    this.foregroundColor,
  }) : variant = AppButtonVariant.filled;

  const AppButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = true,
    this.foregroundColor,
  })  : variant = AppButtonVariant.outlined,
        backgroundColor = null;

  final bool expand;
  final IconData? icon;
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;

  /// Optional colors (only for filled button)
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.fluentishColors;
    final child = _ButtonChild(
      label: label,
      icon: icon,
    );

    return SizedBox(
      height: AppSpacing.buttonHeight,
      width: expand ? double.infinity : null,
      child: switch (variant) {
        AppButtonVariant.filled => ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor ?? colors.accent,
              foregroundColor: foregroundColor ?? colors.textPrimary,
              textStyle: AppTextStyles.button,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
              ),
            ),
            child: child,
          ),
        AppButtonVariant.outlined => OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: foregroundColor ?? colors.textPrimary,
              side: BorderSide(
                color: foregroundColor ?? colors.border,
              ),
              textStyle: AppTextStyles.button,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
              ),
            ),
            child: child,
          ),
      },
    );
  }
}

class _ButtonChild extends StatelessWidget {
  const _ButtonChild({
    required this.label,
    this.icon,
  });

  final IconData? icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    if (icon == null) {
      return Text(
        label,
        textAlign: TextAlign.center,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 20,
        ),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
