import 'package:flutter/material.dart';

import '../friend_location/friend_location_page.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FriendLocationPage(showBottomNavigation: false);
  }
}
