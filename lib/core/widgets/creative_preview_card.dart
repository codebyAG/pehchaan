import 'package:flutter/material.dart';

import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';

/// The generated-creative visual: violet ground, yellow tag, big price,
/// business identity pinned to the bottom. Aspect ratio is 1:1 or 9:16.
class CreativePreviewCard extends StatelessWidget {
  const CreativePreviewCard({
    super.key,
    required this.tag,
    required this.title,
    required this.priceText,
    required this.businessName,
    required this.phone,
    this.aspectRatio = 1,
  });

  final String tag;
  final String title;
  final String priceText;
  final String businessName;
  final String phone;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.violet600,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppColors.softShadow,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.yellow500,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                tag,
                style: AppTextStyles.eyebrow.copyWith(
                  color: AppColors.violet900,
                ),
              ),
            ),
            const Spacer(),
            Text(
              title,
              style: AppTextStyles.sectionHeading.copyWith(
                color: Colors.white,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(priceText, style: AppTextStyles.bigNumber),
            const SizedBox(height: 20),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text(
              businessName,
              style: AppTextStyles.body.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              phone,
              style: AppTextStyles.fieldLabel.copyWith(
                color: AppColors.textOnViolet,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
