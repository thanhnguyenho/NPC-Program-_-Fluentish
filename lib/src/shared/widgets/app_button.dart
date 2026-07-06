import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

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
  }) : variant = AppButtonVariant.filled;

  const AppButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = true,
  }) : variant = AppButtonVariant.outlined;

  final bool expand;
  final IconData? icon;
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final child = _ButtonChild(label: label, icon: icon);

    return SizedBox(
      height: AppSpacing.buttonHeight,
      width: expand ? double.infinity : null,
      child: switch (variant) {
        AppButtonVariant.filled => ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blush,
              foregroundColor: AppColors.pineMuted,
              textStyle: AppTextStyles.button,
            ),
            child: child,
          ),
        AppButtonVariant.outlined => OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.blush,
              side: const BorderSide(color: AppColors.blush),
              textStyle: AppTextStyles.button,
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
      return Text(label, textAlign: TextAlign.center);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20),
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
