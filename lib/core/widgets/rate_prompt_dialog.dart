import 'package:flutter/material.dart';

import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';

/// Shown after the 3rd successful download.
class RatePromptDialog extends StatelessWidget {
  const RatePromptDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const RatePromptDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Pehchaan pasand aaya?', style: AppTextStyles.sectionHeading),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Later',
            style: AppTextStyles.body.copyWith(color: AppColors.mutedText),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Rate on Play Store',
            style: AppTextStyles.body.copyWith(
              color: AppColors.violet600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
