import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditableProfile {
  const EditableProfile({
    required this.username,
    required this.dateOfBirth,
    required this.phoneNumber,
    required this.email,
    this.avatarUrl,
    this.avatarBase64,
  });

  final String username;
  final String dateOfBirth;
  final String phoneNumber;
  final String email;
  final String? avatarUrl;
  final String? avatarBase64;

  EditableProfile copyWith({
    String? username,
    String? dateOfBirth,
    String? phoneNumber,
    String? email,
    String? avatarUrl,
    String? avatarBase64,
    bool clearAvatarBase64 = false,
  }) {
    return EditableProfile(
      username: username ?? this.username,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarBase64:
          clearAvatarBase64 ? null : avatarBase64 ?? this.avatarBase64,
    );
  }
}

class ProfileAvatarSelection {
  const ProfileAvatarSelection({
    required this.bytes,
    required this.contentType,
  });

  final Uint8List bytes;
  final String contentType;
}

abstract class ProfileDataSource {
  Future<EditableProfile> loadProfile();
  Future<void> saveProfile(EditableProfile profile);
  Future<EditableProfile> uploadAvatar(ProfileAvatarSelection avatar);
}

class ProfileRepository implements ProfileDataSource {
  ProfileRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  User get _user {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Sign in to edit your profile.');
    return user;
  }

  @override
  Future<EditableProfile> loadProfile() async {
    final user = _user;
    final snapshots = await Future.wait([
      _firestore.collection('publicProfiles').doc(user.uid).get(),
      _firestore.collection('users').doc(user.uid).get(),
    ]).timeout(const Duration(seconds: 12));
    final publicData = snapshots[0].data() ?? const <String, dynamic>{};
    final privateData = snapshots[1].data() ?? const <String, dynamic>{};

    return EditableProfile(
      username: (privateData['username'] ??
              publicData['username'] ??
              publicData['displayName'] ??
              '')
          .toString(),
      dateOfBirth: (privateData['dateOfBirth'] ?? '').toString(),
      phoneNumber: (privateData['phoneNumber'] ?? '').toString(),
      email: user.email ?? (privateData['email'] ?? '').toString(),
      avatarUrl: _nonEmptyString(
        privateData['avatarUrl'] ?? publicData['avatarUrl'] ?? user.photoURL,
      ),
      avatarBase64: _nonEmptyString(
        privateData['avatarBase64'] ?? publicData['avatarBase64'],
      ),
    );
  }

  @override
  Future<void> saveProfile(EditableProfile profile) async {
    final user = _user;
    final username = profile.username.trim();
    final usernameLower = username.toLowerCase();
    final email = profile.email.trim().toLowerCase();
    final publicReference =
        _firestore.collection('publicProfiles').doc(user.uid);
    final usernameReference =
        _firestore.collection('usernames').doc(usernameLower);

    final usernameSnapshot = await usernameReference.get();
    if (usernameSnapshot.exists &&
        usernameSnapshot.data()?['uid'] != user.uid) {
      throw StateError('This username is already taken.');
    }
    if (email != (user.email ?? '').trim().toLowerCase()) {
      await user.verifyBeforeUpdateEmail(email);
    }

    await _firestore.runTransaction((transaction) async {
      final publicSnapshot = await transaction.get(publicReference);
      final originalUsernameLower =
          _nonEmptyString(publicSnapshot.data()?['usernameLower']);
      final currentUsernameSnapshot = await transaction.get(usernameReference);
      if (currentUsernameSnapshot.exists &&
          currentUsernameSnapshot.data()?['uid'] != user.uid) {
        throw StateError('This username is already taken.');
      }

      DocumentReference<Map<String, dynamic>>? oldUsernameReference;
      DocumentSnapshot<Map<String, dynamic>>? oldUsernameSnapshot;
      if (originalUsernameLower != null &&
          originalUsernameLower != usernameLower) {
        oldUsernameReference =
            _firestore.collection('usernames').doc(originalUsernameLower);
        oldUsernameSnapshot = await transaction.get(oldUsernameReference);
      }

      transaction.set(usernameReference, {
        'uid': user.uid,
        'username': username,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (oldUsernameReference != null &&
          oldUsernameSnapshot?.data()?['uid'] == user.uid) {
        transaction.delete(oldUsernameReference);
      }
      transaction.set(
        _firestore.collection('users').doc(user.uid),
        {
          'username': username,
          'dateOfBirth': profile.dateOfBirth.trim(),
          'phoneNumber': profile.phoneNumber.trim(),
          'avatarUrl': profile.avatarUrl,
        },
        SetOptions(merge: true),
      );
      transaction.set(
        publicReference,
        {
          'uid': user.uid,
          'displayName': username,
          'username': username,
          'usernameLower': usernameLower,
          'avatarUrl': profile.avatarUrl,
        },
        SetOptions(merge: true),
      );
    }).timeout(const Duration(seconds: 12));
  }

  @override
  Future<EditableProfile> uploadAvatar(ProfileAvatarSelection avatar) async {
    final user = _user;
    if (avatar.bytes.isEmpty || avatar.bytes.length > 1024 * 1024) {
      throw StateError('Choose an image smaller than 1 MB.');
    }
    if (!const {
      'image/jpeg',
      'image/png',
      'image/webp',
    }.contains(avatar.contentType)) {
      throw StateError('Choose a JPEG, PNG, or WebP image.');
    }

    final reference = _storage.ref('avatars/${user.uid}/profile');
    await reference
        .putData(
          avatar.bytes,
          SettableMetadata(contentType: avatar.contentType),
        )
        .timeout(const Duration(seconds: 30));
    final avatarUrl = await reference.getDownloadURL();
    final batch = _firestore.batch();
    batch.set(
      _firestore.collection('users').doc(user.uid),
      {
        'avatarUrl': avatarUrl,
        'avatarBase64': FieldValue.delete(),
      },
      SetOptions(merge: true),
    );
    batch.set(
      _firestore.collection('publicProfiles').doc(user.uid),
      {
        'uid': user.uid,
        'avatarUrl': avatarUrl,
        'avatarBase64': FieldValue.delete(),
      },
      SetOptions(merge: true),
    );
    await batch.commit();
    await user.updatePhotoURL(avatarUrl);
    final current = await loadProfile();
    return current.copyWith(
      avatarUrl: avatarUrl,
      clearAvatarBase64: true,
    );
  }
}

String? _nonEmptyString(Object? value) {
  final string = value?.toString().trim();
  return string == null || string.isEmpty ? null : string;
}

String? validateProfileInput({
  required String username,
  required String phoneNumber,
  required String dateOfBirth,
  required String email,
}) {
  if (!RegExp(r'^[a-zA-Z0-9_]{3,24}$').hasMatch(username.trim())) {
    return 'Username must be 3–24 characters and use only letters, numbers, or _.';
  }
  if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email.trim())) {
    return 'Enter a valid email address.';
  }
  if (!RegExp(r'^\+?[0-9 ()-]{7,20}$').hasMatch(phoneNumber.trim())) {
    return 'Enter a valid phone number.';
  }
  final match =
      RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(dateOfBirth.trim());
  if (match == null) return 'Enter date of birth as DD/MM/YYYY.';
  final day = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final year = int.parse(match.group(3)!);
  final date = DateTime(year, month, day);
  if (date.day != day || date.month != month || date.year != year) {
    return 'Enter a valid date of birth.';
  }
  final today = DateTime.now();
  final adultCutoff = DateTime(today.year - 18, today.month, today.day);
  if (date.isAfter(adultCutoff)) return 'You must be at least 18 years old.';
  return null;
}
