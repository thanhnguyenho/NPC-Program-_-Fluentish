import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';

import 'package:fluentish/main.dart';
import 'package:fluentish/src/shared/theme/app_colors.dart';

// Mock Firebase Platform
class MockFirebasePlatform extends FirebasePlatform {
  @override
  Future<FirebaseAppPlatform> initializeApp({
    required String name,
    required FirebaseOptions options,
  }) async {
    return MockFirebaseApp();
  }

  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    return MockFirebaseApp();
  }

  @override
  List<FirebaseAppPlatform> get apps => [MockFirebaseApp()];
}

class MockFirebaseApp extends FirebaseAppPlatform {
  @override
  String get name => 'fluentish';

  @override
  FirebaseOptions get options => FirebaseOptions(
    apiKey: 'mock-api-key',
    appId: 'mock-app-id',
    messagingSenderId: 'mock-sender-id',
    projectId: 'mock-project-id',
  );

  @override
  Future<void> delete() async {}
}

void main() {
  setUpAll(() async {
    // Mock Firebase before running tests
    FirebasePlatform.instance = MockFirebasePlatform();
  });

  testWidgets('Fluentish app starts with the shared theme', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

    expect(materialApp.title, 'Fluentish');
    expect(materialApp.theme?.colorScheme.primary, AppColors.pine);
    expect(find.byType(Scaffold), findsWidgets);
  });
}
