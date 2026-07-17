// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import 'package:fluentish/src/shared/shared.dart';

const String _privacyPolicyLastUpdated = 'July 2026';

/// Shows the Privacy Policy as a draggable, scrollable popup (bottom sheet)
/// instead of navigating to a full page.
Future<void> showPrivacyPolicySheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.blush,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return _PrivacyPolicySheetContent(scrollController: scrollController);
        },
      );
    },
  );
}

class _PrivacyPolicySheetContent extends StatelessWidget {
  const _PrivacyPolicySheetContent({required this.scrollController});

  final ScrollController scrollController;

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.lg,
        bottom: AppSpacing.xs,
      ),
      child: Text(
        text,
        style: AppTextStyles.body.copyWith(
          color: AppColors.pine,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _sectionBody(String text) {
    return Text(
      text,
      style: AppTextStyles.body.copyWith(
        color: AppColors.pine,
        fontSize: 13,
        height: 1.5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Drag handle
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: AppColors.pine.withOpacity(0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Header row with close button
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 40),
              Expanded(
                child: Center(
                  child: AppStrokeText(
                    'PRIVACY POLICY',
                    fontSize: 24,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.pine),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Last updated: $_privacyPolicyLastUpdated',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.pine,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _sectionBody(
                  'This Privacy Policy explains how Fluentish collects, '
                  'uses, and protects your personal information when you '
                  'use our app. This is placeholder content — replace it '
                  'with your actual policy before publishing the app.',
                ),
                _sectionTitle('1. Information We Collect'),
                _sectionBody(
                  'When you create an account, we collect information such '
                  'as your name, preferred name, username, date of birth, '
                  'phone number, and email address. We may also collect '
                  'usage data to help improve the app experience.',
                ),
                _sectionTitle('2. How We Use Your Information'),
                _sectionBody(
                  'We use your information to create and manage your '
                  'account, personalize your experience, communicate with '
                  'you about updates, and improve the app\'s features and '
                  'performance.',
                ),
                _sectionTitle('3. How We Store Your Information'),
                _sectionBody(
                  'Your account credentials are securely managed through '
                  'Firebase Authentication, and your profile information is '
                  'stored in our Firestore database, protected by access '
                  'rules that restrict data access to your own account.',
                ),
                _sectionTitle('4. Sharing Your Information'),
                _sectionBody(
                  'We do not sell your personal information. We only share '
                  'data with third-party services necessary to operate the '
                  'app (such as our authentication and database providers), '
                  'or when required by law.',
                ),
                _sectionTitle('5. Your Rights'),
                _sectionBody(
                  'You may access, update, or delete your personal '
                  'information at any time by contacting us or through '
                  'your account settings, where available.',
                ),
                _sectionTitle('6. Children\'s Privacy'),
                _sectionBody(
                  'Fluentish is intended for users who are 18 years of age '
                  'or older. We do not knowingly collect information from '
                  'individuals under 18.',
                ),
                _sectionTitle('7. Changes to This Policy'),
                _sectionBody(
                  'We may update this Privacy Policy from time to time. '
                  'Any changes will be reflected here with an updated '
                  '"Last updated" date.',
                ),
                _sectionTitle('8. Contact Us'),
                _sectionBody(
                  'If you have any questions about this Privacy Policy, '
                  'please contact us at support@fluentish.app.',
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ],
    );
  }
}