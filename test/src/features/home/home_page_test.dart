import 'package:fluentish/src/features/home/home_page.dart';
import 'package:fluentish/src/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart' as ll;

import '../../../helpers/fakes.dart';

void main() {
  Future<void> pumpHome(
    WidgetTester tester, {
    Future<bool> Function(ll.LatLng)? launchDirections,
    VoidCallback? onNavigateToMap,
    VoidCallback? onNavigateToLanguage,
    VoidCallback? onNavigateToSoundboard,
    ValueChanged<FavouritePhraseRecord>? onOpenFavouritePhrase,
    FavouriteDataSource? favouriteRepository,
    Future<void> Function(FavouritePhraseRecord)? phrasePlayback,
    Future<void> Function(FavouriteSoundboardRecord)? soundboardPlayback,
  }) async {
    tester.view.physicalSize = const Size(393, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: HomeScreen(
            onNavigateToMap: onNavigateToMap ?? () {},
            onNavigateToLanguage: onNavigateToLanguage,
            onNavigateToSoundboard: onNavigateToSoundboard,
            onOpenFavouritePhrase: onOpenFavouritePhrase,
            auth: FakeAuthGateway(),
            friendRepository: FakeFriendDataSource(),
            favouriteRepository:
                favouriteRepository ?? FakeFavouriteDataSource(),
            locationRepository: FakeLocationDataSource(),
            launchDirections: launchDirections,
            phrasePlayback: phrasePlayback,
            soundboardPlayback: soundboardPlayback,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('shows the nearest place from each recommendation group', (
    tester,
  ) async {
    await pumpHome(tester);

    expect(find.text('Sample Cafe'), findsOneWidget);
    expect(find.text('Sample Cinema'), findsOneWidget);
    expect(find.text('Sample Museum'), findsOneWidget);
    expect(find.text('Far Restaurant'), findsNothing);
    expect(find.textContaining('Cafe'), findsWidgets);
    expect(find.textContaining('Movie Theatre'), findsOneWidget);
    expect(find.textContaining('Museum'), findsWidgets);
    expect(
      find.text('A relaxed cafe for coffee and conversation.'),
      findsOneWidget,
    );
    expect(find.textContaining('Cinema in District 1.'), findsOneWidget);
    expect(find.byIcon(Icons.local_cafe), findsOneWidget);
    expect(find.byIcon(Icons.movie), findsOneWidget);
    expect(find.byIcon(Icons.museum), findsOneWidget);
  });

  testWidgets('tapping a recommendation launches directions', (tester) async {
    ll.LatLng? destination;
    await pumpHome(
      tester,
      launchDirections: (value) async {
        destination = value;
        return true;
      },
    );

    await tester.tap(find.text('Sample Cafe'));
    await tester.pump();

    expect(destination?.latitude, 10.775);
    expect(destination?.longitude, 106.701);
  });

  testWidgets('See all opens the map callback', (tester) async {
    var openedMap = false;
    await pumpHome(
      tester,
      onNavigateToMap: () => openedMap = true,
    );

    await tester.tap(find.text('See all'));
    await tester.pump();

    expect(openedMap, isTrue);
  });

  testWidgets('prompts the user when neither favourite collection has data', (
    tester,
  ) async {
    await pumpHome(tester);

    expect(find.text('Favourite Phrases'), findsOneWidget);
    expect(find.text('Favourite Soundboard Bites'), findsOneWidget);
    expect(
      find.text(
        'No favourite phrases yet. Add phrases from the Language screen '
        'to see them here.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'No favourite soundboard bites yet. Add sounds from the Soundboard '
        'screen to see them here.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('plays favourite phrases and soundboard bites from home', (
    tester,
  ) async {
    String? playedPhraseId;
    String? playedSoundboardId;
    await pumpHome(
      tester,
      favouriteRepository: FakeFavouriteDataSource(
        phrases: const [sampleFavouritePhrase],
        soundboardBites: const [sampleFavouriteSoundboard],
      ),
      phrasePlayback: (phrase) async => playedPhraseId = phrase.id,
      soundboardPlayback: (bite) async => playedSoundboardId = bite.id,
    );

    expect(find.text('How are you?'), findsOneWidget);
    expect(find.text('Bạn khỏe không?'), findsOneWidget);
    expect(find.text('Hello'), findsOneWidget);
    expect(find.text('Xin chào'), findsOneWidget);

    final phraseButton = find.byKey(
      const ValueKey('play-phrase-phrase-how-are-you'),
    );
    await tester.ensureVisible(phraseButton);
    await tester.tap(phraseButton);
    await tester.pump();
    expect(playedPhraseId, sampleFavouritePhrase.id);

    final soundboardButton = find.byKey(
      const ValueKey('play-soundboard-soundboard-hello'),
    );
    await tester.ensureVisible(soundboardButton);
    await tester.tap(soundboardButton);
    await tester.pump();
    expect(playedSoundboardId, sampleFavouriteSoundboard.id);
  });

  testWidgets('tapping a phrase card opens it in the language flow', (
    tester,
  ) async {
    FavouritePhraseRecord? openedPhrase;
    await pumpHome(
      tester,
      favouriteRepository: FakeFavouriteDataSource(
        phrases: const [sampleFavouritePhrase],
      ),
      onOpenFavouritePhrase: (phrase) => openedPhrase = phrase,
    );

    final phraseText = find.text('How are you?');
    await tester.ensureVisible(phraseText);
    await tester.tap(phraseText);
    await tester.pump();

    expect(openedPhrase?.id, sampleFavouritePhrase.id);
  });

  testWidgets('filled stars remove both Firestore favourites', (tester) async {
    final favourites = FakeFavouriteDataSource(
      phrases: const [sampleFavouritePhrase],
      soundboardBites: const [sampleFavouriteSoundboard],
    );
    await pumpHome(tester, favouriteRepository: favourites);

    final phraseStar = find.byKey(
      const ValueKey('remove-phrase-phrase-how-are-you'),
    );
    await tester.ensureVisible(phraseStar);
    await tester.tap(phraseStar);
    await tester.pumpAndSettle();
    expect(favourites.removedPhraseIds, [sampleFavouritePhrase.id]);
    expect(find.text('How are you?'), findsNothing);

    final soundboardStar = find.byKey(
      const ValueKey('remove-soundboard-soundboard-hello'),
    );
    await tester.ensureVisible(soundboardStar);
    await tester.tap(soundboardStar);
    await tester.pumpAndSettle();
    expect(
      favourites.removedSoundboardIds,
      [sampleFavouriteSoundboard.id],
    );
    expect(find.text('Hello'), findsNothing);
  });

  testWidgets('empty favourite actions open their source screens', (
    tester,
  ) async {
    var openedLanguage = false;
    var openedSoundboard = false;
    await pumpHome(
      tester,
      onNavigateToLanguage: () => openedLanguage = true,
      onNavigateToSoundboard: () => openedSoundboard = true,
    );

    final phraseAction = find.text('Browse phrases');
    await tester.ensureVisible(phraseAction);
    await tester.tap(phraseAction);
    await tester.pump();
    expect(openedLanguage, isTrue);

    final soundboardAction = find.text('Open soundboard');
    await tester.ensureVisible(soundboardAction);
    await tester.tap(soundboardAction);
    await tester.pump();
    expect(openedSoundboard, isTrue);
  });
}
