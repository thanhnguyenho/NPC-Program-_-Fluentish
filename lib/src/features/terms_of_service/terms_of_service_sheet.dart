// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import 'package:fluentish/src/shared/shared.dart';

const String _termsOfServiceLastUpdated = 'July 2026';

/// Shows the Terms of Service as a draggable, scrollable popup (bottom
/// sheet) instead of navigating to a full page.
Future<void> showTermsOfServiceSheet(BuildContext context) {
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
          return _TermsOfServiceSheetContent(
            scrollController: scrollController,
          );
        },
      );
    },
  );
}

class _TermsOfServiceSheetContent extends StatelessWidget {
  const _TermsOfServiceSheetContent({required this.scrollController});

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
                    'TERMS OF SERVICE',
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
                    'Last updated: $_termsOfServiceLastUpdated',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.pine,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _sectionBody(
                  'These Terms of Service govern your use of the Fluentish '
                  'app. By creating an account, you agree to these terms. '
                  'This is placeholder content — replace it with your '
                  'actual terms before publishing the app.',
                ),
                _sectionTitle('1. Eligibility'),
                _sectionBody(
                  'You must be at least 18 years old to create an account '
                  'and use Fluentish.',
                ),
                _sectionTitle('2. Your Account'),
                _sectionBody(
                  'You are responsible for maintaining the confidentiality '
                  'of your account credentials and for all activity that '
                  'occurs under your account. Please notify us immediately '
                  'if you suspect any unauthorized use.',
                ),
                _sectionTitle('3. Acceptable Use'),
                _sectionBody(
                  'You agree not to misuse the app, including attempting '
                  'to access other users\' accounts, disrupting the '
                  'service, or using the app for any unlawful purpose.',
                ),
                _sectionTitle('4. Content'),
                _sectionBody(
                  'Any content you submit through the app remains yours, '
                  'but you grant us a license to store and display it as '
                  'necessary to operate the service.',
                ),
                _sectionTitle('5. Termination'),
                _sectionBody(
                  'We may suspend or terminate your account if you violate '
                  'these terms or engage in behavior that harms the app or '
                  'other users.',
                ),
                _sectionTitle('6. Disclaimer of Warranties'),
                _sectionBody(
                  'The app is provided "as is" without warranties of any '
                  'kind. We do not guarantee that the service will be '
                  'uninterrupted or error-free.',
                ),
                _sectionTitle('7. Changes to These Terms'),
                _sectionBody(
                  'We may update these Terms of Service from time to '
                  'time. Any changes will be reflected here with an '
                  'updated "Last updated" date.',
                ),
                _sectionTitle('8. Contact Us'),
                _sectionBody(
                  'If you have any questions about these Terms of Service, '
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