import 'package:flutter/material.dart';

import 'app_colors.dart';

@immutable
class FluentishThemeColors extends ThemeExtension<FluentishThemeColors> {
  const FluentishThemeColors({
    required this.background,
    required this.surface,
    required this.surfaceStrong,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.header,
    required this.onHeader,
    required this.accent,
    required this.shadow,
  });

  final Color background;
  final Color surface;
  final Color surfaceStrong;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color header;
  final Color onHeader;
  final Color accent;
  final Color shadow;

  static const light = FluentishThemeColors(
    background: AppColors.shell,
    surface: Color(0xFFF8F5F1),
    surfaceStrong: Colors.white,
    border: Color(0xFFE5DAD6),
    textPrimary: AppColors.pine,
    textSecondary: Color(0xFF68705F),
    header: AppColors.pine,
    onHeader: AppColors.blush,
    accent: AppColors.blush,
    shadow: AppColors.shadow,
  );

  static const dark = FluentishThemeColors(
    background: Color(0xFF171A15),
    surface: Color(0xFF252A21),
    surfaceStrong: Color(0xFF30362B),
    border: Color(0xFF424A3B),
    textPrimary: Color(0xFFF4E7E4),
    textSecondary: Color(0xFFB8BDAF),
    header: Color(0xFF2C3328),
    onHeader: Color(0xFFF4DDDD),
    accent: Color(0xFFB98383),
    shadow: Color(0x52000000),
  );

  @override
  FluentishThemeColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceStrong,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? header,
    Color? onHeader,
    Color? accent,
    Color? shadow,
  }) {
    return FluentishThemeColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceStrong: surfaceStrong ?? this.surfaceStrong,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      header: header ?? this.header,
      onHeader: onHeader ?? this.onHeader,
      accent: accent ?? this.accent,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  FluentishThemeColors lerp(
    covariant FluentishThemeColors? other,
    double t,
  ) {
    if (other == null) return this;
    return FluentishThemeColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceStrong: Color.lerp(surfaceStrong, other.surfaceStrong, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      header: Color.lerp(header, other.header, t)!,
      onHeader: Color.lerp(onHeader, other.onHeader, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

extension FluentishThemeContext on BuildContext {
  FluentishThemeColors get fluentishColors =>
      Theme.of(this).extension<FluentishThemeColors>() ??
      FluentishThemeColors.light;
}
