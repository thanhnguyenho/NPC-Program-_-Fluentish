import 'package:flutter/material.dart';

import 'package:fluentish/src/features/history/history_page.dart';
import 'package:fluentish/src/features/profile_menu/profile_menu_options_page.dart';
import 'package:fluentish/src/features/settings/settings_page.dart';
import 'package:fluentish/src/features/welcome/welcome_page.dart';
import 'package:fluentish/src/shared/shared.dart';

/// The Profile tab: avatar + stats header, account/preferences menu,
/// logout, and a hamburger side menu.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.shell,
      body: _ProfilePageContent(onMenuTap: () {  },),
    );
  }
}

class _ProfilePageContent extends StatelessWidget {
  const _ProfilePageContent({required this.onMenuTap});

  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            50,
            AppSpacing.md,
            AppSpacing.lg,
          ),
          decoration: const BoxDecoration(
            color: AppColors.pine,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  const CircleAvatar(
                    radius: 46,
                    backgroundColor: AppColors.blush,
                    child: Icon(
                      Icons.person,
                      size: 48,
                      color: AppColors.pine,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.blush,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit, size: 14, color: AppColors.pine),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              // TODO: pull from the logged-in user's real profile data.
              Text(
                'Chloe',
                style: AppTextStyles.title.copyWith(
                  color: AppColors.blush,
                  fontSize: 18,
                ),
              ),
              Text(
                'chloe123@gmail.com',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.blush.withValues(alpha: 0.75),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatColumn(value: '36', label: 'Saved'),
                    _StatColumn(value: '36', label: 'History'),
                    _StatColumn(value: '36', label: 'Friends'),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.bottomNavHeight + AppSpacing.xl,
            ),
            children: [
              const _SectionLabel('MY ACCOUNT'),
              _AccountTile(
                icon: Icons.person_outline,
                iconBg: AppColors.blush,
                label: 'MY DETAILS',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ProfileMenuOptionsPage(),
                  ),
                ),
              ),
              _AccountTile(
                icon: Icons.star_border,
                iconBg: AppColors.blush,
                label: 'FAVOURITE LIST',
                onTap: () {},
              ),
              _AccountTile(
                icon: Icons.history,
                iconBg: AppColors.blush,
                label: 'HISTORY',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const HistoryPage()),
                ),
              ),
              _AccountTile(
                icon: Icons.people_outline,
                iconBg: AppColors.blush,
                label: 'MY FRIENDS',
                onTap: () {},
              ),
              const SizedBox(height: AppSpacing.xs),
              const _SectionLabel('PREFERENCES'),
              _AccountTile(
                icon: Icons.build_outlined,
                iconBg: AppColors.blush,
                label: 'SETTINGS',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: 'Logout',
                icon: Icons.logout,
                backgroundColor: AppColors.blush,
                foregroundColor: AppColors.pine,
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const WelcomePage()),
                  (route) => false,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.value, required this.label});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.title.copyWith(color: AppColors.blush, fontSize: 20),
        ),
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: AppColors.blush.withValues(alpha: 0.75),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs, left: AppSpacing.xxs),
      child: Text(
        text,
        style: AppTextStyles.body.copyWith(
          color: AppColors.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({
    required this.icon,
    required this.iconBg,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  ),
                  child: Icon(icon, size: 20, color: AppColors.pine),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.pine,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}






  

