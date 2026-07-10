import 'package:flutter/material.dart';

import 'package:fluentish/src/features/login/login_page.dart';
import 'package:fluentish/src/features/registration/registration_page.dart';
import 'package:fluentish/src/features/welcome/widgets/welcome_logo.dart';
import 'package:fluentish/src/shared/shared.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pine,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
          ),
          child: Column(
            children: [
              const Expanded(
                child: WelcomeLogo(),
              ),

              AppButton(
                label: 'LOGIN',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LoginPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.md),

              AppButton.outlined(
                label: 'CREATE ACCOUNT',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const RegistrationPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}