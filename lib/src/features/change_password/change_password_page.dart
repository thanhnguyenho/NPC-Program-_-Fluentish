import 'package:flutter/material.dart';

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Password change flow can be wired here later.'),
        ),
      ),
    );
  }
}
