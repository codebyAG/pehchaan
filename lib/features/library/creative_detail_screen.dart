import 'package:flutter/material.dart';

import 'package:pehchaan/core/models/creative.dart';
import 'package:pehchaan/core/state/app_state.dart';
import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';
import 'package:pehchaan/core/widgets/creative_preview_card.dart';
import 'package:pehchaan/features/creative/format_download_screen.dart';
import 'package:pehchaan/features/creative/generating_screen.dart';

class CreativeDetailScreen extends StatelessWidget {
  const CreativeDetailScreen({super.key, required this.creative});

  final Creative creative;

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Creative delete kar dein?',
          style: AppTextStyles.sectionHeading,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTextStyles.body.copyWith(color: AppColors.violet600),
            ),
          ),
          TextButton(
            onPressed: () {
              AppStateScope.of(context, listen: false).removeCreative(creative);
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              'Delete',
              style: AppTextStyles.body.copyWith(
                color: const Color(0xFFD94A2B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.violet900,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: InteractiveViewer(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: CreativePreviewCard(
                      tag: creative.category.label,
                      title: creative.title,
                      priceText: creative.priceText,
                      businessName: creative.businessName,
                      phone: creative.phone,
                      aspectRatio: creative.format.aspectRatio,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    creative.category.label,
                    style: AppTextStyles.fieldLabel.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    ' · ',
                    style: AppTextStyles.fieldLabel.copyWith(
                      color: Colors.white54,
                    ),
                  ),
                  Text(
                    creative.format.label,
                    style: AppTextStyles.fieldLabel.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    ' · ',
                    style: AppTextStyles.fieldLabel.copyWith(
                      color: Colors.white54,
                    ),
                  ),
                  Text(
                    '${creative.createdAt.day}/${creative.createdAt.month}',
                    style: AppTextStyles.fieldLabel.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActionIcon(
                    icon: Icons.download_rounded,
                    label: 'Download',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => FormatDownloadScreen(
                          category: creative.category,
                          title: creative.title,
                          priceText: creative.priceText,
                          businessName: creative.businessName,
                          phone: creative.phone,
                          format: creative.format,
                        ),
                      ),
                    ),
                  ),
                  _ActionIcon(
                    icon: Icons.share_rounded,
                    label: 'Share',
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Share sheet khul raha hai'),
                      ),
                    ),
                  ),
                  _ActionIcon(
                    icon: Icons.refresh_rounded,
                    label: 'Regenerate',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => GeneratingScreen(
                          category: creative.category,
                          title: creative.title,
                          priceText: creative.priceText,
                          format: creative.format,
                        ),
                      ),
                    ),
                  ),
                  _ActionIcon(
                    icon: Icons.delete_rounded,
                    label: 'Delete',
                    onTap: () => _confirmDelete(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTextStyles.fieldLabel.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
