// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import 'widgets/login_footer.dart';
import 'widgets/login_form.dart';
import 'widgets/login_google_button.dart';
import 'widgets/login_header.dart';
import 'package:fluentish/src/shared/shared.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({
    super.key,
    this.auth,
  });

  final AuthGateway? auth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pine,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              const LoginHeader(),
              const SizedBox(height: AppSpacing.xxl),
              LoginForm(auth: auth),
              const SizedBox(height: AppSpacing.xl),
              LoginGoogleButton(auth: auth),
              const SizedBox(height: AppSpacing.lg),
              const LoginFooter(),
            ],
          ),
        ),
      ),
    );
  }
}
