import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:fluentish/src/services/auth_service.dart';
import 'package:fluentish/src/shared/shared.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();
  bool _isSending = false;
  bool _emailSent = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSending) return;
    final email = emailController.text.trim().toLowerCase();
    final isValidEmail = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
    if (!isValidEmail) {
      _showMessage('Please enter a valid email address.');
      return;
    }

    setState(() => _isSending = true);
    try {
      await AuthService().resetPassword(email);
      if (!mounted) return;
      setState(() => _emailSent = true);
      _showMessage('Password reset email sent to $email.');
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      _showMessage(_messageFor(error.code));
    } catch (_) {
      if (!mounted) return;
      _showMessage('Could not send the reset email. Please try again.');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  String _messageFor(String code) => switch (code) {
        'invalid-email' => 'Please enter a valid email address.',
        'user-not-found' => 'No account was found for this email address.',
        'too-many-requests' =>
          'Too many requests. Please wait a moment and try again.',
        'network-request-failed' =>
          'Check your internet connection and try again.',
        _ => 'Could not send the reset email. Please try again.',
      };

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
    final colors = context.fluentishColors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: colors.textPrimary,
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
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 8),
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
              if (_emailSent) ...[
                const SizedBox(height: AppSpacing.lg),
                AppCard(
                  child: Row(
                    children: [
                      Icon(Icons.mark_email_read_outlined,
                          color: colors.textPrimary),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Check your inbox and spam folder, then open the link to set a new password.',
                          style: AppTextStyles.body.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 40),
              AppButton(
                label: _isSending
                    ? 'SENDING...'
                    : _emailSent
                        ? 'SEND AGAIN'
                        : 'SEND RESET EMAIL',
                backgroundColor: AppColors.pine,
                foregroundColor: AppColors.blush,
                onPressed: _isSending ? null : _submit,
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
