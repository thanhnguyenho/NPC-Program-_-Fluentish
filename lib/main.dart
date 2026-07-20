// ignore: unused_import
// import 'package:fluentish/debug_menu.dart';
import 'package:flutter/material.dart';

import 'package:fluentish/src/shared/theme/app_theme.dart';
import 'package:fluentish/src/shared/services/auth_service.dart';
// import 'src/features/navigation/main_scaffold.dart';
import 'src/shared/widgets/widget_tree.dart';
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
  const MyApp({super.key, this.auth});

  final AuthGateway? auth;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fluentish',
      theme: AppTheme.light,
      home: WidgetTree(auth: auth),
    );
  }
}
