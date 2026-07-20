// ignore: unused_import
// import 'package:fluentish/debug_menu.dart';
import 'package:flutter/material.dart';

import 'package:fluentish/src/shared/theme/app_theme.dart';
import 'package:fluentish/src/shared/services/auth_service.dart';
import 'package:fluentish/src/services/settings_controller.dart';
// import 'src/features/navigation/main_scaffold.dart';
import 'src/shared/widgets/widget_tree.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SettingsController.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.auth});

  final AuthGateway? auth;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SettingsController.instance,
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Fluentish',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: SettingsController.instance.themeMode,
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context);
          return MediaQuery(
            data: mediaQuery.copyWith(
              textScaler: TextScaler.linear(
                SettingsController.instance.textSize.scale,
              ),
            ),
            child: child!,
          );
        },
        home: WidgetTree(auth: auth),
      ),
    );
  }
}
