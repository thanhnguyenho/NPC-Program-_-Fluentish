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
    expect(find.text('4 nearby'), findsOneWidget);
    expect(find.text('Vĩnh Tiến'), findsWidgets);
    expect(find.text('Library later.'), findsOneWidget);
    expect(find.text('Tấn Phát'), findsOneWidget);
    expect(find.text('Keem'), findsOneWidget);
    expect(find.byIcon(Icons.my_location_outlined), findsOneWidget);
    expect(find.text('Route'), findsOneWidget);
    expect(find.text('Community'), findsOneWidget);
  });

  testWidgets('Friend Location page selects a preview pin', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const FriendLocationPage(),
      ),
    );

    await tester.tap(find.text('Keem').first);
    await tester.pumpAndSettle();

    expect(find.text('New vocab drop.'), findsOneWidget);
  });
}
