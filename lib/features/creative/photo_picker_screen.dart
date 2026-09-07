import 'package:flutter/material.dart';

import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';
import 'package:pehchaan/core/widgets/app_buttons.dart';
import 'crop_screen.dart';

/// Mock photo picker — tabs over placeholder tiles standing in for the
/// device gallery / camera / already-uploaded shop photos (no real image
/// asset backing this V1 UI-only build).
class PhotoPickerScreen extends StatefulWidget {
  const PhotoPickerScreen({super.key});

  @override
  State<PhotoPickerScreen> createState() => _PhotoPickerScreenState();
}

class _PhotoPickerScreenState extends State<PhotoPickerScreen> {
  int _tab = 0;
  int? _selected;

  static const _tabs = ['My photos', 'Gallery', 'Camera'];

  Future<void> _usePhoto() async {
    final cropped = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const CropScreen()),
    );
    if (cropped != null && mounted) {
      Navigator.of(context).pop(cropped);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Photo choose karein')),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  for (var i = 0; i < _tabs.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _TabChip(
                        label: _tabs[i],
                        selected: _tab == i,
                        onTap: () => setState(() {
                          _tab = i;
                          _selected = null;
                        }),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  itemCount: 9,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  itemBuilder: (context, i) {
                    final selected = _selected == i;
                    return InkWell(
                      onTap: () => setState(() => _selected = i),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.violet200,
                          borderRadius: BorderRadius.circular(8),
                          border: selected ? Border.all(color: AppColors.violet600, width: 3) : null,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(Icons.image_rounded, color: AppColors.violet600),
                            if (selected)
                              const Positioned(
                                top: 6,
                                right: 6,
                                child: Icon(Icons.check_circle_rounded, color: AppColors.violet600, size: 18),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(label: 'Use photo', onPressed: _selected == null ? null : _usePhoto),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.violet600 : AppColors.violet100,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: AppTextStyles.fieldLabel.copyWith(
            color: selected ? Colors.white : AppColors.violet900,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
