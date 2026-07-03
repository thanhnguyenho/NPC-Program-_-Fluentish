import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  const AppTextStyles._();

  static const displayFont = 'Itim';
  static const bodyFont = 'Inter';
  static const accentFont = 'Gulzar';

  static const display = TextStyle(
    color: AppColors.blush,
    fontFamily: displayFont,
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static const button = TextStyle(
    fontFamily: displayFont,
    fontSize: 24,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static const title = TextStyle(
    color: AppColors.pine,
    fontFamily: displayFont,
    fontSize: 24,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static const body = TextStyle(
    color: AppColors.textSoft,
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static const cardBody = TextStyle(
    color: AppColors.textMuted,
    fontFamily: displayFont,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static const navLabel = TextStyle(
    color: AppColors.blush,
    fontFamily: accentFont,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static const chipLabel = TextStyle(
    color: AppColors.pine,
    fontFamily: accentFont,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static const textTheme = TextTheme(
    displayLarge: display,
    titleLarge: title,
    bodyMedium: body,
    labelLarge: button,
  );
}
