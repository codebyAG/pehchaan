import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';

/// The generated-creative visual: yellow tag, big price, business identity
/// pinned to the bottom. Aspect ratio is 1:1 or 9:16.
///
/// When [imageBytes] is given (a real AI-generated photo — which is
/// deliberately generated with no text baked into the pixels), the photo
/// fills the card and all this text is overlaid on top over a bottom
/// scrim, the way a real poster layers text over a photo. Without it,
/// falls back to a flat violet ground for the mock/demo cards.
class CreativePreviewCard extends StatelessWidget {
  const CreativePreviewCard({
    super.key,
    required this.tag,
    required this.title,
    required this.priceText,
    required this.businessName,
    required this.phone,
    this.aspectRatio = 1,
    this.imageBytes,
    this.logoBytes,
  });

  final String tag;
  final String title;
  final String priceText;
  final String businessName;
  final String phone;
  final double aspectRatio;
  final Uint8List? imageBytes;

  /// The business's actual uploaded logo — composited on top, never
  /// AI-generated, since a text-to-image model can't reliably reproduce a
  /// specific real logo.
  final Uint8List? logoBytes;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageBytes != null;

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.violet600,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppColors.softShadow,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasImage) Image.memory(imageBytes!, fit: BoxFit.cover),
            if (hasImage)
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.0),
                      Colors.black.withValues(alpha: 0.75),
                    ],
                    stops: const [0.45, 1.0],
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.yellow500,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          tag,
                          style: AppTextStyles.eyebrow.copyWith(color: AppColors.violet900),
                        ),
                      ),
                      if (logoBytes != null)
                        Container(
                          width: 40,
                          height: 40,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(color: Color(0x33000000), blurRadius: 8),
                            ],
                          ),
                          child: Image.memory(logoBytes!, fit: BoxFit.cover),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: AppTextStyles.sectionHeading.copyWith(color: Colors.white, fontSize: 22),
                  ),
                  const SizedBox(height: 8),
                  Text(priceText, style: AppTextStyles.bigNumber),
                  const SizedBox(height: 20),
                  Container(height: 1, color: Colors.white.withValues(alpha: 0.2)),
                  const SizedBox(height: 16),
                  Text(
                    businessName,
                    style: AppTextStyles.body.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(phone, style: AppTextStyles.fieldLabel.copyWith(color: AppColors.textOnViolet)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
