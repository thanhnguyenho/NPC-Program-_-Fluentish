import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryFilter extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'icon': Icons.mic_none, 'label': 'All Words'},
      {'icon': Icons.star_border, 'label': 'Favourites'},
      {'icon': Icons.translate, 'label': 'Common Words'},
      {'icon': Icons.waving_hand_outlined, 'label': 'Greetings'},
      {'icon': Icons.numbers, 'label': 'Numbers'},
      {'icon': Icons.restaurant_outlined, 'label': 'Dining'},
      {'icon': Icons.shopping_cart_outlined, 'label': 'Shopping'},
      {'icon': Icons.flight_takeoff, 'label': 'Travel'},
      {'icon': Icons.local_hospital_outlined, 'label': 'Emergency'},
    ];

    return SizedBox(
      height: 45,
      child: ListView.separated(
        physics: const ClampingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = categories[index];

          final bool selected =
          category['label'] == selectedCategory;

          return GestureDetector(
            onTap: () {
              onCategorySelected(category['label'] as String);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: selected
                  ? const Color(0xFF4E5A45)
                  : const Color(0xFF868F54),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    category['icon'] as IconData,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category['label'] as String,
                    style: GoogleFonts.itim(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}