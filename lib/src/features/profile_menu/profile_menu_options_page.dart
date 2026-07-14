import 'package:flutter/material.dart';
import 'package:fluentish/src/shared/shared.dart';

/// "My Details" — lets the user view and edit their profile fields.
class ProfileMenuOptionsPage extends StatefulWidget {
  const ProfileMenuOptionsPage({super.key});

  @override
  State<ProfileMenuOptionsPage> createState() =>
      _ProfileMenuOptionsPageState();
}

class _ProfileMenuOptionsPageState
    extends State<ProfileMenuOptionsPage> {
  final _username = TextEditingController(text: 'Chloe123');
  final _dob = TextEditingController(text: '01-01-2000');
  final _phone = TextEditingController(text: '0123456789');
  final _email = TextEditingController(text: 'chloe123@gmail.com');

  bool _dirty = false;

  @override
  void initState() {
    super.initState();

    for (final c in [_username, _dob, _phone, _email]) {
      c.addListener(() {
        setState(() {
          _dirty = true;
        });
      });
    }
  }

  @override
  void dispose() {
    _username.dispose();
    _dob.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  void _save() {
    setState(() {
      _dirty = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Profile updated."),
      ),
    );
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  //----------------------------------------
                  // Avatar
                  //----------------------------------------

                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const CircleAvatar(
                        radius: 55,
                        backgroundColor: AppColors.cardSurface,
                        child: Icon(
                          Icons.person,
                          size: 56,
                          color: AppColors.pine,
                        ),
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

                  const SizedBox(height: 10),

                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Change Photo",
                      style: TextStyle(
                        color: AppColors.pine,
                      ),
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
                    label: "SAVE CHANGES",
                    backgroundColor: AppColors.pine,
                    foregroundColor: AppColors.blush,
                    onPressed: _dirty ? _save : null,
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
            style: const TextStyle(
              color: AppColors.pine,
            ),
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