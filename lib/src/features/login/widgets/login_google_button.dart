import 'package:flutter/material.dart';

import 'package:fluentish/src/features/navigation/main_scaffold.dart';
import 'package:fluentish/src/shared/shared.dart';

class LoginGoogleButton extends StatefulWidget {
  const LoginGoogleButton({
    super.key,
    this.auth,
  });

  final AuthGateway? auth;

  @override
  State<LoginGoogleButton> createState() => _LoginGoogleButtonState();
}

class _LoginGoogleButtonState extends State<LoginGoogleButton> {
  bool _isSubmitting = false;

  Future<void> _signIn() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    final auth = widget.auth ?? Auth.instance;

    try {
      await auth.signInWithGoogle();

      if (auth.currentUserId == null) {
        throw StateError(
          'Google authentication completed without a signed-in user.',
        );
      }
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => MainScaffold(
            initialIndex: 0,
            auth: auth,
          ),
        ),
        (route) => false,
      );
    } catch (error, stackTrace) {
      debugPrint('=== GOOGLE LOGIN ERROR ===');
      debugPrint('$error');
      debugPrint('$stackTrace');
      debugPrint('==========================');
      if (!mounted) return;

      final message = error is StateError
          ? error.message
          : error.toString().replaceFirst('Bad state: ', '');

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(message)),
        );
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
