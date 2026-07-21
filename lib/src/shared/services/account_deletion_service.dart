import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class AccountDeletionDataSource {
  bool get requiresPassword;
  Future<void> deleteAccount({String? password});
}

class AccountDeletionService implements AccountDeletionDataSource {
  AccountDeletionService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  static Future<void>? _googleInitialization;

  User get _user {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Sign in before deleting your account.');
    return user;
  }

  @override
  bool get requiresPassword =>
      _auth.currentUser?.providerData.any(
        (provider) => provider.providerId == EmailAuthProvider.PROVIDER_ID,
      ) ??
      false;

  @override
  Future<void> deleteAccount({String? password}) async {
    final user = _user;
    await _reauthenticate(user, password: password);
    await _deleteAvatar(user.uid);
    await _deleteFirestoreData(user.uid);
    try {
      await user.delete();
    } on FirebaseAuthException catch (error) {
      if (error.code == 'requires-recent-login') {
        throw StateError('Please sign in again and retry.');
      }
      throw StateError('Could not delete your account.');
    }
  }

  Future<void> _reauthenticate(User user, {String? password}) async {
    try {
      if (requiresPassword) {
        if (password == null || password.isEmpty) {
          throw StateError('Enter your password to continue.');
        }
        final email = user.email;
        if (email == null || email.isEmpty) {
          throw StateError('This account does not have an email address.');
        }
        await user.reauthenticateWithCredential(
          EmailAuthProvider.credential(email: email, password: password),
        );
        return;
      }

      final usesGoogle = user.providerData.any(
        (provider) => provider.providerId == GoogleAuthProvider.PROVIDER_ID,
      );
      if (!usesGoogle) {
        await user.reload();
        return;
      }
      if (kIsWeb) {
        await user.reauthenticateWithPopup(GoogleAuthProvider());
        return;
      }

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
      final googleUser = await GoogleSignIn.instance.authenticate();
      await user.reauthenticateWithCredential(
        GoogleAuthProvider.credential(
          idToken: googleUser.authentication.idToken,
        ),
      );
    } on FirebaseAuthException catch (error) {
      if (error.code == 'wrong-password' ||
          error.code == 'invalid-credential') {
        throw StateError('The password is incorrect.');
      }
      throw StateError('Could not verify your account.');
    }
  }

  Future<void> _deleteAvatar(String uid) async {
    try {
      await _storage.ref('avatars/$uid/profile').delete();
    } on FirebaseException catch (error) {
      if (error.code != 'object-not-found' &&
          error.code != 'bucket-not-found') {
        rethrow;
      }
    }
  }

  Future<void> _deleteFirestoreData(String uid) async {
    final references = <String, DocumentReference<Map<String, dynamic>>>{};
    Future<void> addQuery(Query<Map<String, dynamic>> query) async {
      final snapshot = await query.get();
      for (final document in snapshot.docs) {
        references[document.reference.path] = document.reference;
      }
    }

    final userReference = _firestore.collection('users').doc(uid);
    final publicProfileReference =
        _firestore.collection('publicProfiles').doc(uid);
    final publicProfile = await publicProfileReference.get();
    final usernameLower = publicProfile.data()?['usernameLower']?.toString();
    if (usernameLower != null && usernameLower.isNotEmpty) {
      references['usernames/$usernameLower'] =
          _firestore.collection('usernames').doc(usernameLower);
    }
    for (final collectionName in const [
      'history',
      'favouritePhrases',
      'favouriteSoundboardBites',
      'savedGuides',
    ]) {
      await addQuery(userReference.collection(collectionName));
    }
    await addQuery(
      _firestore.collection('friendships').where('userIds', arrayContains: uid),
    );
    await addQuery(
      _firestore.collection('friendRequests').where('senderId', isEqualTo: uid),
    );
    await addQuery(
      _firestore
          .collection('friendRequests')
          .where('receiverId', isEqualTo: uid),
    );

    references.addAll({
      'locations/$uid': _firestore.collection('locations').doc(uid),
      'locationSharing/$uid': _firestore.collection('locationSharing').doc(uid),
      'publicProfiles/$uid': publicProfileReference,
      'users/$uid': userReference,
    });

    final values = references.values.toList();
    for (var offset = 0; offset < values.length; offset += 400) {
      final batch = _firestore.batch();
      for (final reference in values.skip(offset).take(400)) {
        batch.delete(reference);
      }
      await batch.commit();
    }
  }
}
