import 'package:flutter/material.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  String _selectedMood = 'Coffee';
  String _selectedDuration = '30 min';
  final TextEditingController _noteController =
      TextEditingController(text: 'Cafe after class?');

  final Color _primaryOlive = const Color(0xFF3E4E31);
  final Color _lightRose = const Color(0xFFF8EDED);

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E9E2),
      body: Stack(
        children: [
          // 1. Stylized Campus Map Background with University Streets & Buildings
          _buildCampusBackgroundMap(),

          // 2. Friends Nearby Avatars & Status Bubbles on Map
          _buildFriendMapMarkers(),

          // 3. Top Header Bar ("Friend Location - Posting my note" & "Note" Pill)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _lightRose.withAlpha(235),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: Color(0xFF3E4E31),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Friend Location',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _primaryOlive,
                            ),
                          ),
                          const Text(
                            'Posting my note',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _primaryOlive,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF98E37E),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Note',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. Draggable Scrollable Bottom Sheet ("Post a Note")
          _buildPostANoteBottomSheet(),
        ],
      ),
    );
  }

  // Map representation matching Figma Page 14 campus layout
  Widget _buildCampusBackgroundMap() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _CampusMapPainter(),
      ),
    );
  }

  // Friend Map Markers matching Figma Page 14
  Widget _buildFriendMapMarkers() {
    return Stack(
      children: [
        // Top Left: Cat Avatar
        Positioned(
          top: 130,
          left: 45,
          child: _buildAvatarMarker(
            label: null,
            iconBadge: Icons.coffee,
            borderColor: Colors.amber.shade200,
            imageText: '🐱',
          ),
        ),

        // Top Right: 2 Friends Selfie
        Positioned(
          top: 190,
          right: 55,
          child: _buildAvatarMarker(
            label: null,
            iconBadge: Icons.auto_awesome,
            borderColor: _primaryOlive.withAlpha(100),
            imageText: '👭',
          ),
        ),

        // Center Left: Tấn Phát ("On campus")
        Positioned(
          top: 410,
          left: 30,
          child: _buildAvatarMarker(
            label: 'Tấn Phát',
            statusBubble: 'On campus',
            borderColor: Colors.green.shade300,
            imageText: '👦🏻',
          ),
        ),

        // Center: Friend with chat badge
        Positioned(
          top: 360,
          left: 125,
          child: _buildAvatarMarker(
            label: null,
            statusBubble: 'Library later',
            iconBadge: Icons.chat_bubble_outline,
            borderColor: Colors.pink.shade200,
            imageText: '👧🏻',
          ),
        ),

        // Center Right: Keem ("New vocab", Kanji 金)
        Positioned(
          top: 330,
          right: 40,
          child: _buildAvatarMarker(
            label: 'Keem',
            statusBubble: 'New vocab',
            borderColor: Colors.amber.shade300,
            imageText: '金',
            isKanji: true,
          ),
        ),

        // Center Right Lower: Friend ("Free now")
        Positioned(
          top: 460,
          right: 60,
          child: _buildAvatarMarker(
            label: null,
            statusBubble: 'Free now',
            iconBadge: Icons.headphones,
            borderColor: Colors.teal.shade200,
            imageText: '🎧',
          ),
        ),

        // Center User Location Pulse Ring
        Positioned(
          top: 470,
          left: 175,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withAlpha(40),
              border: Border.all(color: Colors.blue.shade300, width: 2),
            ),
            child: Center(
              child: Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF6B8DB9),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 28),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarMarker({
    String? label,
    String? statusBubble,
    IconData? iconBadge,
    required Color borderColor,
    required String imageText,
    bool isKanji = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (statusBubble != null)
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _primaryOlive,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              statusBubble,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: borderColor, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  imageText,
                  style: TextStyle(
                    fontSize: isKanji ? 24 : 26,
                    fontWeight: isKanji ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
            if (iconBadge != null)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 4),
                    ],
                  ),
                  child: Icon(iconBadge, size: 14, color: _primaryOlive),
                ),
              ),
          ],
        ),
        if (label != null)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 4),
              ],
            ),
            child: Text(
              label,
              style: TextStyle(
                color: _primaryOlive,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  // Draggable Scrollable Bottom Sheet matching Figma Page 14
  Widget _buildPostANoteBottomSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.35,
      maxChildSize: 0.82,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: _lightRose,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 15,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Drag Handle Pill
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(35),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Post a Note',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: _primaryOlive,
                      ),
                    ),
                    const Text(
                      'friends nearby',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Note Input Field Card ("Cafe after class?")
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _noteController,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 16,
                      color: _primaryOlive,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Share what you are up to...',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Mood Filter Row
                Text(
                  'Mood',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _primaryOlive,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: ['Coffee', 'Study', 'Free', 'Busy'].map((mood) {
                    final isSelected = _selectedMood == mood;
                    return ChoiceChip(
                      label: Text(
                        mood,
                        style: TextStyle(
                          color: isSelected ? Colors.white : _primaryOlive,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: _primaryOlive,
                      backgroundColor: _primaryOlive.withAlpha(35),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedMood = mood);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Duration & Distance Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Duration',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _primaryOlive,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 16, color: _primaryOlive),
                        const SizedBox(width: 4),
                        const Text(
                          'Current location · 0.0 km',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Action Pills & Buttons Row
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ...['30 min', '1 hr', 'Today'].map((dur) {
                      final isSelected = _selectedDuration == dur;
                      return ChoiceChip(
                        label: Text(
                          dur,
                          style: TextStyle(
                            color: isSelected ? Colors.white : _primaryOlive,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: _primaryOlive,
                        backgroundColor: _primaryOlive.withAlpha(35),
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedDuration = dur);
                        },
                      );
                    }),
                    ActionChip(
                      label: const Text('Cancel'),
                      backgroundColor: Colors.white,
                      onPressed: () {},
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryOlive,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 12),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Note posted: "${_noteController.text}" ($_selectedMood)'),
                            backgroundColor: _primaryOlive,
                          ),
                        );
                      },
                      child: const Text('Post',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Stylized Campus Street Map Painter
class _CampusMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFE2E7DE);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final roadPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round;

    // Draw stylized campus roads
    final path = Path()
      ..moveTo(0, size.height * 0.25)
      ..lineTo(size.width * 0.5, size.height * 0.35)
      ..lineTo(size.width, size.height * 0.2)
      ..moveTo(size.width * 0.35, 0)
      ..lineTo(size.width * 0.45, size.height * 0.7)
      ..lineTo(size.width * 0.8, size.height);

    canvas.drawPath(path, roadPaint);

    // Draw building blocks
    final buildingPaint = Paint()..color = const Color(0xFFD6DDD0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(20, 180, 110, 80),
        const Radius.circular(12),
      ),
      buildingPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width - 140, 260, 120, 90),
        const Radius.circular(12),
      ),
      buildingPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
