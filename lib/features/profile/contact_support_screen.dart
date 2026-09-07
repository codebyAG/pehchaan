import 'package:flutter/material.dart';

import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';
import 'package:pehchaan/core/widgets/app_buttons.dart';

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  final _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _send() {
    _snack('Feedback bhej diya gaya');
    _feedbackController.clear();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact support')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            _Row(
              icon: Icons.chat_bubble_rounded,
              label: 'WhatsApp support',
              onTap: () => _snack('WhatsApp khul raha hai'),
            ),
            _Row(
              icon: Icons.email_rounded,
              label: 'Email support',
              onTap: () => _snack('Email app khul raha hai'),
            ),
            _Row(
              icon: Icons.call_rounded,
              label: 'Call (10 am–7 pm)',
              onTap: () => _snack('Call shuru ho raha hai'),
            ),
            const SizedBox(height: 20),
            Text('Feedback', style: AppTextStyles.fieldLabel),
            const SizedBox(height: 8),
            TextField(
              controller: _feedbackController,
              maxLines: 4,
              style: AppTextStyles.body,
              decoration: InputDecoration(
                hintText: 'Apna feedback likhein',
                hintStyle: AppTextStyles.body.copyWith(
                  color: AppColors.mutedText,
                ),
                filled: true,
                fillColor: AppColors.violet100,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.violet600,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(label: 'Send', onPressed: _send),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.violet600, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.mutedText),
          ],
        ),
      ),
    );
  }
}
