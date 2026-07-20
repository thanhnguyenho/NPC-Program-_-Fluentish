import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<bool> requestPermissionAndRegister() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      final granted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;
      if (!granted) return false;

      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      final token = await _messaging.getToken();
      final user = FirebaseAuth.instance.currentUser;
      if (token == null || user == null) return false;

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {
          'notificationTokens': FieldValue.arrayUnion([token]),
        },
        SetOptions(merge: true),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> unregister() async {
    try {
      final token = await _messaging.getToken();
      final user = FirebaseAuth.instance.currentUser;
      if (token != null && user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
          {
            'notificationTokens': FieldValue.arrayRemove([token]),
          },
          SetOptions(merge: true),
        );
      }
      await _messaging.deleteToken();
    } catch (_) {
      // The preference remains disabled even if a stale token cannot be
      // removed while the device is offline.
    }
  }
}
