import 'package:flutter/material.dart';

import '../../features/navigation/main_scaffold.dart';
import '../../features/welcome/welcome_page.dart';
import '../services/auth_service.dart';

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key, this.auth});

  final AuthGateway? auth;

  @override
  Widget build(BuildContext context) {
    final gateway = auth ?? Auth.instance;
    return StreamBuilder<String?>(
      stream: gateway.userIdChanges,
      initialData: gateway.currentUserId,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data == null
            ? const WelcomePage()
            : const MainScaffold(initialIndex: 0);
      },
    );
  }
}
