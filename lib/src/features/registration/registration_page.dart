// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:fluentish/src/features/login/login_page.dart';
import 'package:fluentish/src/shared/shared.dart';

import 'package:firebase_auth/firebase_auth.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key, this.auth});

  final AuthGateway? auth;

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  String? errorMessage;
  bool _isSubmitting = false;
  bool isLogin = true;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _preferredNameController =
      TextEditingController();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _confirmEmailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool agree = false;

  AuthGateway get _auth => widget.auth ?? Auth.instance;

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

    super.dispose();
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
    );
  }

  Widget buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    TextInputType? keyboardType,
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
        const SizedBox(height: AppSpacing.xs),
        AppTextField(
          controller: controller,
          hintText: hint,
          obscureText: obscure,
          keyboardType: keyboardType,
        ),
      ],
    );
  }

  //displays error message
  Widget _errorMessage() {
    final message = errorMessage;
    if (message == null || message.isEmpty) {
      return const SizedBox.shrink();
    }

    return Text(
      message,
      style: GoogleFonts.itim(
        color: Colors.red.shade800,
        fontSize: 15,
      ),
    );
  }

  Future<void> createUser() async {
    if (_isSubmitting) {
      return;
    }

    //remove unwanted spaces
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final preferredName = _preferredNameController.text.trim();
    final username = _usernameController.text.trim();
    final dob = _dobController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _controllerEmail.text.trim();
    final confirmEmail = _confirmEmailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    //ensure all fields are filled

    if (preferredName.isEmpty) {
      setState(() {
        errorMessage = 'Preferred name is required';
      });
      return;
    }

    if (username.isEmpty) {
      setState(() {
        errorMessage = 'Username is required';
      });
      return;
    }

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        confirmEmail.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        dob.isEmpty ||
        phone.isEmpty) {
      setState(() {
        errorMessage = 'Please fill in all fields';
      });
      return;
    }

    //ensures passwords match
    if (password != confirmPassword) {
      setState(() {
        errorMessage = 'Passwords do not match';
      });
      return;
    }

    if (email.toLowerCase() != confirmEmail.toLowerCase()) {
      setState(() {
        errorMessage = 'Email addresses do not match';
      });
      return;
    }

    if (agree == false) {
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
      //create entry and store user info
      await _auth.createUser(
        firstName: firstName,
        lastName: lastName,
        preferredName: preferredName,
        username: username,
        email: email,
        password: password,
        dateOfBirth: dob,
        phoneNumber: phone,
      );

      if (!mounted) {
        return;
      }

      //if error display error
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
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
      backgroundColor: AppColors.blush,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.pine,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: AppStrokeText(
                  'CREATE ACCOUNT',
                  fontSize: 36,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: buildField(
                      label: 'FIRST NAME:',
                      controller: _firstNameController,
                      hint: 'e.g Chloe',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: buildField(
                      label: 'LAST NAME:',
                      controller: _lastNameController,
                      hint: 'e.g Nguyen',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              buildField(
                label: 'PREFERRED NAME:',
                controller: _preferredNameController,
                hint: 'e.g Chloe',
              ),
              const SizedBox(height: AppSpacing.md),
              buildField(
                label: 'USERNAME:',
                controller: _usernameController,
                hint: 'e.g Chloe123',
              ),
              const SizedBox(height: AppSpacing.md),
              buildField(
                label: 'DATE OF BIRTH:',
                controller: _dobController,
                hint: 'DD/MM/YYYY',
              ),
              const SizedBox(height: AppSpacing.md),
              buildField(
                label: 'PHONE NUMBER:',
                controller: _phoneController,
                hint: '0412345678',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppSpacing.md),
              buildField(
                label: 'EMAIL:',
                controller: _controllerEmail,
                hint: 'example@gmail.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppSpacing.md),
              buildField(
                label: 'CONFIRM EMAIL:',
                controller: _confirmEmailController,
                hint: 'example@gmail.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppSpacing.md),
              buildField(
                label: 'PASSWORD:',
                controller: _passwordController,
                hint: 'Minimum 8 characters',
                obscure: true,
              ),
              const SizedBox(height: AppSpacing.md),
              buildField(
                label: 'CONFIRM PASSWORD:',
                controller: _confirmPasswordController,
                hint: 'Re-enter password',
                obscure: true,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: agree,
                    activeColor: AppColors.pine,
                    onChanged: (value) {
                      setState(() {
                        agree = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: RichText(
                        text: TextSpan(
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.pine,
                            fontSize: 12,
                          ),
                          children: const [
                            TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: ', and confirm I am 18 years or older.',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              _errorMessage(),
              if (errorMessage != null && errorMessage!.isNotEmpty)
                const SizedBox(height: AppSpacing.md),
              AppButton(
                label: 'CREATE ACCOUNT',
                backgroundColor: AppColors.pine,
                foregroundColor: AppColors.blush,
                onPressed: createUser,
              ),
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: GestureDetector(
                  onTap: _goToLogin,
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.pine,
                      ),
                      children: const [
                        TextSpan(
                          text: 'Already have an account? ',
                        ),
                        TextSpan(
                          text: 'Log in',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
