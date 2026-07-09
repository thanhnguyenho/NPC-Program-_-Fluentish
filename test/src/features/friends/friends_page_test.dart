import 'package:fluentish/src/features/friends/friends_page.dart';
import 'package:fluentish/src/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Friends page shows today plan section', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const FriendsPage(),
      ),
    );

    expect(find.text('Today’s Plan'), findsOneWidget);
    expect(find.text('1. Practice 5 food phrases'), findsOneWidget);
    expect(find.text('2. Start District 1 Walk'), findsOneWidget);
    expect(find.text('3. Message a nearby friend'), findsOneWidget);
  });
}
