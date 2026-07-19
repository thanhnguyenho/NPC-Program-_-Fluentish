class LocationDetectionException implements Exception {
  const LocationDetectionException(this.message);

  final String message;
}

class LocationDetectionResult {
  const LocationDetectionResult({
    required this.language,
    required this.countryName,
  });

  final String language;
  final String countryName;
}

class LocationLanguageService {
  Future<LocationDetectionResult> detect() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return const LocationDetectionResult(
      language: 'English',
      countryName: 'Current region',
    );
  }
}
