import 'package:fluentish/src/features/friend_location/friend_location_page.dart';
import 'package:fluentish/src/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Friend Location page shows map shell', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const FriendLocationPage(),
      ),
    );

    expect(find.text('Friend Location'), findsOneWidget);
    expect(find.text('Nearby friends'), findsOneWidget);
    expect(find.text('Map preview'), findsOneWidget);
    expect(find.text('District 1'), findsOneWidget);
    expect(find.byIcon(Icons.my_location_outlined), findsOneWidget);
    expect(find.text('Community'), findsOneWidget);
  });
}
