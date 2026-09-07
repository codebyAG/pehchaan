import 'package:flutter/material.dart';

import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';

/// 44dp rounded-square avatar (initial letter) + business name + "Category · Location".
class BusinessHeaderRow extends StatelessWidget {
  const BusinessHeaderRow({
    super.key,
    required this.businessName,
    required this.category,
    required this.location,
  });

  final String businessName;
  final String category;
  final String location;

  @override
  Widget build(BuildContext context) {
    final initial = businessName.isNotEmpty ? businessName[0].toUpperCase() : '?';
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.violet200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            initial,
            style: AppTextStyles.sectionHeading.copyWith(
              fontSize: 18,
              color: AppColors.violet600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              businessName,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text('$category · $location', style: AppTextStyles.fieldLabel),
          ],
        ),
      ],
    );
  }
}
