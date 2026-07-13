// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import 'widgets/login_footer.dart';
import 'widgets/login_form.dart';
import 'widgets/login_google_button.dart';
import 'widgets/login_header.dart';
import 'package:fluentish/src/shared/shared.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pine,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: const [
              LoginHeader(),
              SizedBox(height: AppSpacing.xxl),
              LoginForm(),
              SizedBox(height: AppSpacing.xl),
              LoginGoogleButton(),
              SizedBox(height: AppSpacing.lg),
              LoginFooter(),
            ],
          ),
        ),
      ),
    );
  }
}
