import 'package:flutter/material.dart';

import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';

class PermissionDeniedCard extends StatelessWidget {
  const PermissionDeniedCard({
    super.key,
    required this.message,
    required this.onOpenSettings,
  });

  final String message;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.violet100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: AppTextStyles.body),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onOpenSettings,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.violet600,
              padding: EdgeInsets.zero,
            ),
            child: Text(
              'Open settings',
              style: AppTextStyles.buttonLabel.copyWith(
                color: AppColors.violet600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
