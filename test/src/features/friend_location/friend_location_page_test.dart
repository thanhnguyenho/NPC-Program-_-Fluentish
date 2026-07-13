import 'package:fluentish/src/features/friend_location/friend_location_page.dart';
import 'package:fluentish/src/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpFriendLocation(WidgetTester tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const FriendLocationPage(),
      ),
    );
  }

  testWidgets('Friend Location page shows map shell', (tester) async {
    await pumpFriendLocation(tester);

    expect(find.text('Friend Location'), findsOneWidget);
    expect(find.text('Nearby friends'), findsOneWidget);
    expect(find.text('Map preview'), findsOneWidget);
    expect(find.text('District 1'), findsOneWidget);
    expect(find.text('4 nearby'), findsOneWidget);
    expect(find.text('Vĩnh Tiến'), findsWidgets);
    expect(find.text('"Library later. I saved the route."'), findsOneWidget);
    expect(find.bySemanticsLabel('Vĩnh Tiến avatar'), findsWidgets);
    expect(find.text('Message Vĩnh Tiến...'), findsOneWidget);
    expect(find.text("Tell Vĩnh Tiến: I'm coming"), findsOneWidget);
    expect(find.text('5 min'), findsOneWidget);
    expect(find.text('10 min'), findsOneWidget);
    expect(find.text('after class'), findsOneWidget);
    expect(find.text('Send visit note'), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);
    expect(find.text('React'), findsOneWidget);
    expect(find.text('Poke'), findsOneWidget);
    expect(find.text('Tấn Phát'), findsOneWidget);
    expect(find.text('Keem'), findsOneWidget);
    expect(find.byIcon(Icons.my_location_outlined), findsOneWidget);
    expect(find.text('Route'), findsOneWidget);
    expect(find.text('Community'), findsOneWidget);
  });

  testWidgets('Friend Location page selects a preview pin', (tester) async {
    await pumpFriendLocation(tester);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Keem').first);
    await tester.pumpAndSettle();

    expect(find.text('"New vocab drop. Come practice."'), findsOneWidget);
    expect(find.text('Message Keem...'), findsOneWidget);
  });

  testWidgets('Friend Location page uses the Figma friend avatar asset', (
    tester,
  ) async {
    await pumpFriendLocation(tester);

    final avatars = tester.widgetList<Image>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName == AppAssets.friendVinhTien,
      ),
    );

    expect(avatars, isNotEmpty);
  });
}
