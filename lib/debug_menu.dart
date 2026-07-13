import 'package:flutter/material.dart';

import 'package:fluentish/src/features/welcome/welcome_page.dart';
import 'package:fluentish/src/features/login/login_page.dart';
import 'package:fluentish/src/features/registration/registration_page.dart';
import 'package:fluentish/src/features/forgot_password/forgot_password_page.dart';
import 'package:fluentish/src/features/profile/profile_page.dart';

class DebugMenu extends StatelessWidget {
  const DebugMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Debug Menu"),
      ),
      body: ListView(
        children: [
          _tile(
            context,
            "Welcome",
            const WelcomePage(),
          ),

          _tile(
            context,
            "Login",
            const LoginPage(),
          ),

          _tile(
            context,
            "Registration",
            const RegistrationPage(),
          ),

          _tile(
            context,
            "Forgot Password",
            const ForgotPasswordPage(),
          ),

          _tile(
            context,
            "Profile",
            const ProfilePage(),
          ),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    String title,
    Widget page,
  ) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => page,
          ),
        );
      },
    );
  }
}
