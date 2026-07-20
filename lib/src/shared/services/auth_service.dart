import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/firestore_models.dart';

abstract class AuthGateway {
  String? get currentUserId;
  String? get currentEmail;
  Stream<String?> get userIdChanges;
  Stream<PublicProfile?> watchCurrentProfile();
  Future<void> updatePresence();
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<void> signInWithGoogle();
  Future<void> signOut();
  Future<void> createUser({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
    required String preferredName,
    required String dateOfBirth,
    required String phoneNumber,
  });
}

class Auth implements AuthGateway {
  Auth({FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  static final Auth instance = Auth();

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  static Future<void>? _googleInitialization;

  @override
  String? get currentUserId => _firebaseAuth.currentUser?.uid;

  @override
  String? get currentEmail => _firebaseAuth.currentUser?.email;

  @override
  Stream<String?> get userIdChanges =>
      _firebaseAuth.authStateChanges().map((user) => user?.uid);

  @override
  Stream<PublicProfile?> watchCurrentProfile() {
    return userIdChanges.asyncExpand((uid) {
      if (uid == null) return Stream.value(null);
      return _firestore.collection('publicProfiles').doc(uid).snapshots().map(
            (document) =>
                document.exists ? PublicProfile.fromDocument(document) : null,
          );
    });
  }

  @override
  Future<void> updatePresence() async {
    final uid = currentUserId;
    if (uid == null) return;
    await _firestore.collection('publicProfiles').doc(uid).set({
      'lastSeenAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user == null) throw StateError('Firebase did not return the account.');
    await _ensureUserDocuments(user);
  }

  @override
  Future<void> signInWithGoogle() async {
    final UserCredential credential;
    if (kIsWeb) {
      credential = await _firebaseAuth.signInWithPopup(GoogleAuthProvider());
    } else {
      _googleInitialization ??= GoogleSignIn.instance.initialize(
        clientId: switch (defaultTargetPlatform) {
          TargetPlatform.iOS =>
            '794059461770-qi09d3mq0g07902ae1dter4j2361i06l.apps.googleusercontent.com',
          TargetPlatform.macOS =>
            '794059461770-fg6nio9d19k1iace2esnsrtp3j6qjo5b.apps.googleusercontent.com',
          _ => null,
        },
        serverClientId: defaultTargetPlatform == TargetPlatform.android
            ? '794059461770-ass0ip65m16vnp8g4dv72sl1klso05et.apps.googleusercontent.com'
            : null,
      );
      await _googleInitialization;
      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        throw StateError('Google sign-in is unavailable on this device.');
      }
      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuthentication = googleUser.authentication;
      credential = await _firebaseAuth.signInWithCredential(
        GoogleAuthProvider.credential(idToken: googleAuthentication.idToken),
      );
    }
    final user = credential.user;
    if (user == null) throw StateError('Google did not return the account.');
    await _ensureUserDocuments(user);
  }

  Future<void> _ensureUserDocuments(User user) async {
    final privateReference = _firestore.collection('users').doc(user.uid);
    final publicReference =
        _firestore.collection('publicProfiles').doc(user.uid);
    final sharingReference =
        _firestore.collection('locationSharing').doc(user.uid);
    final snapshots = await Future.wait([
      privateReference.get(),
      publicReference.get(),
      sharingReference.get(),
    ]);
    final privateExists = snapshots[0].exists;
    final publicExists = snapshots[1].exists;
    final sharingExists = snapshots[2].exists;
    final batch = _firestore.batch();

    if (!privateExists) {
      batch.set(privateReference, {
        'uid': user.uid,
        'email': user.email?.trim().toLowerCase() ?? '',
        'phoneNumber': user.phoneNumber ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    if (publicExists) {
      batch.set(
          publicReference,
          {
            'lastSeenAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true));
    } else {
      final username = _defaultUsername(user);
      batch.set(publicReference, {
        'uid': user.uid,
        'displayName': _defaultDisplayName(user),
        'username': username,
        'usernameLower': username.toLowerCase(),
        'avatarUrl': user.photoURL,
        'lastSeenAt': FieldValue.serverTimestamp(),
      });
    }
    if (!sharingExists) {
      batch.set(sharingReference, {
        'enabled': false,
        'audience': 'friends',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  String _defaultDisplayName(User user) {
    final displayName = user.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;
    final email = user.email?.trim();
    if (email != null && email.contains('@')) return email.split('@').first;
    return 'Fluentish user';
  }

  String _defaultUsername(User user) {
    final emailPrefix = user.email?.split('@').first ?? 'user';
    final normalized = emailPrefix
        .toLowerCase()
        .replaceAll(RegExp('[^a-z0-9_]'), '')
        .replaceAll(RegExp('_+'), '_');
    final base = normalized.isEmpty ? 'user' : normalized;
    return '${base}_${user.uid.substring(0, 6).toLowerCase()}';
  }

  @override
  Future<void> signOut() async {
    await updatePresence();
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> createUser({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
    required String preferredName,
    required String dateOfBirth,
    required String phoneNumber,
  }) async {
    final normalizedUsername = username.trim().toLowerCase();
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw StateError('Firebase did not return the new account.');
    }

    final duplicate = await _firestore
        .collection('publicProfiles')
        .where('usernameLower', isEqualTo: normalizedUsername)
        .limit(1)
        .get();
    if (duplicate.docs.isNotEmpty) {
      await user.delete();
      throw StateError('That username is already in use.');
    }

    final privateReference = _firestore.collection('users').doc(user.uid);
    final publicReference =
        _firestore.collection('publicProfiles').doc(user.uid);
    final sharingReference =
        _firestore.collection('locationSharing').doc(user.uid);
    final batch = _firestore.batch();
    batch.set(privateReference, {
      'uid': user.uid,
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'preferredName': preferredName.trim(),
      'username': username.trim(),
      'email': email.trim().toLowerCase(),
      'dateOfBirth': dateOfBirth.trim(),
      'phoneNumber': phoneNumber.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.set(publicReference, {
      'uid': user.uid,
      'displayName': preferredName.trim(),
      'username': username.trim(),
      'usernameLower': normalizedUsername,
      'avatarUrl': null,
      'lastSeenAt': FieldValue.serverTimestamp(),
    });
    batch.set(sharingReference, {
      'enabled': false,
      'audience': 'friends',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    try {
      await batch.commit().timeout(const Duration(seconds: 10));
    } catch (_) {
      await user.delete();
      rethrow;
    }
  }
}
