import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:fluentish/src/shared/shared.dart';

/// "My Details" — lets the user view and edit their profile fields.
class ProfileMenuOptionsPage extends StatefulWidget {
  const ProfileMenuOptionsPage({super.key});

  @override
  State<ProfileMenuOptionsPage> createState() =>
      _ProfileMenuOptionsPageState();
}

class _ProfileMenuOptionsPageState extends State<ProfileMenuOptionsPage> {
  final _username = TextEditingController();
  final _dob = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();

  bool _dirty = false;
  bool _loading = true;
  bool _saving = false;
  String? _avatarUrl;

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
      final privateDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

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
        _username.text = (profile['username'] ?? profile['displayName'] ?? '').toString();
        _dob.text = (profile['dateOfBirth'] ?? '').toString();
        _phone.text = (profile['phoneNumber'] ?? '').toString();
        final avatar = (profile['avatarUrl'] ?? '').toString();
        if (avatar.isNotEmpty) {
          _avatarUrl = avatar;
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
    final controller = TextEditingController(text: _avatarUrl ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update photo URL'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'https://example.com/avatar.jpg'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {'avatarUrl': result},
        SetOptions(merge: true),
      );
      await FirebaseFirestore.instance.collection('publicProfiles').doc(user.uid).set(
        {'avatarUrl': result},
        SetOptions(merge: true),
      );
      if (!mounted) return;
      setState(() {
        _avatarUrl = result;
        _dirty = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo updated.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update photo: $e')),
      );
    }
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _saving = true;
    });

    try {
      final newEmail = _email.text.trim();
      if (newEmail.isNotEmpty && newEmail != user.email) {
        await user.verifyBeforeUpdateEmail(newEmail);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'A verification link was sent to $newEmail. Your email will '
              'update once you confirm it.',
            ),
          ),
        );
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'username': _username.text.trim(),
        'dateOfBirth': _dob.text.trim(),
        'phoneNumber': _phone.text.trim(),
        'avatarUrl': _avatarUrl,
      }, SetOptions(merge: true));

      await FirebaseFirestore.instance.collection('publicProfiles').doc(user.uid).set({
        'displayName': _username.text.trim(),
        'username': _username.text.trim(),
        'usernameLower': _username.text.trim().toLowerCase(),
        'avatarUrl': _avatarUrl,
      }, SetOptions(merge: true));

      if (!mounted) return;
      setState(() {
        _dirty = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save changes: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    Navigator.pop(context);
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
                    onTap: _changeAvatar,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundColor: AppColors.cardSurface,
                          backgroundImage: _avatarUrl != null && _avatarUrl!.isNotEmpty
                              ? NetworkImage(_avatarUrl!)
                              : null,
                          child: _avatarUrl == null || _avatarUrl!.isEmpty
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
                    onPressed: _changeAvatar,
                    child: const Text(
                      'Change Photo',
                      style: TextStyle(color: AppColors.pine),
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