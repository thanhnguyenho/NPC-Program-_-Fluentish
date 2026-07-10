import 'package:flutter/material.dart';

import 'package:fluentish/src/shared/shared.dart';

class LoginGoogleButton extends StatelessWidget {
  const LoginGoogleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: Divider(color: AppColors.blush),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
              ),
              child: Text(
                'or continue with',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.blush,
                ),
              ),
            ),
            const Expanded(
              child: Divider(color: AppColors.blush),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.lg),

        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.g_mobiledata),
          label: const Text('Continue with Google'),
        ),
      ],
    );
  }
}