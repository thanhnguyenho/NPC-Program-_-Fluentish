import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:fluentish/src/shared/shared.dart';

/// "My Details" — lets the user view and edit their profile fields.
class ProfileMenuOptionsPage extends StatefulWidget {
  const ProfileMenuOptionsPage({super.key});

  @override
  State<ProfileMenuOptionsPage> createState() => _ProfileMenuOptionsPageState();
}

class _ProfileMenuOptionsPageState extends State<ProfileMenuOptionsPage> {
  final _username = TextEditingController();
  final _dob = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();

  bool _dirty = false;
  bool _loading = true;
  bool _saving = false;
  bool _uploadingAvatar = false;
  String? _avatarUrl;
  String? _avatarBase64;
  String _originalUsernameLower = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();

    for (final c in [_username, _dob, _phone, _email]) {
      c.addListener(() {
        if (!_dirty) {
          setState(() {
            _dirty = true;
          });
        }
      });
    }
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    _avatarUrl = user?.photoURL;
    _email.text = user?.email ?? '';

    final uid = user?.uid;
    if (uid != null) {
      final publicDoc = await FirebaseFirestore.instance
          .collection('publicProfiles')
          .doc(uid)
          .get();
      final privateDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      final publicProfile = publicDoc.data();
      final privateProfile = privateDoc.data();
      final profile = <String, dynamic>{};
      if (publicProfile != null) {
        profile.addAll(Map<String, dynamic>.from(publicProfile));
      }
      if (privateProfile != null) {
        profile.addAll(Map<String, dynamic>.from(privateProfile));
      }

      if (profile.isNotEmpty) {
        _username.text =
            (profile['username'] ?? profile['displayName'] ?? '').toString();
        _originalUsernameLower = _username.text.trim().toLowerCase();
        _dob.text = (profile['dateOfBirth'] ?? '').toString();
        _phone.text = (profile['phoneNumber'] ?? '').toString();
        final avatar = (profile['avatarUrl'] ?? '').toString();
        final avatarBase64 = (profile['avatarBase64'] ?? '').toString();
        if (avatar.isNotEmpty) {
          _avatarUrl = avatar;
        }
        if (avatarBase64.isNotEmpty) {
          _avatarBase64 = avatarBase64;
        }
      }
    }

    if (!mounted) return;
    setState(() {
      _loading = false;
      _dirty = false;
    });
  }

  @override
  void dispose() {
    _username.dispose();
    _dob.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _changeAvatar() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _uploadingAvatar) return;

    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 256,
        maxHeight: 256,
        imageQuality: 70,
      );
      if (image == null) return;

      final bytes = await image.readAsBytes();
      if (bytes.length > 500 * 1024) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This photo could not be compressed below 500 KB.'),
          ),
        );
        return;
      }

      if (mounted) setState(() => _uploadingAvatar = true);

      final encodedAvatar = base64Encode(bytes);
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();
      batch.set(
        firestore.collection('users').doc(user.uid),
        {'avatarBase64': encodedAvatar},
        SetOptions(merge: true),
      );
      batch.set(
        firestore.collection('publicProfiles').doc(user.uid),
        {'uid': user.uid, 'avatarBase64': encodedAvatar},
        SetOptions(merge: true),
      );
      await batch.commit();

      if (!mounted) return;
      setState(() {
        _avatarBase64 = encodedAvatar;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile photo updated.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Could not upload photo. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final username = _username.text.trim();
    final usernameLower = username.toLowerCase();
    final newEmail = _email.text.trim().toLowerCase();
    if (!RegExp(r'^[a-zA-Z0-9_]{3,24}$').hasMatch(username)) {
      _showMessage(
        'Username must be 3–24 characters and use only letters, numbers, or _.',
      );
      return;
    }
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(newEmail)) {
      _showMessage('Please enter a valid email address.');
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      if (usernameLower != _originalUsernameLower) {
        final duplicate = await FirebaseFirestore.instance
            .collection('publicProfiles')
            .where('usernameLower', isEqualTo: usernameLower)
            .limit(1)
            .get();
        if (duplicate.docs.any((document) => document.id != user.uid)) {
          throw const _ProfileSaveException('This username is already taken.');
        }
      }

      final currentEmail = user.email?.trim().toLowerCase();
      final emailChanged = newEmail != currentEmail;
      if (emailChanged) {
        await user.verifyBeforeUpdateEmail(newEmail);
      }

      final firestore = FirebaseFirestore.instance;
      await firestore.runTransaction((transaction) async {
        final usernameReference =
            firestore.collection('usernames').doc(usernameLower);
        final usernameSnapshot = await transaction.get(usernameReference);
        final ownerUid = usernameSnapshot.data()?['uid']?.toString();
        if (usernameSnapshot.exists && ownerUid != user.uid) {
          throw const _ProfileSaveException('This username is already taken.');
        }
        DocumentReference<Map<String, dynamic>>? oldReference;
        if (_originalUsernameLower.isNotEmpty &&
            _originalUsernameLower != usernameLower) {
          oldReference =
              firestore.collection('usernames').doc(_originalUsernameLower);
          final oldSnapshot = await transaction.get(oldReference);
          if (oldSnapshot.data()?['uid'] == user.uid) {
            transaction.delete(oldReference);
          }
        }
        transaction.set(usernameReference, {
          'uid': user.uid,
          'username': username,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        transaction.set(
          firestore.collection('users').doc(user.uid),
          {
            'username': username,
            'dateOfBirth': _dob.text.trim(),
            'phoneNumber': _phone.text.trim(),
            'avatarUrl': _avatarUrl,
            'avatarBase64': _avatarBase64,
          },
          SetOptions(merge: true),
        );
        transaction.set(
          firestore.collection('publicProfiles').doc(user.uid),
          {
            'uid': user.uid,
            'displayName': username,
            'username': username,
            'usernameLower': usernameLower,
            'avatarUrl': _avatarUrl,
            'avatarBase64': _avatarBase64,
          },
          SetOptions(merge: true),
        );
      });

      if (!mounted) return;
      setState(() {
        _dirty = false;
        _originalUsernameLower = usernameLower;
      });

      _showMessage(
        emailChanged
            ? 'Profile updated. A verification link was sent to $newEmail. '
                'Your email changes only after you confirm it.'
            : 'Profile updated.',
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      _showMessage(switch (error.code) {
        'email-already-in-use' =>
          'This email is already used by another account.',
        'invalid-email' => 'Please enter a valid email address.',
        'requires-recent-login' =>
          'Please sign out, sign in again, then retry changing your email.',
        _ => 'Could not update email. Please try again.',
      });
    } on _ProfileSaveException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
    } catch (error) {
      if (!mounted) return;
      debugPrint('Could not save profile: $error');
      _showMessage('Could not save changes. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatarImage = avatarImageProvider(
      base64Data: _avatarBase64,
      url: _avatarUrl,
    );
    return Scaffold(
      backgroundColor: AppColors.shell,
      body: Column(
        children: [
          //----------------------------------------
          // Header
          //----------------------------------------

          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.pine,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(
              8,
              50,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppColors.blush,
                  ),
                  onPressed: () {
                    Navigator.pop(context, _avatarUrl);
                  },
                ),
                Expanded(
                  child: Text(
                    "My Details",
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.blush,
                      fontSize: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),

          //----------------------------------------
          // Body
          //----------------------------------------

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      children: [
                        //----------------------------------------
                        // Avatar
                        //----------------------------------------

                        GestureDetector(
                          onTap: _uploadingAvatar ? null : _changeAvatar,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              CircleAvatar(
                                radius: 55,
                                backgroundColor: AppColors.cardSurface,
                                backgroundImage: avatarImage,
                                child: _uploadingAvatar
                                    ? const CircularProgressIndicator()
                                    : avatarImage == null
                                        ? const Icon(
                                            Icons.person,
                                            size: 56,
                                            color: AppColors.pine,
                                          )
                                        : null,
                              ),
                              Positioned(
                                right: -2,
                                bottom: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: AppColors.blush,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    size: 18,
                                    color: AppColors.pine,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        TextButton(
                          onPressed: _uploadingAvatar ? null : _changeAvatar,
                          child: Text(
                            _uploadingAvatar ? 'Uploading...' : 'Choose Photo',
                            style: const TextStyle(color: AppColors.pine),
                          ),
                        ),

                        const SizedBox(height: 20),

                        //----------------------------------------
                        // Fields
                        //----------------------------------------

                        _DetailField(
                          label: "Username",
                          controller: _username,
                          icon: Icons.person_outline,
                        ),

                        _DetailField(
                          label: "Date of Birth",
                          controller: _dob,
                          icon: Icons.cake_outlined,
                        ),

                        _DetailField(
                          label: "Phone Number",
                          controller: _phone,
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),

                        _DetailField(
                          label: "Email",
                          controller: _email,
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),

                        const SizedBox(height: 16),

                        //----------------------------------------
                        // Save Button
                        //----------------------------------------

                        AppButton(
                          label: _saving ? 'SAVING...' : 'SAVE CHANGES',
                          backgroundColor: AppColors.pine,
                          foregroundColor: AppColors.blush,
                          onPressed: (_dirty && !_saving) ? _save : null,
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _DetailField extends StatelessWidget {
  const _DetailField({
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType = TextInputType.text,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(color: AppColors.pine),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: AppColors.textMuted,
              ),
              filled: true,
              fillColor: AppColors.cardSurface,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppSpacing.buttonRadius,
                ),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppSpacing.buttonRadius,
                ),
                borderSide: const BorderSide(
                  color: AppColors.pine,
                  width: 2,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppSpacing.buttonRadius,
                ),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSaveException implements Exception {
  const _ProfileSaveException(this.message);

  final String message;
}
