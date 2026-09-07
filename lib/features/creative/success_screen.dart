import 'package:flutter/material.dart';

import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';
import 'package:pehchaan/core/widgets/app_buttons.dart';
import 'type_picker_sheet.dart';
import 'creative_input_screen.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  Future<void> _createAnother(BuildContext context) async {
    final category = await TypePickerSheet.show(context);
    if (category != null && context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => CreativeInputScreen(category: category)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.violet050,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(color: AppColors.yellow500, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: const Icon(Icons.check_rounded, color: AppColors.violet900, size: 36),
              ),
              const SizedBox(height: 20),
              Text('Ho gaya!', style: AppTextStyles.screenTitle.copyWith(fontSize: 22)),
              const SizedBox(height: 8),
              Text(
                'Creative save ho gaya. Ab isse kahin bhi use karein.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(color: AppColors.mutedText, fontSize: 17),
              ),
              const Spacer(),
              PrimaryButton(label: 'Create another', onPressed: () => _createAnother(context)),
              TextButton(
                onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                child: Text('Go to home', style: AppTextStyles.body.copyWith(color: AppColors.mutedText)),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
