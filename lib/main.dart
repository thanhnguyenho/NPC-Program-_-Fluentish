import 'package:flutter/material.dart';

import 'src/shared/theme/app_theme.dart';

void main() {
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
      home: const Scaffold(),
    );
  }
}
