import 'package:flutter/material.dart';

import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';
import 'package:pehchaan/core/widgets/app_buttons.dart';

class ManagePhotosScreen extends StatefulWidget {
  const ManagePhotosScreen({super.key});

  @override
  State<ManagePhotosScreen> createState() => _ManagePhotosScreenState();
}

class _ManagePhotosScreenState extends State<ManagePhotosScreen> {
  final List<int> _photos = List.generate(3, (i) => i);

  void _addPhoto() {
    if (_photos.length >= 12) return;
    setState(() => _photos.add(_photos.length));
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shop aur product photos')),
      backgroundColor: AppColors.violet050,
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (final p in _photos)
                          Stack(
                            children: [
                              Container(
                                width: 104,
                                height: 104,
                                decoration: BoxDecoration(
                                  color: AppColors.violet200,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.storefront_rounded,
                                  color: AppColors.violet600,
                                  size: 32,
                                ),
                              ),
                              Positioned(
                                top: 6,
                                right: 6,
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _photos.remove(p)),
                                  child: Container(
                                    width: 22,
                                    height: 22,
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                      color: AppColors.violet900,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        if (_photos.length < 12)
                          InkWell(
                            onTap: _addPhoto,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: 104,
                              height: 104,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.violet100,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.add_rounded,
                                color: AppColors.violet600,
                                size: 26,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text('Logo', style: AppTextStyles.sectionHeading),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.violet200,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.image_rounded,
                            color: AppColors.violet600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        TextButton(
                          onPressed: () =>
                              _snack(context, 'Logo replace ho gaya'),
                          child: Text(
                            'Replace',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.violet600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              _snack(context, 'Logo remove ho gaya'),
                          child: Text(
                            'Remove',
                            style: AppTextStyles.body.copyWith(
                              color: const Color(0xFFD94A2B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text('Brand colour', style: AppTextStyles.sectionHeading),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        for (final c in [
                          AppColors.violet600,
                          AppColors.yellow500,
                          AppColors.violet900,
                          Colors.teal,
                          Colors.pink,
                        ])
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.violet100,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Use Pehchaan colours',
                            style: AppTextStyles.fieldLabel.copyWith(
                              color: AppColors.violet600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Save',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
