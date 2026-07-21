import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fluentish/src/features/profile_menu/profile_menu_options_page.dart';
import 'package:fluentish/src/shared/services/profile_repository.dart';
import 'package:fluentish/src/shared/theme/app_theme.dart';

void main() {
  test('validates phone and adult date of birth', () {
    expect(
      validateProfileInput(
        username: 'a!',
        phoneNumber: '+84 901 234 567',
        dateOfBirth: '01/01/2000',
        email: 'demo@example.com',
      ),
      'Username must be 3–24 characters and use only letters, numbers, or _.',
    );
    expect(
      validateProfileInput(
        username: 'demo',
        phoneNumber: '+84 901 234 567',
        dateOfBirth: '01/01/2000',
        email: 'not-an-email',
      ),
      'Enter a valid email address.',
    );
    expect(
      validateProfileInput(
        username: 'demo',
        phoneNumber: 'abc',
        dateOfBirth: '01/01/2000',
        email: 'demo@example.com',
      ),
      'Enter a valid phone number.',
    );
    expect(
      validateProfileInput(
        username: 'demo',
        phoneNumber: '+84 901 234 567',
        dateOfBirth: '01/01/2020',
        email: 'demo@example.com',
      ),
      'You must be at least 18 years old.',
    );
    expect(
      validateProfileInput(
        username: 'demo',
        phoneNumber: '+84 901 234 567',
        dateOfBirth: '01/01/2000',
        email: 'demo@example.com',
      ),
      isNull,
    );
  });

  testWidgets('shows load error and retries successfully', (tester) async {
    final repository = _FakeProfileRepository(loadFailures: 1);
    await tester.pumpWidget(_app(repository));
    await tester.pump();

    expect(find.text('Could not load your profile.'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);

    await tester.tap(find.text('Try Again'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Could not load your profile.'), findsNothing);
    expect(find.text('demo'), findsOneWidget);
  });

  testWidgets('uploads avatar and saves the returned URL', (tester) async {
    final repository = _FakeProfileRepository();
    await tester.pumpWidget(
      _app(
        repository,
        pickAvatar: () async => ProfileAvatarSelection(
          bytes: Uint8List.fromList([1, 2, 3]),
          contentType: 'image/jpeg',
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byTooltip('Change profile photo'));
    await tester.pump();
    await tester.pump();

    expect(repository.uploadedBytes, [1, 2, 3]);
    expect(
        repository.savedProfile?.avatarUrl, 'https://example.com/avatar.jpg');
    expect(find.text('Profile photo updated.'), findsOneWidget);
  });

  testWidgets('keeps save enabled after a failed save', (tester) async {
    final repository = _FakeProfileRepository(saveFailures: 1);
    await tester.pumpWidget(_app(repository));
    await tester.pump();

    final username = find.widgetWithText(TextField, 'demo');
    await tester.enterText(username, 'updated');
    await tester.ensureVisible(find.text('Save Changes'));
    await tester.tap(find.text('Save Changes'));
    await tester.pump();

    expect(find.text('Could not save your profile.'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);

    await tester.tap(find.text('Save Changes'));
    await tester.pump();
    expect(repository.savedProfile?.username, 'updated');
  });
}

Widget _app(
  ProfileDataSource repository, {
  Future<ProfileAvatarSelection?> Function()? pickAvatar,
}) {
  return MaterialApp(
    theme: AppTheme.light,
    home: ProfileMenuOptionsPage(
      repository: repository,
      pickAvatar: pickAvatar,
    ),
  );
}

class _FakeProfileRepository implements ProfileDataSource {
  _FakeProfileRepository({this.loadFailures = 0, this.saveFailures = 0});

  int loadFailures;
  int saveFailures;
  List<int>? uploadedBytes;
  EditableProfile? savedProfile;

  @override
  Future<EditableProfile> loadProfile() async {
    if (loadFailures > 0) {
      loadFailures--;
      throw StateError('offline');
    }
    return const EditableProfile(
      username: 'demo',
      dateOfBirth: '01/01/2000',
      phoneNumber: '+84 901 234 567',
      email: 'demo@example.com',
    );
  }

  @override
  Future<EditableProfile> uploadAvatar(ProfileAvatarSelection avatar) async {
    uploadedBytes = avatar.bytes.toList();
    final profile = (savedProfile ?? await loadProfile()).copyWith(
      avatarUrl: 'https://example.com/avatar.jpg',
      clearAvatarBase64: true,
    );
    savedProfile = profile;
    return profile;
  }

  @override
  Future<void> saveProfile(EditableProfile profile) async {
    if (saveFailures > 0) {
      saveFailures--;
      throw StateError('offline');
    }
    savedProfile = profile;
  }
}
