import 'package:flutter/material.dart';

import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';
import 'package:pehchaan/core/widgets/app_buttons.dart';

/// Blocking screen — user cannot proceed until they update from Play Store.
class UpdateRequiredScreen extends StatelessWidget {
  const UpdateRequiredScreen({super.key, required this.onUpdate});

  final VoidCallback onUpdate;

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
                  decoration: BoxDecoration(
                    color: AppColors.violet200,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.system_update_rounded,
                    color: AppColors.violet600,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Naya version aa gaya hai',
                  style: AppTextStyles.sectionHeading,
                ),
                const SizedBox(height: 24),
                PrimaryButton(label: 'Update now', onPressed: onUpdate),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
