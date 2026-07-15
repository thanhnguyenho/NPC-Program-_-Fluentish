import 'package:flutter/material.dart';

/// Fluentish Community Page (Exact Figma Page 14/42 Scrollable UI)
/// Recreates Images 1 & 2 perfectly with compact, elegant layout:
/// - Active Friends horizontal/grid compact cards
/// - Find a Friend interactive-style Map Card + Locate button
/// - Friend Note Activity List (Chris OMW / Vĩnh Tiến Library later) + Reply & Route buttons
/// - Find your Way Route Card (District 1 Walk)
/// - Connect with Fluentish social footer
class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final Color _bgPastelRose = const Color(0xFFF8EDED);
  final Color _primaryOlive = const Color(0xFF3E4E31);
  final Color _cardCream = const Color(0xFFF3ECE5);
  final Color _textSubOlive = const Color(0xFF6B7E5D);
  final Color _greenOnline = const Color(0xFF58D668);

  final List<Map<String, dynamic>> _activeFriends = [
    {'name': 'Chloe', 'icon': Icons.pets, 'color': const Color(0xFF4A6572)},
    {'name': 'Chris', 'icon': Icons.people_alt, 'color': const Color(0xFF2C3E50)},
    {'name': 'AnhQuan', 'icon': Icons.person, 'color': const Color(0xFFD32F2F)},
    {'name': 'Mary', 'icon': Icons.face_3, 'color': const Color(0xFF8E44AD)},
    {'name': 'Minh', 'icon': Icons.camera_alt, 'color': const Color(0xFF16A085)},
    {'name': 'Vĩnh Tiến', 'icon': Icons.cruelty_free, 'color': const Color(0xFFB7950B)},
    {'name': 'Tấn Phát', 'icon': Icons.directions_walk, 'color': const Color(0xFF27AE60)},
    {'name': 'Keem', 'icon': Icons.workspace_premium, 'color': const Color(0xFFF39C12)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPastelRose,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Title & Subtitle
              Text(
                'Fluentish Community',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: _primaryOlive,
                  fontFamily: 'Georgia',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Let's see what your friends are up to!",
                style: TextStyle(
                  fontSize: 14,
                  color: _textSubOlive,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 22),

              // 2. Active Friends Section (Compact & Proportional Grid)
              _buildSectionTitle('Active Friends'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                decoration: BoxDecoration(
                  color: _cardCream,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(8),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 18,
                  alignment: WrapAlignment.spaceAround,
                  children: _activeFriends.map((f) {
                    return SizedBox(
                      width: 72,
                      child: _buildFriendAvatarCard(
                        f['name'] as String,
                        f['icon'] as IconData,
                        f['color'] as Color,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 26),

              // 3. Find a Friend Section (Map Card + Notes list below)
              _buildSectionTitle('Find a Friend'),
              const SizedBox(height: 12),
              _buildFindAFriendMapCard(),
              const SizedBox(height: 14),

              // Friend notes cards matching Figma (Chris OMW & Vĩnh Tiến Library later)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _cardCream,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(8),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildFriendNoteRow(
                      nameTitle: 'Chris: OMW in 8 min.',
                      subtitle: 'Cafe meetup near campus',
                      avatarIcon: Icons.people_alt,
                      avatarColor: const Color(0xFF2C3E50),
                      btnText: 'Reply',
                      onBtnTap: () => _showActionToast('Replying to Chris...'),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: Colors.black12, height: 1),
                    ),
                    _buildFriendNoteRow(
                      nameTitle: 'Vĩnh Tiến: Library later.',
                      subtitle: 'Close to your current spot',
                      avatarIcon: Icons.cruelty_free,
                      avatarColor: const Color(0xFFB7950B),
                      btnText: 'Route',
                      onBtnTap: () => _showActionToast('Routing to Vĩnh Tiến...'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // 4. Find your Way Section
              _buildSectionTitle('Find your Way'),
              const SizedBox(height: 12),
              _buildFindYourWayRouteCard(),
              const SizedBox(height: 32),

              // 5. Connect with Fluentish Footer Card
              _buildConnectFooterCard(),
              const SizedBox(height: 14),

              Center(
                child: Text(
                  '© 2026 Fluentish. All rights reserved.',
                  style: TextStyle(
                    fontSize: 12,
                    color: _textSubOlive.withAlpha(180),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: _primaryOlive,
        fontFamily: 'Georgia',
      ),
    );
  }

  Widget _buildFriendAvatarCard(String name, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withAlpha(25),
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            Positioned(
              right: 2,
              bottom: 2,
              child: Container(
                width: 13,
                height: 13,
                decoration: BoxDecoration(
                  color: _greenOnline,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _primaryOlive,
          ),
        ),
      ],
    );
  }

  Widget _buildFindAFriendMapCard() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Custom Campus Street Map Painter
            CustomPaint(
              size: const Size(double.infinity, 220),
              painter: _CampusMapPainter(),
            ),

            // Top-left floating info card ("8 nearby · 2 close enough to meet")
            Positioned(
              left: 14,
              top: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(245),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '8 nearby',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: _primaryOlive,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '2 close enough to meet',
                      style: TextStyle(
                        fontSize: 12,
                        color: _textSubOlive,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom-right floating Locate button
            Positioned(
              right: 14,
              bottom: 14,
              child: ElevatedButton(
                onPressed: () => _showActionToast('Locating campus meetup spot...'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryOlive,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  'Locate',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendNoteRow({
    required String nameTitle,
    required String subtitle,
    required IconData avatarIcon,
    required Color avatarColor,
    required String btnText,
    required VoidCallback onBtnTap,
  }) {
    return Row(
      children: [
        Stack(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: avatarColor.withAlpha(30),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(avatarIcon, color: avatarColor, size: 24),
            ),
            Positioned(
              right: 1,
              bottom: 1,
              child: Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  color: _greenOnline,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nameTitle,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: _primaryOlive,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12.5,
                  color: _textSubOlive,
                ),
              ),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: onBtnTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7E9866),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            btnText,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildFindYourWayRouteCard() {
    return Container(
      decoration: BoxDecoration(
        color: _cardCream,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 140,
              child: CustomPaint(
                painter: _RouteMapPainter(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'District 1 Walk',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _primaryOlive,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Saved route with food phrases and coffee stops.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: _textSubOlive,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => _showActionToast('Opening District 1 Walk Route...'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryOlive,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Route',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectFooterCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _cardCream,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _primaryOlive.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.people_alt_rounded, color: _primaryOlive, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'Connect with Fluentish',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _primaryOlive,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Follow updates, community notes, and nearby language moments.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: _textSubOlive,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialBtn('fb', Icons.facebook, const Color(0xFF1877F2)),
              _buildSocialBtn('insta', Icons.camera_alt, const Color(0xFFE4405F)),
              _buildSocialBtn('tiktok', Icons.music_note, Colors.black87),
              _buildSocialBtn('mail', Icons.mail_rounded, _primaryOlive),
              _buildSocialBtn('web', Icons.language, const Color(0xFF7E9866)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(220),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'hello@fluentish.app',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: _primaryOlive,
                  ),
                ),
                Text(
                  'Privacy · Terms',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: _textSubOlive,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialBtn(String label, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => _showActionToast('Opening $label...'),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withAlpha(60),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: _textSubOlive,
          ),
        ),
      ],
    );
  }

  void _showActionToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 1),
        backgroundColor: _primaryOlive,
      ),
    );
  }
}

class _CampusMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFE2E9DE);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final roadPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, size.height * 0.3)
      ..lineTo(size.width * 0.55, size.height * 0.45)
      ..lineTo(size.width, size.height * 0.25)
      ..moveTo(size.width * 0.4, 0)
      ..lineTo(size.width * 0.48, size.height * 0.75)
      ..lineTo(size.width * 0.8, size.height);

    canvas.drawPath(path, roadPaint);

    final bldgPaint = Paint()..color = const Color(0xFFCED6C9);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(20, 140, 110, 60),
        const Radius.circular(12),
      ),
      bldgPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width - 130, 120, 110, 70),
        const Radius.circular(12),
      ),
      bldgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RouteMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFDFE6D8);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final roadPaint = Paint()
      ..color = Colors.white.withAlpha(230)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, size.height * 0.6)
      ..lineTo(size.width * 0.6, size.height * 0.3)
      ..lineTo(size.width, size.height * 0.7);

    canvas.drawPath(path, roadPaint);

    final routePaint = Paint()
      ..color = const Color(0xFF3E4E31)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawPath(path, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
