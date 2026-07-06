import 'package:flutter/material.dart';
import 'widgets/language_toggle.dart';
import 'widgets/category_filter.dart';
import 'widgets/word_card.dart';

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

              const SizedBox(height: 24),
              CategoryFilter(),

              const SizedBox(height: 24),
              Expanded(
                  child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                      children: const [
                    WordCard(
                      english: 'Hello',
                      vietnamese: 'Xin chào',
                    ),
                    WordCard(
                      english: 'Thank you',
                      vietnamese: 'Cảm ơn',
                      favourite: true,
                    ),
                    WordCard(
                      english: 'Goodbye',
                      vietnamese: 'Tạm biệt',
                    ),
                    WordCard(
                      english: 'Yes',
                      vietnamese: 'Vâng',
                    ),
                    WordCard(
                      english: 'No',
                      vietnamese: 'Không',
                    ),
                    WordCard(
                      english: 'Please',
                      vietnamese: 'Làm ơn',
                    ),
                  ]))
            ],
          ),
        ),
      ),
    );
  }
}
