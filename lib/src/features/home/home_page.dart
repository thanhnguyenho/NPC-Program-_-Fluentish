import 'package:flutter/material.dart';
import 'package:fluentish/src/shared/widgets/app_bottom_nav.dart';
// import 'package:fluentish/src/features/language/language_page.dart';
// import 'package:fluentish/src/features/soundboard/soundboard_page.dart';
// import 'package:fluentish/src/features/community/community_page.dart';
// import 'package:fluentish/src/features/profile/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final _pages = const [
    HomeScreen(),
    //LanguagePage(),
    //SoundboardPage(),
    //CommunityPage(),
    //ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Text('Home page'),
      ),
    );
  }
}
