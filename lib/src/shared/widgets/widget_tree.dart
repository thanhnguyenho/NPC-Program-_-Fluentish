import 'package:fluentish/src/shared/services/auth_service.dart';
import 'package:fluentish/src/features/home/home_page.dart';
import 'package:fluentish/src/features/welcome/welcome_page.dart';
import 'package:flutter/material.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    //this updates whenever user logs in or out
    return StreamBuilder(
      stream: Auth().authStateChanges,
      //on change, check if user is (succesfully) logged in
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          //if logged in, show home screen
          return const HomePage();
        } else {
          //if not logged in, show login screen
          return const WelcomePage();
        }
      },
    );
  }
}
