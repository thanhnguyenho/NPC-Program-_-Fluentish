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
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Requests'), findsOneWidget);
    expect(find.text('Nearby'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('Friends page tabs can change selection', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const FriendsPage(),
      ),
    );

    await tester.tap(find.text('Requests'));
    await tester.pumpAndSettle();

    final requestsTab = tester.widget<Semantics>(
      find.byKey(const ValueKey('friends-tab-Requests')),
    );

    expect(requestsTab.properties.selected, isTrue);
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
    expect(find.text('Vĩnh Tiến'), findsWidgets);
    expect(find.text('0.2 km'), findsOneWidget);
    expect(find.text('Route'), findsWidgets);
  });

  testWidgets('Friends page shows close now routes', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const FriendsPage(),
      ),
    );

    expect(find.text('Close Now'), findsOneWidget);
    expect(find.text('Nearest friends with route shortcuts'), findsOneWidget);
    expect(find.text('2 nearby'), findsOneWidget);
    expect(find.text('0.2 km · 5 min walk'), findsOneWidget);
    expect(find.text('0.4 km · 8 min walk'), findsOneWidget);
    expect(find.text('Route'), findsNWidgets(3));
  });

  testWidgets('Friends page shows footer and bottom nav', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const FriendsPage(),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Soundboard'), findsOneWidget);
    expect(find.text('Community'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Connect with Fluentish'), findsOneWidget);
    expect(find.text('hello@fluentish.app'), findsOneWidget);
    expect(find.text('Privacy · Terms'), findsOneWidget);
    expect(find.text('© 2026 Fluentish. All rights reserved.'), findsOneWidget);
  });
}
