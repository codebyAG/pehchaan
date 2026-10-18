import 'package:flutter/material.dart';

import 'package:pehchaan/core/theme/app_colors.dart';

/// Shown while local session state loads at launch. Full-bleed violet-600,
/// logo mark centred, nothing else.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.violet600,
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.asset(
            'assets/pehchaanapp_logo.png',
            width: 96,
            height: 96,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
