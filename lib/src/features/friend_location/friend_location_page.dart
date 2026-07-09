import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../shared/shared.dart';

class FriendLocationPage extends StatelessWidget {
  const FriendLocationPage({super.key});

  static void _ignoreNavTap(int index) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blush,
      bottomNavigationBar: const AppBottomNav(
        currentIndex: 3,
        onItemSelected: _ignoreNavTap,
      ),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.figmaFrameWidth,
            ),
            child: const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.bottomNavHeight + AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _FriendLocationHeader(),
                  SizedBox(height: AppSpacing.lg),
                  Expanded(child: _MapPreview()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FriendLocationHeader extends StatelessWidget {
  const _FriendLocationHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Friend Location',
                style: GoogleFonts.gulzar(
                  color: Colors.black,
                  fontSize: 32,
                  fontWeight: FontWeight.w400,
                  height: 38 / 32,
                  letterSpacing: 0,
                ),
              ),
              Text(
                'Nearby friends',
                style: GoogleFonts.inter(
                  color: AppColors.textSoft,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 18 / 14,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
            color: Colors.white.withValues(alpha: 0.42),
          ),
          alignment: Alignment.center,
          child: Text(
            'District 1',
            style: GoogleFonts.inter(
              color: AppColors.pine,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _MapPreview extends StatelessWidget {
  const _MapPreview();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            blurRadius: 28,
            color: AppColors.pine.withValues(alpha: 0.12),
            offset: const Offset(0, 16),
            spreadRadius: -12,
          ),
        ],
        color: const Color(0xFFE6DED2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            const _MapGrid(),
            Positioned(
              left: AppSpacing.lg,
              top: AppSpacing.lg,
              child: Text(
                'Map preview',
                style: GoogleFonts.inter(
                  color: AppColors.pine,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ),
            Positioned(
              right: AppSpacing.lg,
              top: AppSpacing.lg,
              child: _MapActionButton(
                icon: Icons.my_location_outlined,
                label: 'Current location',
                onTap: () {},
              ),
            ),
            const Positioned(
              left: 74,
              top: 168,
              child: _MapPinDot(),
            ),
            const Positioned(
              right: 88,
              top: 252,
              child: _MapPinDot(isPrimary: true),
            ),
            const Positioned(
              left: 160,
              bottom: 160,
              child: _MapPinDot(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapActionButton extends StatelessWidget {
  const _MapActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: SizedBox(
        height: 42,
        width: 42,
        child: FilledButton(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.72),
            foregroundColor: AppColors.pine,
            padding: EdgeInsets.zero,
            shape: const CircleBorder(),
          ),
          child: Icon(icon, size: 22),
        ),
      ),
    );
  }
}

class _MapGrid extends StatelessWidget {
  const _MapGrid();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MapGridPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.42)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 18;
    final thinRoadPaint = Paint()
      ..color = AppColors.pine.withValues(alpha: 0.10)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5;

    canvas.drawLine(
      Offset(-20, size.height * 0.28),
      Offset(size.width + 20, size.height * 0.12),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.16, -20),
      Offset(size.width * 0.82, size.height + 20),
      roadPaint,
    );
    canvas.drawLine(
      Offset(-20, size.height * 0.72),
      Offset(size.width + 20, size.height * 0.54),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.30, -20),
      Offset(size.width * 0.42, size.height + 20),
      thinRoadPaint,
    );
    canvas.drawLine(
      Offset(-20, size.height * 0.42),
      Offset(size.width + 20, size.height * 0.80),
      thinRoadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapPinDot extends StatelessWidget {
  const _MapPinDot({this.isPrimary = false});

  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final size = isPrimary ? 34.0 : 26.0;

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            color: AppColors.pine.withValues(alpha: 0.25),
            offset: const Offset(0, 6),
          ),
        ],
        color: isPrimary ? AppColors.pine : const Color(0xFF93CF75),
        shape: BoxShape.circle,
      ),
    );
  }
}
