import 'package:flutter/material.dart';

import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';

enum _CropAspect { square, story, poster }

extension on _CropAspect {
  String get label {
    switch (this) {
      case _CropAspect.square:
        return '1:1';
      case _CropAspect.story:
        return '9:16';
      case _CropAspect.poster:
        return 'A4';
    }
  }

  double get ratio {
    switch (this) {
      case _CropAspect.square:
        return 1;
      case _CropAspect.story:
        return 9 / 16;
      case _CropAspect.poster:
        return 210 / 297;
    }
  }
}

/// Mock crop UI — the aspect frame and controls are real, the underlying
/// image is a placeholder since this V1 build has no real photo pipeline.
class CropScreen extends StatefulWidget {
  const CropScreen({super.key});

  @override
  State<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends State<CropScreen> {
  _CropAspect _aspect = _CropAspect.square;
  int _quarterTurns = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.violet900,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: _aspect.ratio,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: AppColors.violet200,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: RotatedBox(
                      quarterTurns: _quarterTurns,
                      child: const Icon(
                        Icons.image_rounded,
                        color: AppColors.violet600,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  for (final a in _CropAspect.values)
                    ChoiceChip(
                      label: Text(a.label),
                      selected: _aspect == a,
                      onSelected: (_) => setState(() => _aspect = a),
                      backgroundColor: AppColors.violet800,
                      selectedColor: AppColors.violet600,
                      labelStyle: AppTextStyles.fieldLabel.copyWith(
                        color: Colors.white,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      side: BorderSide.none,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () =>
                      setState(() => _quarterTurns = (_quarterTurns + 1) % 4),
                  child: Text(
                    'Rotate',
                    style: AppTextStyles.body.copyWith(color: Colors.white70),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () => setState(() {
                    _quarterTurns = 0;
                    _aspect = _CropAspect.square;
                  }),
                  child: Text(
                    'Reset',
                    style: AppTextStyles.body.copyWith(color: Colors.white70),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.body.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop('photo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.violet600,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text('Done', style: AppTextStyles.buttonLabel),
                      ),
                    ),
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
