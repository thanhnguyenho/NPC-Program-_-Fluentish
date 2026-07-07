import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyles {
  const AppTextStyles._();

  static final display = GoogleFonts.itim(
    color: AppColors.blush,
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static final button = GoogleFonts.itim(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static final title = GoogleFonts.itim(
    color: AppColors.pine,
    fontSize: 24,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static final body = GoogleFonts.inter(
    color: AppColors.textSoft,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static final cardBody = GoogleFonts.itim(
    color: AppColors.textMuted,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static final navLabel = GoogleFonts.gulzar(
    color: AppColors.blush,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static final chipLabel = GoogleFonts.gulzar(
    color: AppColors.pine,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static final textTheme = TextTheme(
    displayLarge: display,
    titleLarge: title,
    bodyMedium: body,
    labelLarge: button,
  );
}
