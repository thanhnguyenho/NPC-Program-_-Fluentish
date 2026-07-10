import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppTextLabel extends StatelessWidget {
  const AppTextLabel({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.body.copyWith(
        color: AppColors.pine,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
    );
  }
}