import 'package:flutter/material.dart';
import 'widgets/language_toggle.dart';
import 'widgets/category_filter.dart';
import 'widgets/word_card.dart';
import 'data/words.dart';
import 'models/soundboard_word.dart';

class SoundboardPage extends StatefulWidget {
  const SoundboardPage({super.key});

  @override
  State<SoundboardPage> createState() => _SoundboardPageState();
}

class _SoundboardPageState extends State<SoundboardPage> {
  String selectedCategory = 'All Words';
  bool isVietnamese = true;

  List<SoundboardWord> get filteredWords {
    if (selectedCategory == 'All Words') {
      return words;
    }

    if (selectedCategory == 'Favourites') {
      return words.where((word) => word.favourite).toList();
    }

    return words
        .where((word) => word.category == selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFEEDADA),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: LanguageToggle(
                  isVietnamese: isVietnamese,
                  onToggle: () {
                    setState(() {
                      isVietnamese = !isVietnamese;
                    });
                  }
                ),
              ),

              const SizedBox(height: 24),
              CategoryFilter(
                selectedCategory: selectedCategory,
                onCategorySelected: (category) {
                  setState(() {
                    selectedCategory = category;
                  });
                },
              ),

              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  physics: const ClampingScrollPhysics(),
                  itemCount: filteredWords.length,
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final word = filteredWords[index];

                    return WordCard(
                      english: word.english,
                      vietnamese: word.vietnamese,
                      category: word.category,
                      englishAudio: word.englishAudio,
                      vietnameseAudio: word.vietnameseAudio,
                      isVietnamese: isVietnamese,
                      favourite: word.favourite,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
                  
