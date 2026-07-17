import 'package:fluentish/src/features/navigation/main_scaffold.dart';
import 'package:fluentish/src/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:fluentish/src/features/forgot_password/forgot_password_page.dart';
import 'package:fluentish/src/shared/shared.dart';
// import 'package:fluentish/src/features/registration/registration_page.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:fluentish/src/shared/services/auth_service.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final AuthService _authService = AuthService();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool _isSubmitting = false;
  String? errorMessage;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_isSubmitting) return;

    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Please enter your email and password.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      errorMessage = null;
    });

    try {
      await _authService.login(email: email, password: password);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MainScaffold(initialIndex: 0),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Login failed. Please try again.';

      switch (e.code) {
        case 'user-not-found':
          message = 'No account found with this email.';
          break;
        case 'wrong-password':
          message = 'Incorrect password.';
          break;
        case 'invalid-email':
          message = 'Invalid email address.';
          break;
        case 'invalid-credential':
          message = 'Incorrect email or password.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        default:
          message = e.message ?? message;
      }

      if (!mounted) return;
      setState(() {
        errorMessage = message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Something went wrong. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppTextLabel(text: 'Email'),
        const SizedBox(height: AppSpacing.xs),
        AppTextField(
          controller: emailController,
          hintText: 'Enter your email',
          keyboardType: TextInputType.emailAddress,
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
              obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: AppColors.pine,
            ),
            onPressed: () {
              setState(() {
                obscurePassword = !obscurePassword;
              });
            },
          ),
        ),
        if (errorMessage != null && errorMessage!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            errorMessage!,
            style: AppTextStyles.body.copyWith(
              color: Colors.red.shade200,
            ),
          ),
        ],
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
          label: _isSubmitting ? 'LOGGING IN...' : 'LOGIN',
          onPressed: _login,
        ),
      ],
    );
  }
}