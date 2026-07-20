import 'package:flutter/material.dart';
import 'package:fluentish/src/shared/shared.dart';

class LanguageToggle extends StatelessWidget {
  final bool isVietnamese;
  final VoidCallback onToggle;

  const LanguageToggle({
    super.key,
    required this.isVietnamese,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.fluentishColors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Container(
            width: 66,
            height: 32,
            decoration: BoxDecoration(
              color: isVietnamese ? colors.accent : colors.surfaceStrong,
              borderRadius: BorderRadius.circular(20),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 150),
              alignment:
                  isVietnamese ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: colors.surface,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.asset(
                    isVietnamese
                        ? 'assets/images/Vietnam-Flag.webp'
                        : 'assets/images/UK-Flag.webp',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isVietnamese ? 'Tiếng Việt' : 'English',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }
}
