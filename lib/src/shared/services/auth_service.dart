import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/firestore_models.dart';

abstract class AuthGateway {
  String? get currentUserId;
  String? get currentEmail;
  Stream<String?> get userIdChanges;
  Stream<PublicProfile?> watchCurrentProfile();
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
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
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final uid = credential.user?.uid;
    if (uid != null) {
      await _firestore.collection('publicProfiles').doc(uid).set({
        'lastSeenAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  @override
  Future<void> signOut() async {
    final uid = currentUserId;
    if (uid != null) {
      await _firestore.collection('publicProfiles').doc(uid).set({
        'lastSeenAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
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
