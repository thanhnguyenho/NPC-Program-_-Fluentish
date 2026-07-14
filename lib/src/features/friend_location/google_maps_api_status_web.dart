import 'dart:js_interop';

const _googleMapsApiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');

@JS('fluentishHasGoogleMapsKey')
external JSAny? get _fluentishHasGoogleMapsKey;

@JS('Boolean')
external JSBoolean _toJsBoolean(JSAny? value);

bool get hasGoogleMapsApiKey {
  return _googleMapsApiKey.isNotEmpty ||
      _toJsBoolean(_fluentishHasGoogleMapsKey).toDart;
}
