import 'package:fluentish/src/features/friend_location/maps_launcher.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  test('buildGoogleMapsDirectionsUri creates a walking directions URL', () {
    final uri = buildGoogleMapsDirectionsUri(const LatLng(10.7769, 106.7009));

    expect(uri.scheme, 'https');
    expect(uri.host, 'www.google.com');
    expect(uri.path, '/maps/dir/');
    expect(uri.queryParameters['api'], '1');
    expect(uri.queryParameters['destination'], '10.7769,106.7009');
    expect(uri.queryParameters['travelmode'], 'walking');
  });
}
