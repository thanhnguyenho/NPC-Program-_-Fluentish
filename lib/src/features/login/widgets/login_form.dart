import 'package:flutter/material.dart';
import 'package:fluentish/src/features/navigation/main_scaffold.dart';
import 'package:fluentish/src/features/forgot_password/forgot_password_page.dart';
import 'package:fluentish/src/shared/shared.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
    this.auth,
  });

  final AuthGateway? auth;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  late final AuthGateway _auth;

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _auth = widget.auth ?? Auth.instance;
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (isSubmitting) return;

    setState(() {
      isSubmitting = true;
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: usernameController.text.trim(),
        password: passwordController.text,
      );

      final uid = _auth.currentUserId;

      if (uid == null) {
        throw StateError('Authentication completed without a signed-in user.');
      }

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => MainScaffold(
            initialIndex: 0,
            auth: _auth,
          ),
        ),
        (route) => false,
      );
    } catch (e, stackTrace) {
      debugPrint('=== LOGIN FORM ERROR ===');
      debugPrint('$e');
      debugPrint('$stackTrace');
      debugPrint('========================');
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              e is StateError ? e.message : e.toString(),
            ),
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
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
          controller: usernameController,
          hintText: 'Enter your email',
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
          label: isSubmitting ? 'LOADING...' : 'LOGIN',
          onPressed: isSubmitting ? null : _login,
        ),
      ],
    );
  }
}
