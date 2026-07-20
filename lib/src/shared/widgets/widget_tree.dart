import 'dart:async';

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
            : _AuthenticatedShell(auth: gateway);
      },
    );
  }
}

class _AuthenticatedShell extends StatefulWidget {
  const _AuthenticatedShell({required this.auth});

  final AuthGateway auth;

  @override
  State<_AuthenticatedShell> createState() => _AuthenticatedShellState();
}

class _AuthenticatedShellState extends State<_AuthenticatedShell>
    with WidgetsBindingObserver {
  Timer? _heartbeat;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _resumePresence();
  }

  void _resumePresence() {
    _heartbeat?.cancel();
    unawaited(_touchPresence());
    _heartbeat = Timer.periodic(
      const Duration(minutes: 1),
      (_) => unawaited(_touchPresence()),
    );
  }

  Future<void> _touchPresence() async {
    try {
      await widget.auth.updatePresence();
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _resumePresence();
    } else {
      _heartbeat?.cancel();
      _heartbeat = null;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _heartbeat?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      MainScaffold(initialIndex: 0, auth: widget.auth);
}
