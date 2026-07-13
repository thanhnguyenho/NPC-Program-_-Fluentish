import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppStrokeText extends StatelessWidget {
  const AppStrokeText(
    this.text, {
    super.key,
    this.fontSize = 36,
    this.textAlign = TextAlign.center,
  });

  final String text;
  final double fontSize;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          text,
          textAlign: textAlign,
          style: AppTextStyles.title.copyWith(
            fontSize: fontSize,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5
              ..color = AppColors.pine,
          ),
        ),
        Text(
          text,
          textAlign: textAlign,
          style: AppTextStyles.title.copyWith(
            fontSize: fontSize,
            color: AppColors.blush,
          ),
        ),
      ],
    );
  }
}
