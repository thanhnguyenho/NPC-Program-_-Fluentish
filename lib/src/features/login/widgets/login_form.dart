import 'package:flutter/material.dart';

import 'package:fluentish/src/features/forgot_password/forgot_password_page.dart';
import 'package:fluentish/src/features/home/home_page.dart';
import 'package:fluentish/src/shared/shared.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppTextLabel(text: 'Username'),

        const SizedBox(height: AppSpacing.xs),

        AppTextField(
          controller: usernameController,
          hintText: 'Enter your username',
        ),

        const SizedBox(height: AppSpacing.lg),

        const AppTextLabel(text: 'Password'),

        const SizedBox(height: AppSpacing.xs),

        AppTextField(
          controller: passwordController,
          hintText: 'Enter your password',
          obscureText: obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              obscurePassword
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: AppColors.pine,
            ),
            onPressed: () {
              setState(() {
                obscurePassword = !obscurePassword;
              });
            },
          ),
        ),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ForgotPasswordPage(),
                ),
              );
            },
            child: Text(
              'Forgot Password?',
              style: AppTextStyles.body.copyWith(
                color: AppColors.blush,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        AppButton(
          label: 'LOGIN',
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          },
        ),
      ],
    );
  }
}
