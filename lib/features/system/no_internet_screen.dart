import 'package:flutter/material.dart';

import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';
import 'package:pehchaan/core/widgets/app_buttons.dart';

/// Saved creatives stay viewable even offline — this screen only blocks
/// actions that need a connection (generation, etc).
class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(color: AppColors.violet200, borderRadius: BorderRadius.circular(24)),
                  alignment: Alignment.center,
                  child: const Icon(Icons.wifi_off_rounded, color: AppColors.violet600, size: 44),
                ),
                const SizedBox(height: 20),
                Text('Internet nahi hai', style: AppTextStyles.sectionHeading),
                const SizedBox(height: 8),
                Text(
                  'Creative banane ke liye connection chahiye.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(color: AppColors.mutedText),
                ),
                const SizedBox(height: 24),
                PrimaryButton(label: 'Try again', onPressed: onRetry),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
