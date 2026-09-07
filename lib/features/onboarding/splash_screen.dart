import 'package:flutter/material.dart';

import 'package:pehchaan/core/theme/app_colors.dart';

/// Session check. Full-bleed violet-600, logo mark centred, nothing else. Max 1.5s.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) widget.onFinished();
    });
  }

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
