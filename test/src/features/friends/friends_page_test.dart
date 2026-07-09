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

  testWidgets('Friends page shows friends nearby list', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const FriendsPage(),
      ),
    );

    expect(find.text('Friends nearby'), findsOneWidget);
    expect(find.text('8 friends'), findsOneWidget);
    expect(find.text('Thanh Nguyen (Chloe)'), findsOneWidget);
    expect(find.text('Chris Crowne'), findsOneWidget);
    expect(find.text('mary ⟡ ﾟ.'), findsOneWidget);
    expect(find.text('Vĩnh Tiến'), findsOneWidget);
    expect(find.text('0.2 km'), findsOneWidget);
    expect(find.text('Route'), findsOneWidget);
  });
}
