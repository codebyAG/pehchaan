import 'package:flutter/material.dart';

import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';
import 'package:pehchaan/core/widgets/app_buttons.dart';

/// Never shows error codes or model names — plain-language reason only.
class GenerationFailedSheet extends StatelessWidget {
  const GenerationFailedSheet({
    super.key,
    required this.onTryAgain,
    required this.onChangeDetails,
  });

  final VoidCallback onTryAgain;
  final VoidCallback onChangeDetails;

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onTryAgain,
    required VoidCallback onChangeDetails,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => GenerationFailedSheet(
        onTryAgain: onTryAgain,
        onChangeDetails: onChangeDetails,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Creative nahi ban paya', style: AppTextStyles.sectionHeading),
            const SizedBox(height: 8),
            Text('Ek baar phir try karein.', style: AppTextStyles.body),
            const SizedBox(height: 20),
            PrimaryButton(label: 'Try again', onPressed: onTryAgain),
            TextButton(
              onPressed: onChangeDetails,
              child: Text(
                'Change details',
                style: AppTextStyles.body.copyWith(color: AppColors.mutedText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
