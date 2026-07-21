import 'package:fluentish/src/features/language/language_page.dart';
import 'package:fluentish/src/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';

void main() {
  testWidgets('saving a translation adds it to favourite phrases', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final favourites = FakeFavouriteDataSource();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: LanguagePage(
          initialSourceText: 'Hello',
          initialTargetText: 'Xin chào',
          initialSourceLang: 'English',
          initialTargetLang: 'Vietnamese',
          auth: FakeAuthGateway(),
          favouriteRepository: favourites,
        ),
      ),
    );
    await tester.pump();

    final saveButton = find.byTooltip('Save to favourites');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pump();

    expect(favourites.phrases, hasLength(1));
    expect(favourites.phrases.single.sourceText, 'Hello');
    expect(favourites.phrases.single.translatedText, 'Xin chào');
    expect(find.text('Saved to Favourites!'), findsOneWidget);
    expect(find.byTooltip('Remove from favourites'), findsOneWidget);
  });
}
