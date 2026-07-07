import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.pine,
    ).copyWith(
      primary: AppColors.pine,
      onPrimary: AppColors.blush,
      secondary: AppColors.blush,
      onSecondary: AppColors.pine,
      surface: AppColors.blush,
      onSurface: AppColors.pine,
    );

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.blush,
      textTheme: AppTextStyles.textTheme,
      useMaterial3: true,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blush,
          disabledBackgroundColor: AppColors.shell,
          disabledForegroundColor: AppColors.pineMuted,
          elevation: 0,
          foregroundColor: AppColors.pineMuted,
          minimumSize: const Size(0, AppSpacing.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.lg),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.lg),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        filled: true,
        fillColor: AppColors.cardSurface,
        hintStyle: AppTextStyles.body,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.blush,
          minimumSize: const Size(0, AppSpacing.buttonHeight),
          side: const BorderSide(color: AppColors.blush),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
    );
  }
}
