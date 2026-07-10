import 'package:flutter/material.dart';

import 'package:fluentish/src/shared/shared.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.chevron_left,
              color: AppColors.blush,
              size: 32,
            ),
          ),
        ),

        Image.asset(
          AppAssets.fluentishLogo,
          height: 180,
        ),

        const SizedBox(height: AppSpacing.lg),

        Text(
          'WELCOME BACK TO FLUENTISH',
          textAlign: TextAlign.center,
          style: AppTextStyles.title.copyWith(
            color: AppColors.blush,
          ),
        ),
      ],
    );
  }
}