import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:fluentish/src/shared/shared.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _hideCurrentPassword = true;
  bool _hideNewPassword = true;
  bool _hideConfirmPassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateNewPassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Enter a new password.';
    if (password.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Include at least one uppercase letter.';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Include at least one number.';
    }
    if (!RegExp(r'''[!@#$%^&*(),.?":{}|<>_\-\[\]/\\;=+~`]''')
        .hasMatch(password)) {
      return 'Include at least one special character.';
    }
    if (password == _currentPasswordController.text) {
      return 'New password must be different from the current password.';
    }
    return null;
  }

  Future<void> _changePassword() async {
    FocusScope.of(context).unfocus();
    if (_isSubmitting || !_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;
    if (user == null || email == null) {
      _showMessage('Please sign in again before changing your password.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: _currentPasswordController.text,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(_newPasswordController.text);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully.')),
      );
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      _showMessage(_messageFor(error.code));
    } catch (_) {
      if (!mounted) return;
      _showMessage('Could not change your password. Please try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _messageFor(String code) {
    return switch (code) {
      'wrong-password' ||
      'invalid-credential' =>
        'Your current password is incorrect.',
      'weak-password' => 'Your new password is too weak.',
      'requires-recent-login' =>
        'For security, please sign in again before changing your password.',
      'too-many-requests' =>
        'Too many attempts. Please wait a moment and try again.',
      'network-request-failed' =>
        'Check your internet connection and try again.',
      'user-mismatch' ||
      'user-not-found' =>
        'Your account could not be verified. Please sign in again.',
      _ => 'Could not change your password. Please try again.',
    };
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.fluentishColors;
    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          _Header(onBack: () => Navigator.of(context).pop()),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.xl,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _SecurityIntro(),
                    const SizedBox(height: AppSpacing.lg),
                    _PasswordField(
                      controller: _currentPasswordController,
                      label: 'Current password',
                      hint: 'Enter your current password',
                      obscureText: _hideCurrentPassword,
                      onToggleVisibility: () => setState(
                        () => _hideCurrentPassword = !_hideCurrentPassword,
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter your current password.'
                          : null,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _PasswordField(
                      controller: _newPasswordController,
                      label: 'New password',
                      hint: 'Enter your new password',
                      obscureText: _hideNewPassword,
                      onToggleVisibility: () => setState(
                        () => _hideNewPassword = !_hideNewPassword,
                      ),
                      validator: _validateNewPassword,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const _PasswordRequirements(),
                    const SizedBox(height: AppSpacing.md),
                    _PasswordField(
                      controller: _confirmPasswordController,
                      label: 'Confirm new password',
                      hint: 'Enter your new password again',
                      obscureText: _hideConfirmPassword,
                      onToggleVisibility: () => setState(
                        () => _hideConfirmPassword = !_hideConfirmPassword,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirm your new password.';
                        }
                        if (value != _newPasswordController.text) {
                          return 'Passwords do not match.';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _changePassword(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: _isSubmitting
                          ? 'Changing password...'
                          : 'Change Password',
                      icon: _isSubmitting ? null : Icons.lock_reset,
                      backgroundColor: colors.header,
                      foregroundColor: colors.onHeader,
                      onPressed: _isSubmitting ? null : _changePassword,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.fluentishColors;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.header,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(8, 50, AppSpacing.md, AppSpacing.md),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: Icon(Icons.arrow_back, color: colors.onHeader),
          ),
          Expanded(
            child: Text(
              'Change Password',
              style: AppTextStyles.title.copyWith(
                color: colors.onHeader,
                fontSize: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SecurityIntro extends StatelessWidget {
  const _SecurityIntro();

  @override
  Widget build(BuildContext context) {
    final colors = context.fluentishColors;
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: colors.accent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shield_outlined,
              color: colors.header,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keep your account secure',
                  style: AppTextStyles.body.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose a strong password that you do not use for another account.',
                  style: AppTextStyles.body.copyWith(
                    color: colors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.obscureText,
    required this.onToggleVisibility,
    required this.validator,
    required this.textInputAction,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final FormFieldValidator<String> validator;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    final colors = context.fluentishColors;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          enableSuggestions: false,
          autocorrect: false,
          textInputAction: textInputAction,
          validator: validator,
          onFieldSubmitted: onFieldSubmitted,
          style: AppTextStyles.body.copyWith(color: colors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.body.copyWith(color: Colors.grey),
            filled: true,
            fillColor: colors.surfaceStrong,
            prefixIcon: Icon(Icons.lock_outline, color: colors.textSecondary),
            suffixIcon: IconButton(
              tooltip: obscureText ? 'Show password' : 'Hide password',
              onPressed: onToggleVisibility,
              icon: Icon(
                obscureText
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: colors.textSecondary,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            border: border,
            enabledBorder: border,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colors.accent, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _PasswordRequirements extends StatelessWidget {
  const _PasswordRequirements();

  @override
  Widget build(BuildContext context) {
    final colors = context.fluentishColors;
    return Text(
      'Use 8+ characters with an uppercase letter, a number, and a special character.',
      style: AppTextStyles.body.copyWith(
        color: colors.textSecondary,
        fontSize: 12,
      ),
    );
  }
}
