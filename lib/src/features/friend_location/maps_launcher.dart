import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

Uri buildGoogleMapsDirectionsUri(LatLng destination) {
  return Uri.https('www.google.com', '/maps/dir/', {
    'api': '1',
    'destination': '${destination.latitude},${destination.longitude}',
    'travelmode': 'walking',
  });
}

Future<bool> launchGoogleMapsDirections(LatLng destination) {
  return launchUrl(
    buildGoogleMapsDirectionsUri(destination),
    mode: LaunchMode.externalApplication,
  );
}
