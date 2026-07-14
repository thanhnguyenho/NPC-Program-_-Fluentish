import 'package:flutter/material.dart';

import 'package:fluentish/src/features/login/login_page.dart';
import 'package:fluentish/src/shared/shared.dart';

/// Confirms a password-reset email was sent, with a resend option.
class ResendEmailPage extends StatelessWidget {
  const ResendEmailPage({
    super.key,
    this.username = 'your email',
  });

  final String username;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blush,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //----------------------------------
              // Back button
              //----------------------------------

              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: AppColors.pine,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              const SizedBox(height: 10),

              //----------------------------------
              // Title
              //----------------------------------

              Text(
                "EMAIL SENT!",
                textAlign: TextAlign.center,
                style: AppTextStyles.title.copyWith(
                  color: AppColors.pine,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              //----------------------------------
              // Description
              //----------------------------------

              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.pine,
                    fontSize: 17,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(
                      text:
                          'We have sent password reset instructions to\n\n',
                    ),
                    TextSpan(
                      text: username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const TextSpan(
                      text:
                          '\n\nPlease check your inbox and follow the instructions to reset your password.',
                    ),
                  ],
                ),
              ),

              const Spacer(),

              //----------------------------------
              // Image
              //----------------------------------

              Center(
                child: Image.asset(
                  'assets/images/logo(4).png',
                  height: 280,
                ),
              ),

              const Spacer(),

              //----------------------------------
              // Resend Button
              //----------------------------------

              AppButton(
                label: "RESEND EMAIL",
                backgroundColor: AppColors.pine,
                foregroundColor: AppColors.blush,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Password reset email has been sent again.",
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              //----------------------------------
              // Back to Login
              //----------------------------------

              OutlinedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginPage(),
                    ),
                    (route) => false,
                  );
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  side: const BorderSide(
                    color: AppColors.pine,
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  "GO BACK TO LOGIN",
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.pine,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}