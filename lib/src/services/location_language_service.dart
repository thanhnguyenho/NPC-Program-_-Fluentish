import 'dart:async';

import 'package:geolocator/geolocator.dart';

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
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationDetectionException(
        'Location services are turned off. Enable them and try again.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationDetectionException(
        'Location permission was denied.',
      );
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationDetectionException(
        'Location permission is permanently denied. Enable it in device settings.',
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 15),
        ),
      );

      // Fluentish currently supports English and Vietnamese. The geographic
      // bounds cover mainland Vietnam and its major islands.
      final isInVietnam = position.latitude >= 8.0 &&
          position.latitude <= 24.0 &&
          position.longitude >= 102.0 &&
          position.longitude <= 110.8;

      return LocationDetectionResult(
        language: isInVietnam ? 'Vietnamese' : 'English',
        countryName: isInVietnam ? 'Vietnam' : 'your current region',
      );
    } on TimeoutException {
      throw const LocationDetectionException(
        'Location detection timed out. Please try again.',
      );
    } catch (error) {
      if (error is LocationDetectionException) rethrow;
      throw const LocationDetectionException(
        'Could not get your current location.',
      );
    }
  }
}
