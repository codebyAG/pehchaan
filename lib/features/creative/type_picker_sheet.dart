import 'package:flutter/material.dart';

import 'package:pehchaan/core/models/creative.dart';
import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';

class TypePickerSheet extends StatelessWidget {
  const TypePickerSheet({super.key});

  static const _rows = [
    (
      category: CreativeCategory.offer,
      icon: Icons.local_offer_rounded,
      example: '₹999 stitching offer',
    ),
    (
      category: CreativeCategory.festival,
      icon: Icons.celebration_rounded,
      example: 'Diwali greeting + offer',
    ),
    (
      category: CreativeCategory.product,
      icon: Icons.shopping_bag_rounded,
      example: 'New saree collection',
    ),
    (
      category: CreativeCategory.service,
      icon: Icons.content_cut_rounded,
      example: 'Hair spa starting ₹499',
    ),
    (
      category: CreativeCategory.newArrival,
      icon: Icons.fiber_new_rounded,
      example: 'Festive collection 2026',
    ),
    (
      category: CreativeCategory.announcement,
      icon: Icons.campaign_rounded,
      example: 'Shop timing update',
    ),
  ];

  static Future<CreativeCategory?> show(BuildContext context) {
    return showModalBottomSheet<CreativeCategory>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const TypePickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
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
              Text('Kya banana hai?', style: AppTextStyles.sectionHeading),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final row in _rows) ...[
                        InkWell(
                          onTap: () => Navigator.of(context).pop(row.category),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            height: 64,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.violet100,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  row.icon,
                                  color: AppColors.violet600,
                                  size: 22,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        row.category.label,
                                        style: AppTextStyles.body.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        row.example,
                                        style: AppTextStyles.fieldLabel,
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppColors.mutedText,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
