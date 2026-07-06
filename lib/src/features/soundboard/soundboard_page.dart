import 'package:flutter/material.dart';
import 'widgets/language_toggle.dart';
import 'widgets/category_filter.dart';


class SoundboardPage extends StatelessWidget {
  const SoundboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEDADA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Align(
                alignment: Alignment.topRight,
                child: LanguageToggle(),
              ),

              const SizedBox(height:24),

              CategoryFilter(),
            ],
          ),
        ),
      ),
    );
  }
}