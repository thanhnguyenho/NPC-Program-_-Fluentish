import 'package:fluentish/src/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders a valid Base64 avatar image', (tester) async {
    const transparentPng =
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AvatarImage(
            radius: 24,
            base64Data: transparentPng,
            fallbackText: 'Demo User',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows initials when avatar data is invalid', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AvatarImage(
            radius: 24,
            base64Data: 'not-an-image',
            fallbackText: 'Demo User',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('D'), findsOneWidget);
  });
}
