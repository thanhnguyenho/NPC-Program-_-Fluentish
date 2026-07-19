import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:fluentish/src/features/forgot_password/forgot_password_page.dart';
import 'package:fluentish/src/shared/shared.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key, this.auth});

  final AuthGateway? auth;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool _isSubmitting = false;
  String? errorMessage;

  AuthGateway get _auth => widget.auth ?? Auth.instance;

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
      setState(() => errorMessage = 'Enter your email and password.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      errorMessage = null;
    });

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      final message = switch (e.code) {
        'user-not-found' => 'No account found with this email.',
        'wrong-password' => 'Incorrect password.',
        'invalid-email' => 'Invalid email address.',
        'invalid-credential' => 'Incorrect email or password.',
        'user-disabled' => 'This account has been disabled.',
        _ => e.message ?? 'Login failed. Please try again.',
      };
      if (!mounted) return;
      setState(() => errorMessage = message);
    } catch (_) {
      if (!mounted) return;
      setState(() => errorMessage = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
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
            onPressed: () => setState(() => obscurePassword = !obscurePassword),
          ),
        ),
        if (errorMessage != null && errorMessage!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            errorMessage!,
            style: AppTextStyles.body.copyWith(color: Colors.red.shade200),
          ),
        ],
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
            ),
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
          onPressed: _isSubmitting ? null : _login,
        ),
      ],
    );
  }
}