import 'package:flutter/material.dart';
import 'package:fluentish/src/shared/shared.dart';
import 'widgets/language_toggle.dart';
import 'widgets/category_filter.dart';
import 'widgets/word_card.dart';
import 'data/words.dart';
import 'models/soundboard_word.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class SoundboardPage extends StatefulWidget {
  const SoundboardPage({super.key});

  @override
  State<SoundboardPage> createState() => _SoundboardPageState();
}

class _SoundboardPageState extends State<SoundboardPage> {
  String selectedCategory = 'All Words';
  bool isVietnamese = true;

  Set<String> favouriteIds = {};

  @override
  void initState() {
    super.initState();
    _loadFavourites();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadFavourites();
      }
    });
  }

  List<SoundboardWord> get filteredWords {
    if (selectedCategory == 'All Words') {
      return words;
    }

    if (selectedCategory == 'Favourites') {

      final languageId = isVietnamese ? 'vietnamese' : 'english';

      return words.where((word) {
        return favouriteIds.contains('${word.id}_$languageId');
      }).toList();
    }

    return words.where((word) => word.category == selectedCategory).toList();
  }

  Future<void> _loadFavourites() async {
    if (Firebase.apps.isEmpty) {
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
    
      if (user == null) return;

      final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favouriteSoundboardBites')
        .get();

      if (!mounted) return;
      
      setState(() {
        favouriteIds = snapshot.docs.map((doc) => doc.id).toSet();
      });
    } catch (error) {
      debugPrint('Could not load favourites: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.fluentishColors;
    return ColoredBox(
      color: colors.background,
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
                    }),
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final word = filteredWords[index];

                    return WordCard(
                      key: ValueKey(word.id),
                      id: word.id,
                      english: word.english,
                      vietnamese: word.vietnamese,
                      category: word.category,
                      englishAudio: word.englishAudio,
                      vietnameseAudio: word.vietnameseAudio,
                      isVietnamese: isVietnamese,
                      favourite: favouriteIds.contains(
                        '${word.id}_${isVietnamese ? 'vietnamese' : 'english'}',
                      ),
                      onFavouriteChanged: _loadFavourites,
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
