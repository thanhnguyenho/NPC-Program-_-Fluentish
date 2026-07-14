import 'package:flutter/material.dart';

class LanguageToggle extends StatefulWidget {
  const LanguageToggle({super.key});

  @override
  State<LanguageToggle> createState() => _LanguageToggleState();
}

class _LanguageToggleState extends State<LanguageToggle> {
  bool isVietnamese = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isVietnamese = !isVietnamese;
            });
          },
          child: Container(
            width: 78,
            height: 38,
            decoration: BoxDecoration(
              color: isVietnamese
              ? const Color(0xFFFF8F8F)
              : const Color (0xFFD0E4FD),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Align(
            alignment: isVietnamese
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(
                  isVietnamese
                    ? 'assets/images/Vietnam-Flag.webp'
                    : 'assets/images/UK-Flag.webp',
                    width: 38,
                    height: 38,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 6),
        Text(
          isVietnamese
          ? 'Tiếng Việt'
          : 'English',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF3E4E31)
          ),
        ),
      ],
    );
  }
}
