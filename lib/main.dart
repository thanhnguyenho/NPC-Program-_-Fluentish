import 'package:flutter/material.dart';

import 'package:fluentish/src/features/welcome/welcome_page.dart';
import 'package:fluentish/src/shared/theme/app_theme.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fluentish',
      theme: AppTheme.light,
      home: const WelcomePage(),
    );
  }
}
