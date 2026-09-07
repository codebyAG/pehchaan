import 'package:flutter/material.dart';

import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: SafeArea(
        top: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    'assets/pehchaanapp_logo.png',
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Pehchaan',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.violet900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Har Kaam Ko Mile Pehchaan.',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.mutedText,
                  ),
                ),
                const SizedBox(height: 6),
                Text('Version 1.0.0', style: AppTextStyles.fieldLabel),
                const SizedBox(height: 4),
                Text('Made in India', style: AppTextStyles.fieldLabel),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 16,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final link in [
                      'Website',
                      'Privacy Policy',
                      'Terms',
                      'Licenses',
                    ])
                      Text(
                        link,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.violet600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
