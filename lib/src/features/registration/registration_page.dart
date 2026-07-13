import 'package:flutter/material.dart';

import 'package:fluentish/src/features/login/login_page.dart';
import 'package:fluentish/src/shared/shared.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final preferredNameController = TextEditingController();

  final usernameController = TextEditingController();
  final dobController = TextEditingController();
  final phoneController = TextEditingController();

  final emailController = TextEditingController();
  final confirmEmailController = TextEditingController();

  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool agree = false;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    preferredNameController.dispose();

    usernameController.dispose();
    dobController.dispose();
    phoneController.dispose();

    emailController.dispose();
    confirmEmailController.dispose();

    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
    );
  }

  Widget buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
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
          obscureText: obscure,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: AppStrokeText(
                  'CREATE ACCOUNT',
                  fontSize: 36,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: buildField(
                      label: 'FIRST NAME:',
                      controller: firstNameController,
                      hint: 'e.g Chloe',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: buildField(
                      label: 'LAST NAME:',
                      controller: lastNameController,
                      hint: 'e.g Nguyen',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              buildField(
                label: 'PREFERRED NAME:',
                controller: preferredNameController,
                hint: 'e.g Chloe',
              ),
              const SizedBox(height: AppSpacing.md),
              buildField(
                label: 'USERNAME:',
                controller: usernameController,
                hint: 'e.g Chloe123',
              ),
              const SizedBox(height: AppSpacing.md),
              buildField(
                label: 'DATE OF BIRTH:',
                controller: dobController,
                hint: 'DD/MM/YYYY',
              ),
              const SizedBox(height: AppSpacing.md),
              buildField(
                label: 'PHONE NUMBER:',
                controller: phoneController,
                hint: '0412345678',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppSpacing.md),
              buildField(
                label: 'EMAIL:',
                controller: emailController,
                hint: 'example@gmail.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppSpacing.md),
              buildField(
                label: 'CONFIRM EMAIL:',
                controller: confirmEmailController,
                hint: 'example@gmail.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppSpacing.md),
              buildField(
                label: 'PASSWORD:',
                controller: passwordController,
                hint: 'Minimum 8 characters',
                obscure: true,
              ),
              const SizedBox(height: AppSpacing.md),
              buildField(
                label: 'CONFIRM PASSWORD:',
                controller: confirmPasswordController,
                hint: 'Re-enter password',
                obscure: true,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: agree,
                    activeColor: AppColors.pine,
                    onChanged: (value) {
                      setState(() {
                        agree = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: RichText(
                        text: TextSpan(
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.pine,
                            fontSize: 12,
                          ),
                          children: const [
                            TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: ', and confirm I am 18 years or older.',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: 'CREATE ACCOUNT',
                backgroundColor: AppColors.pine,
                foregroundColor: AppColors.blush,
                onPressed: _goToLogin,
              ),
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: GestureDetector(
                  onTap: _goToLogin,
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.pine,
                      ),
                      children: const [
                        TextSpan(
                          text: 'Already have an account? ',
                        ),
                        TextSpan(
                          text: 'Log in',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
