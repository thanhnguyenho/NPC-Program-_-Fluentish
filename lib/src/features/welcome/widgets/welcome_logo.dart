import 'package:flutter/material.dart';

import 'package:fluentish/src/shared/shared.dart';

class WelcomeLogo extends StatelessWidget {
  const WelcomeLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        AppAssets.fluentishLogo,
        height: 320,
        fit: BoxFit.contain,
      ),
    );
  }
}