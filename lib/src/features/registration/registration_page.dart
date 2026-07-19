// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:fluentish/src/features/login/login_page.dart';
import 'package:fluentish/src/features/privacy_policy/privacy_policy_sheet.dart';
import 'package:fluentish/src/features/terms_of_service/terms_of_service_sheet.dart';
import 'package:fluentish/src/shared/shared.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({
    super.key,
    this.auth,
  });

  final AuthGateway? auth;

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  late final TapGestureRecognizer _privacyPolicyRecognizer;
  late final TapGestureRecognizer _termsOfServiceRecognizer;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _preferredNameController =
      TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _confirmEmailController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? errorMessage;

  bool _isSubmitting = false;
  bool agree = false;

  DateTime _selectedDob = DateTime(2000, 1, 1);

  static const List<String> _allowedEmailDomains = [
    'gmail.com',
    'yahoo.com',
    'icloud.com',
    'outlook.com',
    'hotmail.com',
    'live.com',
  ];

  AuthGateway get _auth => widget.auth ?? Auth.instance;

  @override
  void initState() {
    super.initState();

    _privacyPolicyRecognizer = TapGestureRecognizer()
      ..onTap = () {
        showPrivacyPolicySheet(context);
      };

    _termsOfServiceRecognizer = TapGestureRecognizer()
      ..onTap = () {
        showTermsOfServiceSheet(context);
      };
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _preferredNameController.dispose();
    _usernameController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _controllerEmail.dispose();
    _confirmEmailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _privacyPolicyRecognizer.dispose();
    _termsOfServiceRecognizer.dispose();

    super.dispose();
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LoginPage(
          auth: widget.auth,
        ),
      ),
    );
  }

  bool _isValidEmailDomain(String email) {
    final trimmed = email.trim().toLowerCase();

    final basicEmailRegex = RegExp(
      r'^[\w.\-+]+@[\w\-]+(\.[\w\-]+)+$',
    );

    if (!basicEmailRegex.hasMatch(trimmed)) {
      return false;
    }

    final domain = trimmed.split('@').last;

    return _allowedEmailDomains.contains(domain);
  }

  String? _validatePassword(String password) {
    if (password.length < 8) {
      return 'Password must be at least 8 characters.';
    }

    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);

    if (!hasUppercase) {
      return 'Password must contain at least 1 uppercase letter.';
    }

    final hasSpecialChar = RegExp(
      r'''[!@#$%^&*(),.?":{}|<>_\-\[\]/\\;=+~`]''',
    ).hasMatch(password);

    if (!hasSpecialChar) {
      return 'Password must contain at least 1 special character.';
    }

    return null;
  }

  Future<void> _pickDob() async {
    DateTime tempPicked = _selectedDob;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.blush,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return SizedBox(
          height: 320,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.pine,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedDob = tempPicked;

                        _dobController.text =
                            '${_selectedDob.day.toString().padLeft(2, '0')}/'
                            '${_selectedDob.month.toString().padLeft(2, '0')}/'
                            '${_selectedDob.year}';
                      });

                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color: AppColors.pine,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _selectedDob,
                  maximumDate: DateTime.now(),
                  minimumYear: 1900,
                  maximumYear: DateTime.now().year,
                  onDateTimeChanged: (DateTime newDate) {
                    tempPicked = newDate;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.itim(
            color: AppColors.pine,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(
          height: AppSpacing.xs,
        ),
        AppTextField(
          controller: controller,
          hintText: hint,
          keyboardType: keyboardType,
          obscureText: obscure,
          readOnly: readOnly,
          onTap: onTap,
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final preferredName = _preferredNameController.text.trim();
    final username = _usernameController.text.trim();
    final dob = _dobController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _controllerEmail.text.trim().toLowerCase();
    final confirmEmail =
        _confirmEmailController.text.trim().toLowerCase();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        preferredName.isEmpty ||
        username.isEmpty ||
        dob.isEmpty ||
        phone.isEmpty ||
        email.isEmpty ||
        confirmEmail.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      setState(() {
        errorMessage = 'Please fill in all fields.';
      });
      return;
    }

    if (email != confirmEmail) {
      setState(() {
        errorMessage = 'Emails do not match.';
      });
      return;
    }

    if (!_isValidEmailDomain(email)) {
      setState(() {
        errorMessage = 'Email domain is not allowed.';
      });
      return;
    }

    final passwordError = _validatePassword(password);

    if (passwordError != null) {
      setState(() {
        errorMessage = passwordError;
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        errorMessage = 'Passwords do not match.';
      });
      return;
    }

    if (!agree) {
      setState(() {
        errorMessage =
            'You must agree to the Terms of Service and Privacy Policy';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      errorMessage = null;
    });

    try {
      await _auth.createUser(
        firstName: firstName,
        lastName: lastName,
        username: username,
        email: email,
        password: password,
        preferredName: preferredName,
        dateOfBirth: dob,
        phoneNumber: phone,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LoginPage(
            auth: widget.auth,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        errorMessage = e is StateError ? e.message : e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.shell,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.pine,
                ),
                onPressed: _goToLogin,
              ),
              const SizedBox(
                height: AppSpacing.sm,
              ),
              Text(
                'Create Account',
                style: GoogleFonts.itim(
                  color: AppColors.pine,
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(
                height: AppSpacing.sm,
              ),
              Text(
                'Join Fluentish and start exploring.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSoft,
                ),
              ),
              const SizedBox(
                height: AppSpacing.md,
              ),
              buildField(
                label: 'First Name',
                controller: _firstNameController,
                hint: 'Enter first name',
              ),
              const SizedBox(
                height: AppSpacing.sm,
              ),
              buildField(
                label: 'Last Name',
                controller: _lastNameController,
                hint: 'Enter last name',
              ),
              const SizedBox(
                height: AppSpacing.sm,
              ),
              buildField(
                label: 'Preferred Name',
                controller: _preferredNameController,
                hint: 'Enter preferred name',
              ),
              const SizedBox(
                height: AppSpacing.sm,
              ),
              buildField(
                label: 'Username',
                controller: _usernameController,
                hint: 'Enter username',
              ),
              const SizedBox(
                height: AppSpacing.sm,
              ),
              buildField(
                label: 'Date of Birth',
                controller: _dobController,
                hint: 'Select date',
                readOnly: true,
                onTap: _pickDob,
              ),
              const SizedBox(
                height: AppSpacing.sm,
              ),
              buildField(
                label: 'Phone Number',
                controller: _phoneController,
                hint: 'Enter phone number',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(
                height: AppSpacing.sm,
              ),
              buildField(
                label: 'Email',
                controller: _controllerEmail,
                hint: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(
                height: AppSpacing.sm,
              ),
              buildField(
                label: 'Confirm Email',
                controller: _confirmEmailController,
                hint: 'Re-enter your email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(
                height: AppSpacing.sm,
              ),
              buildField(
                label: 'Password',
                controller: _passwordController,
                hint: 'Create a strong password',
                obscure: true,
              ),
              const SizedBox(
                height: AppSpacing.sm,
              ),
              buildField(
                label: 'Confirm Password',
                controller: _confirmPasswordController,
                hint: 'Re-enter your password',
                obscure: true,
              ),
              const SizedBox(
                height: AppSpacing.md,
              ),
              CheckboxListTile(
                value: agree,
                onChanged: (value) {
                  setState(() {
                    agree = value ?? false;
                  });
                },
                title: RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'I agree to the ',
                        style: TextStyle(
                          color: AppColors.pine,
                        ),
                      ),
                      TextSpan(
                        text: 'Terms of Service',
                        style: const TextStyle(
                          color: AppColors.pine,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: _termsOfServiceRecognizer,
                      ),
                      const TextSpan(
                        text: ' and ',
                        style: TextStyle(
                          color: AppColors.pine,
                        ),
                      ),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: const TextStyle(
                          color: AppColors.pine,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: _privacyPolicyRecognizer,
                      ),
                    ],
                  ),
                ),
              ),
              if (errorMessage != null) ...[
                const SizedBox(
                  height: AppSpacing.sm,
                ),
                Text(
                  errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                ),
              ],
              const SizedBox(
                height: AppSpacing.md,
              ),
              AppButton(
                label: _isSubmitting
                    ? 'CREATING ACCOUNT...'
                    : 'CREATE ACCOUNT',
                onPressed: _isSubmitting ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
