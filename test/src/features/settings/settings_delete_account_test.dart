import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fluentish/src/features/settings/settings_page.dart';
import 'package:fluentish/src/shared/services/account_deletion_service.dart';
import 'package:fluentish/src/shared/theme/app_theme.dart';

void main() {
  testWidgets('requires password and delegates account deletion',
      (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final deletion = _FakeDeletionService(requiresPassword: true);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: SettingsPage(accountDeletion: deletion),
      ),
    );
    await tester.scrollUntilVisible(
      find.text('Delete Account'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Delete Account'));
    await tester.pumpAndSettle();

    expect(find.text('Confirm your password'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, 'secret123');
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(deletion.password, 'secret123');
    expect(deletion.calls, 1);
  });

  testWidgets('keeps dialog open when account deletion fails', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final deletion = _FakeDeletionService(error: StateError('cleanup failed'));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: SettingsPage(accountDeletion: deletion),
      ),
    );
    await tester.scrollUntilVisible(
      find.text('Delete Account'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Delete Account'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pump();

    expect(find.text('Delete Account'), findsWidgets);
    expect(find.text('Could not delete your account.'), findsOneWidget);
  });
}

class _FakeDeletionService implements AccountDeletionDataSource {
  _FakeDeletionService({this.requiresPassword = false, this.error});

  @override
  final bool requiresPassword;
  final Object? error;
  int calls = 0;
  String? password;

  @override
  Future<void> deleteAccount({String? password}) async {
    calls++;
    this.password = password;
    if (error != null) throw error!;
  }
}
