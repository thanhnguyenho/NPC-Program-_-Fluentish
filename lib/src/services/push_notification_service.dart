class PushRegistrationResult {
  const PushRegistrationResult.demo()
      : enabled = true,
        simulated = true;

  final bool enabled;
  final bool simulated;
}

/// Demo notification service used when FCM/APNs credentials are unavailable.
///
/// It deliberately avoids requesting native permissions or contacting Firebase
/// Messaging. Settings remain usable, while the UI clearly labels simulated
/// notifications so they cannot be mistaken for real background delivery.
class PushNotificationService {
  static const bool isDemoMode = true;

  Future<PushRegistrationResult> requestPermissionAndRegister() async {
    return const PushRegistrationResult.demo();
  }

  Future<void> unregister() async {}
}
