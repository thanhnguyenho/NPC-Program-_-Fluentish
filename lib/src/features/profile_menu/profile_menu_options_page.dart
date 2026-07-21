import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import 'package:fluentish/src/shared/services/profile_repository.dart';
import 'package:fluentish/src/shared/shared.dart';

typedef PickProfileAvatar = Future<ProfileAvatarSelection?> Function();

class ProfileMenuOptionsPage extends StatefulWidget {
  const ProfileMenuOptionsPage({
    super.key,
    this.repository,
    this.pickAvatar,
  });

  final ProfileDataSource? repository;
  final PickProfileAvatar? pickAvatar;

  @override
  State<ProfileMenuOptionsPage> createState() => _ProfileMenuOptionsPageState();
}

class _ProfileMenuOptionsPageState extends State<ProfileMenuOptionsPage> {
  final _username = TextEditingController();
  final _dob = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();

  late final ProfileDataSource _repository;
  bool _dirty = false;
  bool _loading = true;
  bool _saving = false;
  bool _uploadingAvatar = false;
  String? _loadError;
  String? _avatarUrl;
  String? _avatarBase64;
  String _originalEmail = '';
  bool _applyingProfile = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? ProfileRepository();
    for (final controller in [_username, _dob, _phone, _email]) {
      controller.addListener(_markDirty);
    }
    _loadProfile();
  }

  void _markDirty() {
    if (_applyingProfile || _dirty || !mounted) return;
    setState(() => _dirty = true);
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final profile = await _repository.loadProfile();
      if (!mounted) return;
      _applyProfile(profile);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadError = 'Could not load your profile.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyProfile(EditableProfile profile) {
    _applyingProfile = true;
    _username.text = profile.username;
    _dob.text = profile.dateOfBirth;
    _phone.text = profile.phoneNumber;
    _email.text = profile.email;
    _originalEmail = profile.email;
    _avatarUrl = profile.avatarUrl;
    _avatarBase64 = profile.avatarBase64;
    _applyingProfile = false;
    setState(() => _dirty = false);
  }

  Future<ProfileAvatarSelection?> _pickAvatar() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 384,
      maxHeight: 384,
      imageQuality: 70,
    );
    if (image == null) return null;
    final lowerPath = image.path.toLowerCase();
    final contentType = lowerPath.endsWith('.png')
        ? 'image/png'
        : lowerPath.endsWith('.webp')
            ? 'image/webp'
            : 'image/jpeg';
    return ProfileAvatarSelection(
      bytes: await image.readAsBytes(),
      contentType: contentType,
    );
  }

  Future<void> _changeAvatar() async {
    if (_uploadingAvatar) return;
    final selection = await (widget.pickAvatar ?? _pickAvatar)();
    if (selection == null || !mounted) return;
    setState(() => _uploadingAvatar = true);
    try {
      final profile = await _repository.uploadAvatar(selection);
      if (!mounted) return;
      _applyProfile(profile);
      _showMessage('Profile photo updated.');
    } catch (error) {
      if (!mounted) return;
      _showMessage(_friendlyError(error, fallback: 'Could not upload photo.'));
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    final validation = validateProfileInput(
      username: _username.text,
      phoneNumber: _phone.text,
      dateOfBirth: _dob.text,
      email: _email.text,
    );
    if (validation != null) {
      _showMessage(validation);
      return;
    }

    final profile = EditableProfile(
      username: _username.text.trim(),
      dateOfBirth: _dob.text.trim(),
      phoneNumber: _phone.text.trim(),
      email: _email.text.trim(),
      avatarUrl: _avatarUrl,
      avatarBase64: _avatarBase64,
    );
    setState(() => _saving = true);
    try {
      await _repository.saveProfile(profile);
      if (!mounted) return;
      final emailChanged = profile.email != _originalEmail;
      _originalEmail = profile.email;
      setState(() => _dirty = false);
      _showMessage(
        emailChanged
            ? 'Profile updated. Check your new email to confirm the change.'
            : 'Profile updated.',
      );
    } catch (error) {
      if (!mounted) return;
      _showMessage(
        _friendlyError(error, fallback: 'Could not save your profile.'),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _friendlyError(Object error, {required String fallback}) {
    if (error is FirebaseAuthException) {
      return switch (error.code) {
        'email-already-in-use' =>
          'This email is already used by another account.',
        'invalid-email' => 'Enter a valid email address.',
        'requires-recent-login' =>
          'Please sign in again before changing your email.',
        _ => fallback,
      };
    }
    if (error is StateError) {
      final message = error.message.toLowerCase();
      if (message.contains('sign in') ||
          message.contains('choose a jpeg') ||
          message.contains('smaller than') ||
          message.contains('username is already taken')) {
        return error.message;
      }
    }
    final value = error.toString().toLowerCase();
    if (value.contains('network') || value.contains('timeout')) {
      return 'Check your connection and try again.';
    }
    if (value.contains('requires-recent-login')) {
      return 'Please sign in again before changing your email.';
    }
    if (value.contains('storage') && value.contains('bucket')) {
      return 'Profile photo storage is not configured yet.';
    }
    return fallback;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    for (final controller in [_username, _dob, _phone, _email]) {
      controller
        ..removeListener(_markDirty)
        ..dispose();
    }
    super.dispose();
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
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.pine,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(8, 50, AppSpacing.md, 14),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.blush),
                  onPressed: () => Navigator.pop(context, _avatarUrl),
                ),
                Expanded(
                  child: Text(
                    'My Details',
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.blush,
                      fontSize: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _body(avatarImage)),
        ],
      ),
    );
  }

  Widget _body(ImageProvider<Object>? avatarImage) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 52),
              const SizedBox(height: AppSpacing.md),
              Text(_loadError!, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: 'Try Again',
                expand: false,
                onPressed: _loadProfile,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Tooltip(
            message: 'Change profile photo',
            child: GestureDetector(
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
          _field('Username', _username, Icons.person_outline),
          _field('Date of Birth', _dob, Icons.cake_outlined),
          _field(
            'Phone Number',
            _phone,
            Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          _field(
            'Email',
            _email,
            Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          AppButton(
            label: _saving ? 'Saving...' : 'Save Changes',
            backgroundColor: AppColors.pine,
            foregroundColor: AppColors.blush,
            onPressed: (_dirty && !_saving) ? _save : null,
          ),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
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
              prefixIcon: Icon(icon, color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.cardSurface,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                borderSide: const BorderSide(
                  color: AppColors.pine,
                  width: 2,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
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
