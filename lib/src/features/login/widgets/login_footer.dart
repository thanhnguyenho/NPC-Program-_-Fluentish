import 'package:flutter/material.dart';

import 'package:fluentish/src/features/registration/registration_page.dart';
import 'package:fluentish/src/shared/shared.dart';

class LoginFooter extends StatelessWidget {
  const LoginFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const RegistrationPage(),
            ),
          );
        },
        child: Text(
          "Don't have an account? Register",
          style: AppTextStyles.body.copyWith(
            color: AppColors.blush,
          ),
        ),
      ),
    );
  }
}
