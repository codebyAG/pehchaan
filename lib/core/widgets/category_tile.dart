import 'package:flutter/material.dart';

import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';

enum CategoryTileStyle { violet, yellow, neutral }

/// 2-column grid tile used on Home for Offer / Festival / Product / Service / etc.
class CategoryTile extends StatelessWidget {
  const CategoryTile({
    super.key,
    required this.label,
    required this.icon,
    required this.style,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final CategoryTileStyle style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color background;
    final Color foreground;
    switch (style) {
      case CategoryTileStyle.violet:
        background = AppColors.violet600;
        foreground = Colors.white;
        break;
      case CategoryTileStyle.yellow:
        background = AppColors.yellow500;
        foreground = AppColors.violet900;
        break;
      case CategoryTileStyle.neutral:
        background = AppColors.violet100;
        foreground = AppColors.violet900;
        break;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: foreground, size: 26),
            const SizedBox(height: 16),
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
