import 'package:fluentish/src/features/home/home_page.dart';
import 'package:fluentish/src/features/language/language_page.dart';
import 'package:fluentish/src/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';

void main() {
  testWidgets('starred Language phrase appears in Home favourites',
      (tester) async {
    tester.view.physicalSize = const Size(393, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final auth = FakeAuthGateway();
    final favourites = FakeFavouriteDataSource();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: LanguagePage(
          initialSourceText: 'How are you?',
          initialTargetText: 'Bạn khỏe không?',
          initialSourceLang: 'English',
          initialTargetLang: 'Vietnamese',
          auth: auth,
          favouriteRepository: favourites,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final star = find.byIcon(Icons.star_border).first;
    await tester.ensureVisible(star);
    await tester.tap(star);
    await tester.pumpAndSettle();

    expect(favourites.savedPhrases, hasLength(1));
    expect(favourites.savedPhrases.single.sourceText, 'How are you?');
    expect(favourites.savedPhrases.single.translatedText, 'Bạn khỏe không?');

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: HomeScreen(
            onNavigateToMap: () {},
            auth: auth,
            friendRepository: FakeFriendDataSource(),
            favouriteRepository: favourites,
            locationRepository: FakeLocationDataSource(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('How are you?'), findsOneWidget);
    expect(find.text('Bạn khỏe không?'), findsOneWidget);
  });
}
