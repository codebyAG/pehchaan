import 'package:flutter/material.dart';

import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';
import 'package:pehchaan/core/widgets/app_buttons.dart';

class NotificationPermissionScreen extends StatelessWidget {
  const NotificationPermissionScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.violet200,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.notifications_active_rounded, color: AppColors.violet600, size: 48),
              ),
              const SizedBox(height: 24),
              Text('Festival reminders chahiye?', style: AppTextStyles.screenTitle),
              const SizedBox(height: 12),
              Text(
                'Diwali, Holi, Eid se pehle hum aapko creative banane ki yaad dila denge.',
                style: AppTextStyles.body,
              ),
              const Spacer(),
              PrimaryButton(label: 'Allow notifications', onPressed: onDone),
              TextButton(
                onPressed: onDone,
                child: Text('Not now', style: AppTextStyles.body.copyWith(color: AppColors.mutedText)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
