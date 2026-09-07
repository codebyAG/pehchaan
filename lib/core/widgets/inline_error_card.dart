import 'package:flutter/material.dart';

import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';

/// Plain-language error, never a code or model name.
class InlineErrorCard extends StatelessWidget {
  const InlineErrorCard({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

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
            onPressed: onRetry,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.violet600,
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 48),
            ),
            child: Text(
              'Try again',
              style: AppTextStyles.buttonLabel.copyWith(color: AppColors.violet600),
            ),
          ),
        ],
      ),
    );
  }
}
