import 'package:flutter/material.dart';

import 'package:fluentish/src/shared/shared.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _autoDetectLocation = true;
  bool _pushNotifications = true;
  bool _friendUpdates = true;
  bool _nearbyRecommendation = true;

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text(
          "Are you sure you want to permanently delete your account?\n\nThis action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "Delete",
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.shell,
      body: Column(
        children: [
          //------------------------------------
          // Header
          //------------------------------------

          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.pine,
              borderRadius: BorderRadius.only(
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
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppColors.blush,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    "Settings",
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.blush,
                      fontSize: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),

          //------------------------------------
          // Body
          //------------------------------------

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                const _SectionLabel("LANGUAGE"),

                _SettingsGroup(
                  children: [
                    _NavRow(
                      icon: Icons.language,
                      label: "Source Language",
                      trailing: "English",
                      onTap: () {},
                    ),

                    _NavRow(
                      icon: Icons.arrow_forward,
                      label: "Target Language",
                      trailing: "Vietnamese",
                      onTap: () {},
                    ),

                    _SwitchRow(
                      icon: Icons.location_on_outlined,
                      label: "Auto-detect Location",
                      value: _autoDetectLocation,
                      onChanged: (v) {
                        setState(() {
                          _autoDetectLocation = v;
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                const _SectionLabel("APPEARANCE"),

                _SettingsGroup(
                  children: [
                    _NavRow(
                      icon: Icons.wb_sunny_outlined,
                      label: "Theme",
                      trailing: "Light",
                      onTap: () {},
                    ),

                    _NavRow(
                      icon: Icons.text_fields,
                      label: "Text Size",
                      trailing: "Medium",
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                const _SectionLabel("NOTIFICATIONS"),

                _SettingsGroup(
                  children: [
                    _SwitchRow(
                      icon: Icons.notifications_none,
                      label: "Push Notifications",
                      value: _pushNotifications,
                      onChanged: (v) {
                        setState(() {
                          _pushNotifications = v;
                        });
                      },
                    ),

                    _SwitchRow(
                      icon: Icons.people_outline,
                      label: "Friend Updates",
                      value: _friendUpdates,
                      onChanged: (v) {
                        setState(() {
                          _friendUpdates = v;
                        });
                      },
                    ),

                    _SwitchRow(
                      icon: Icons.near_me_outlined,
                      label: "Nearby Recommendation",
                      value: _nearbyRecommendation,
                      onChanged: (v) {
                        setState(() {
                          _nearbyRecommendation = v;
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                const _SectionLabel("PRIVACY & ACCOUNT"),

                _SettingsGroup(
                  children: [
                    _NavRow(
                      icon: Icons.lock_outline,
                      label: "Change Password",
                      onTap: () {},
                    ),

                    _NavRow(
                      icon: Icons.shield_outlined,
                      label: "Privacy Policy",
                      onTap: () {},
                    ),

                    _NavRow(
                      icon: Icons.description_outlined,
                      label: "Terms of Service",
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                const _SectionLabel("DANGER ZONE"),

                _SettingsGroup(
                  children: [
                    _NavRow(
                      icon: Icons.delete_outline,
                      label: "Delete Account",
                      labelColor: Colors.red,
                      iconColor: Colors.red,
                      onTap: _confirmDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xs,
        bottom: AppSpacing.xs,
      ),
      child: Text(
        text,
        style: AppTextStyles.body.copyWith(
          color: AppColors.textMuted,
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: AppColors.cardBorder,
        ),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              const Divider(
                height: 1,
                indent: 52,
                color: AppColors.cardBorder,
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
              color: iconColor ?? AppColors.pine,
            ),

            const SizedBox(width: AppSpacing.md),

            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body.copyWith(
                  color: labelColor ?? AppColors.pine,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            if (trailing != null)
              Text(
                trailing!,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),

            const SizedBox(width: 4),

            const Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.pine,
          ),

          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: AppColors.pine,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.pine,
          ),
        ],
      ),
    );
  }
}