import 'package:flutter/material.dart';

import 'package:fluentish/src/shared/shared.dart';

class LoginGoogleButton extends StatefulWidget {
  const LoginGoogleButton({super.key, this.auth});

  final AuthGateway? auth;

  @override
  State<LoginGoogleButton> createState() => _LoginGoogleButtonState();
}

class _LoginGoogleButtonState extends State<LoginGoogleButton> {
  bool _isSubmitting = false;

  Future<void> _signIn() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      await (widget.auth ?? Auth.instance).signInWithGoogle();
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (error, stackTrace) {
      debugPrint('=== GOOGLE LOGIN ERROR ===');
      debugPrint('$error');
      debugPrint('$stackTrace');
      debugPrint('==========================');
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(error.toString().replaceFirst('Bad state: ', '')),
        ));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: Divider(color: AppColors.blush),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
              ),
              child: Text(
                'or continue with',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.blush,
                ),
              ),
            ),
            const Expanded(
              child: Divider(color: AppColors.blush),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        OutlinedButton.icon(
          onPressed: _isSubmitting ? null : _signIn,
          icon: const Icon(Icons.g_mobiledata),
          label: Text(
            _isSubmitting ? 'Signing in...' : 'Continue with Google',
          ),
        ),
      ],
    );
  }
}
