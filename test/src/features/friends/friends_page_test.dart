import 'package:fluentish/src/features/friends/friends_page.dart';
import 'package:fluentish/src/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Friends page shows header, search, and tabs', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const FriendsPage(),
      ),
    );

    expect(find.text('Friends'), findsNWidgets(2));
    expect(find.text('Search friends...'), findsOneWidget);
    expect(find.text('Requests'), findsOneWidget);
    expect(find.text('Nearby'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
