import 'package:flutter/material.dart';

class SoundboardPage extends StatelessWidget {
  const SoundboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEDADA),
      body: const Center(
        child: Text(
          'Soundboard Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}