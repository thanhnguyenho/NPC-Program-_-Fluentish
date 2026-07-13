// ignore_for_file: prefer_const_constructors, unused_import

import 'package:flutter/material.dart';

// import 'package:fluentish/src/features/login/login_page.dart';
import 'package:fluentish/src/features/resend_email/resend_email_page.dart';
import 'package:fluentish/src/shared/shared.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (emailController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter your email and phone number.',
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResendEmailPage(
          username: emailController.text.trim(),
        ),
      ),
    );
  }

  Widget buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextLabel(text: label),
        const SizedBox(height: AppSpacing.xs),
        AppTextField(
          controller: controller,
          hintText: hint,
          keyboardType: keyboardType,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blush,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.pine,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: AppStrokeText(
                        'FORGOT\nPASSWORD',
                        fontSize: 35,
                      ),
                    ),
                  ),
                  Image.asset(
                    'assets/images/forgot_password.png',
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              buildField(
                label: 'EMAIL:',
                controller: emailController,
                hint: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: AppSpacing.lg),

              buildField(
                label: 'PHONE NUMBER:',
                controller: phoneController,
                hint: 'Enter your phone number',
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 40),

              AppButton(
                label: 'SUBMIT',
                backgroundColor: AppColors.pine,
                foregroundColor: AppColors.blush,
                onPressed: _submit,
              ),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
