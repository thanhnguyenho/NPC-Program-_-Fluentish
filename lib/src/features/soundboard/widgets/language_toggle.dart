import 'package:flutter/material.dart';

class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 78,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFFF8F8F),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Color(0xFFE32222),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  "🇻🇳",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 6),
        const Text(
          "Tiếng Việt",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
