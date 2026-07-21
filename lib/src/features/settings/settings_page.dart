// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import 'package:fluentish/src/features/change_password/change_password_page.dart';
import 'package:fluentish/src/features/privacy_policy/privacy_policy_sheet.dart';
import 'package:fluentish/src/features/terms_of_service/terms_of_service_sheet.dart';
import 'package:fluentish/src/services/auth_service.dart';
import 'package:fluentish/src/services/location_language_service.dart';
import 'package:fluentish/src/services/push_notification_service.dart';
import 'package:fluentish/src/services/settings_controller.dart';
import 'package:fluentish/src/shared/services/account_deletion_service.dart';
import 'package:fluentish/src/shared/shared.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, this.accountDeletion});

  final AccountDeletionDataSource? accountDeletion;

  Future<void> _togglePushNotifications(
    BuildContext context,
    bool enabled,
  ) async {
    final settings = SettingsController.instance;
    final messenger = ScaffoldMessenger.of(context);

    if (!enabled) {
      await settings.setFriendUpdates(false);
      await settings.setPushNotifications(false);
      await PushNotificationService().unregister();
      return;
    }

    final result =
        await PushNotificationService().requestPermissionAndRegister();
    await settings.setPushNotifications(result.enabled);

    if (result.simulated) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            '🔔 Demo notification: Push Notifications enabled. This works '
            'inside the app only.',
          ),
        ),
      );
    }
  }

  Future<void> _toggleFriendUpdates(
    BuildContext context,
    bool enabled,
  ) async {
    final settings = SettingsController.instance;
    if (!enabled) {
      await settings.setFriendUpdates(false);
      return;
    }

    if (!settings.pushNotifications) {
      final result =
          await PushNotificationService().requestPermissionAndRegister();
      await settings.setPushNotifications(result.enabled);
    }

    await settings.setFriendUpdates(true);
    if (context.mounted && PushNotificationService.isDemoMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '👥 Demo notification: Friend Updates enabled. New friend '
            'activity will be simulated while the app is open.',
          ),
        ),
      );
    }
  }

  Future<void> _toggleAutoDetectLocation(
    BuildContext context,
    bool enabled,
  ) async {
    final settings = SettingsController.instance;
    await settings.setAutoDetectLocation(enabled);
    if (!enabled) return;
    if (!context.mounted) return;
    await _detectLocationLanguage(context, showNoChangeMessage: false);
  }

  Future<void> _detectLocationLanguage(
    BuildContext context, {
    bool showNoChangeMessage = true,
  }) async {
    final settings = SettingsController.instance;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Detecting your location...')),
    );
    try {
      final result = await LocationLanguageService().detect();
      if (result.language != settings.targetLanguage) {
        await settings.setTargetLanguage(result.language);
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Detected ${result.countryName} — switched target language '
              'to ${result.language}.',
            ),
          ),
        );
      } else if (showNoChangeMessage) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Detected ${result.countryName} — already set to '
              '${result.language}.',
            ),
          ),
        );
      }
    } on LocationDetectionException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not detect location: $e')),
      );
    }
  }

  Future<void> _pickThemeMode(BuildContext context) async {
    final settings = SettingsController.instance;
    final colors = context.fluentishColors;
    final selected = await showModalBottomSheet<ThemeMode>(
      context: context,
      backgroundColor: colors.surfaceStrong,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final mode in ThemeMode.values)
                RadioListTile<ThemeMode>(
                  value: mode,
                  groupValue: settings.themeMode,
                  activeColor: colors.accent,
                  title: Text(
                    switch (mode) {
                      ThemeMode.light => 'Light',
                      ThemeMode.dark => 'Dark',
                      ThemeMode.system => 'System Default',
                    },
                    style: AppTextStyles.body.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  onChanged: (value) => Navigator.pop(context, value),
                ),
              const SizedBox(height: AppSpacing.xs),
            ],
          ),
        );
      },
    );
    if (selected != null) {
      await settings.setThemeMode(selected);
    }
  }

  Future<void> _pickTextSize(BuildContext context) async {
    final settings = SettingsController.instance;
    final colors = context.fluentishColors;
    final selected = await showModalBottomSheet<AppTextSize>(
      context: context,
      backgroundColor: colors.surfaceStrong,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final size in AppTextSize.values)
                RadioListTile<AppTextSize>(
                  value: size,
                  groupValue: settings.textSize,
                  activeColor: colors.accent,
                  title: Text(
                    size.label,
                    style: AppTextStyles.body.copyWith(
                      color: colors.textPrimary,
                      fontSize: 14 * size.scale,
                    ),
                  ),
                  onChanged: (value) => Navigator.pop(context, value),
                ),
              const SizedBox(height: AppSpacing.xs),
            ],
          ),
        );
      },
    );
    if (selected != null) {
      await settings.setTextSize(selected);
    }
  }

  Future<void> _pickLanguage({
    required BuildContext context,
    required String current,
    required ValueChanged<String> onPicked,
  }) async {
    const options = ['English', 'Vietnamese'];
    final colors = context.fluentishColors;
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: colors.surfaceStrong,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final option in options)
                RadioListTile<String>(
                  value: option,
                  groupValue: current,
                  activeColor: colors.accent,
                  title: Text(
                    option,
                    style: AppTextStyles.body.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  onChanged: (value) => Navigator.pop(context, value),
                ),
              const SizedBox(height: AppSpacing.xs),
            ],
          ),
        );
      },
    );
    if (selected != null) {
      onPicked(selected);
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final deletion = accountDeletion ?? AccountDeletionService();
    final deleted = await showDialog<bool>(
      context: context,
      builder: (_) => _DeleteAccountDialog(deletion: deletion),
    );
    if (deleted == true && context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SettingsController.instance,
      builder: (context, _) {
        final settings = SettingsController.instance;
        final colors = context.fluentishColors;

        return Scaffold(
          backgroundColor: colors.background,
          body: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colors.header,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
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
                      icon: Icon(
                        Icons.arrow_back,
                        color: colors.onHeader,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'Settings',
                        style: AppTextStyles.title.copyWith(
                          color: colors.onHeader,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    const _SectionLabel('LANGUAGE'),
                    _SettingsGroup(
                      children: [
                        _NavRow(
                          icon: Icons.language,
                          label: 'Source Language',
                          trailing: settings.sourceLanguage,
                          onTap: () => _pickLanguage(
                            context: context,
                            current: settings.sourceLanguage,
                            onPicked: settings.setSourceLanguage,
                          ),
                        ),
                        _NavRow(
                          icon: Icons.arrow_forward,
                          label: 'Target Language',
                          trailing: settings.targetLanguage,
                          onTap: () => _pickLanguage(
                            context: context,
                            current: settings.targetLanguage,
                            onPicked: settings.setTargetLanguage,
                          ),
                        ),
                        _SwitchRow(
                          icon: Icons.location_on_outlined,
                          label: 'Auto-detect Location',
                          value: settings.autoDetectLocation,
                          onChanged: (value) =>
                              _toggleAutoDetectLocation(context, value),
                        ),
                        if (settings.autoDetectLocation)
                          _NavRow(
                            icon: Icons.my_location,
                            label: 'Detect Now',
                            onTap: () => _detectLocationLanguage(context),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const _SectionLabel('APPEARANCE'),
                    _SettingsGroup(
                      children: [
                        _NavRow(
                          icon: Icons.wb_sunny_outlined,
                          label: 'Theme',
                          trailing: switch (settings.themeMode) {
                            ThemeMode.light => 'Light',
                            ThemeMode.dark => 'Dark',
                            ThemeMode.system => 'System',
                          },
                          onTap: () => _pickThemeMode(context),
                        ),
                        _NavRow(
                          icon: Icons.text_fields,
                          label: 'Text Size',
                          trailing: settings.textSize.label,
                          onTap: () => _pickTextSize(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const _SectionLabel('NOTIFICATIONS'),
                    _SettingsGroup(
                      children: [
                        _SwitchRow(
                          icon: Icons.notifications_none,
                          label: 'Push Notifications',
                          value: settings.pushNotifications,
                          onChanged: (value) =>
                              _togglePushNotifications(context, value),
                        ),
                        _SwitchRow(
                          icon: Icons.people_outline,
                          label: 'Friend Updates',
                          value: settings.friendUpdates,
                          onChanged: (value) =>
                              _toggleFriendUpdates(context, value),
                        ),
                        _SwitchRow(
                          icon: Icons.near_me_outlined,
                          label: 'Nearby Recommendation',
                          value: settings.nearbyRecommendation,
                          onChanged: settings.setNearbyRecommendation,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const _SectionLabel('PRIVACY & ACCOUNT'),
                    _SettingsGroup(
                      children: [
                        _NavRow(
                          icon: Icons.lock_outline,
                          label: 'Change Password',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ChangePasswordPage(),
                            ),
                          ),
                        ),
                        _NavRow(
                          icon: Icons.mark_email_read_outlined,
                          label: 'Email Me a Reset Link',
                          onTap: () async {
                            final email = AuthService().currentUser?.email;
                            if (email == null) return;
                            try {
                              await AuthService().resetPassword(email);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Password reset email sent to $email',
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed: $e')),
                                );
                              }
                            }
                          },
                        ),
                        _NavRow(
                          icon: Icons.shield_outlined,
                          label: 'Privacy Policy',
                          onTap: () => showPrivacyPolicySheet(context),
                        ),
                        _NavRow(
                          icon: Icons.description_outlined,
                          label: 'Terms of Service',
                          onTap: () => showTermsOfServiceSheet(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const _SectionLabel('DANGER ZONE'),
                    _SettingsGroup(
                      children: [
                        _NavRow(
                          icon: Icons.delete_outline,
                          label: 'Delete Account',
                          labelColor: Colors.red,
                          iconColor: Colors.red,
                          onTap: () => _confirmDelete(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.fluentishColors;
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xs,
        bottom: AppSpacing.xs,
      ),
      child: Text(
        text,
        style: AppTextStyles.body.copyWith(
          color: colors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.fluentishColors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: colors.border,
        ),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              Divider(
                height: 1,
                indent: 52,
                color: colors.border,
              ),
          ],
        ],
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.labelColor,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? trailing;
  final Color? labelColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.fluentishColors;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: iconColor ?? colors.textPrimary,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body.copyWith(
                  color: labelColor ?? colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (trailing != null)
              Text(
                trailing!,
                style: AppTextStyles.body.copyWith(
                  color: colors.textSecondary,
                  fontSize: 13,
                ),
              ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog({required this.deletion});

  final AccountDeletionDataSource deletion;

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  static const _safeMessages = {
    'Enter your password to continue.',
    'The password is incorrect.',
    'Please sign in again and retry.',
    'Could not verify your account.',
  };

  final _passwordController = TextEditingController();
  bool _deleting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    setState(() {
      _deleting = true;
      _errorMessage = null;
    });
    try {
      await widget.deletion.deleteAccount(
        password:
            widget.deletion.requiresPassword ? _passwordController.text : null,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      final stateMessage = error is StateError ? error.message : null;
      setState(() {
        _deleting = false;
        _errorMessage = _safeMessages.contains(stateMessage)
            ? stateMessage
            : 'Could not delete your account.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Account'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This permanently deletes your profile, friends, locations, '
            'history, favourites, saved guides, and sign-in account.',
          ),
          if (widget.deletion.requiresPassword) ...[
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm your password',
              ),
            ),
          ],
          if (_errorMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _deleting ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _deleting ? null : _delete,
          child: _deleting
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
        ),
      ],
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.fluentishColors;
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: colors.textPrimary,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: colors.accent,
            ),
          ],
        ),
      ),
    );
  }
}
