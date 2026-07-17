import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential> register({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Creates the Firebase Auth account (email/password), then saves the
  /// rest of the profile info to Firestore under `users/{uid}`, and sets
  /// the preferred name as the Firebase displayName.
  ///
  /// If saving to Firestore fails after the auth account was already
  /// created, the exception is rethrown so the caller can show an error,
  /// but the account itself will still exist.
  Future<UserCredential> registerWithProfile({
    required String firstName,
    required String lastName,
    required String preferredName,
    required String username,
    required String email,
    required String password,
    required String dateOfBirth,
    required String phoneNumber,
  }) async {
    final credential = await register(email: email, password: password);

    final uid = credential.user?.uid;

    if (uid != null) {
      await _firestore.collection('users').doc(uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'preferredName': preferredName,
        'username': username,
        'email': email.trim(),
        'dateOfBirth': dateOfBirth,
        'phoneNumber': phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await credential.user?.updateDisplayName(preferredName);
    }

    return credential;
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(
      email: email.trim(),
    );
  }

  /// Fetches the extra profile fields stored in Firestore for the
  /// currently signed-in user (or a specific [uid] if provided).
  Future<Map<String, dynamic>?> getUserProfile({String? uid}) async {
    final targetUid = uid ?? currentUser?.uid;
    if (targetUid == null) return null;

    final doc = await _firestore.collection('users').doc(targetUid).get();
    return doc.data();
  }

  User? get currentUser => _auth.currentUser;
}