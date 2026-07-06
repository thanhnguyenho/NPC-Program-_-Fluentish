import 'package:flutter/material.dart';

class WordCard extends StatelessWidget {
  final String english;
  final String vietnamese;
  final bool favourite;

  const WordCard({
    super.key,
    required this.english,
    required this.vietnamese,
    this.favourite = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5F1).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  english,
                  style: const TextStyle(
                    color: Color(0xFF3E4E31),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(
                favourite
                ? Icons.star
                : Icons.star_border,
                color: favourite
                ? Color(0xFFFFF8A6)
                : Colors.grey,
              ),
            ],
          ),

          const SizedBox(height: 5),
          Text(
            vietnamese,
            style: TextStyle(
              color: Color(0xFF3E4E31),
              fontSize: 16,
            ),
          ),
          
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF3E4E31).withValues(alpha:0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.volume_up,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
