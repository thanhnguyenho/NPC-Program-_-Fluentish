import 'package:flutter/material.dart';

import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_spacing.dart';
import '../../shared/theme/app_text_styles.dart';

class SoundboardPage extends StatelessWidget {
  const SoundboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.blush,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(
            bottom: AppSpacing.bottomNavHeight,
          ),
          child: Center(
            child: Text(
              'Soundboard',
              style: AppTextStyles.title,
            ),
          ),
        ),
      ),
    );
  }
}
