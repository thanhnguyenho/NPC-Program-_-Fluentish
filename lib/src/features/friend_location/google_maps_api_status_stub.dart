const _googleMapsApiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');

bool get hasGoogleMapsApiKey => _googleMapsApiKey.isNotEmpty;
