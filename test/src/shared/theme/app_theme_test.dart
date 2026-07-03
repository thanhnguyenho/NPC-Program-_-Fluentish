import 'package:fluentish/src/shared/theme/app_colors.dart';
import 'package:fluentish/src/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AppTheme uses Fluentish Figma colors', () {
    final theme = AppTheme.light;

    expect(theme.colorScheme.primary, AppColors.pine);
    expect(theme.colorScheme.secondary, AppColors.blush);
    expect(theme.scaffoldBackgroundColor, AppColors.blush);
    expect(theme.useMaterial3, isTrue);
  });

  test('AppTheme keeps controls rounded like the design', () {
    final buttonTheme = AppTheme.light.elevatedButtonTheme.style;
    final shape = buttonTheme?.shape?.resolve(<WidgetState>{});

    expect(shape, isA<RoundedRectangleBorder>());
  });
}
