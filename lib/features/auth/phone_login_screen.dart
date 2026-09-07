import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';
import 'package:pehchaan/core/widgets/app_buttons.dart';

/// Account with the lowest friction: just a phone number.
class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key, required this.onSendOtp});

  final ValueChanged<String> onSendOtp;

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Apna number daaliye', style: AppTextStyles.screenTitle),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 64,
                    height: 60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.violet100,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '+91',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 60,
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (_) => setState(() {}),
                        style: AppTextStyles.body,
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: '98765 43210',
                          hintStyle: AppTextStyles.body.copyWith(
                            color: AppColors.mutedText,
                          ),
                          filled: true,
                          fillColor: AppColors.violet100,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
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
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'OTP se verify karenge. Koi password nahi.',
                style: AppTextStyles.fieldLabel,
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text.rich(
                  TextSpan(
                    style: AppTextStyles.fieldLabel.copyWith(fontSize: 13),
                    children: const [
                      TextSpan(text: 'Continue karke aap hamari '),
                      TextSpan(
                        text: 'Terms',
                        style: TextStyle(color: AppColors.violet600),
                      ),
                      TextSpan(text: ' aur '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(color: AppColors.violet600),
                      ),
                      TextSpan(text: ' accept karte hain.'),
                    ],
                  ),
                ),
              ),
              PrimaryButton(
                label: 'Send OTP',
                onPressed: _phoneController.text.length == 10
                    ? () => widget.onSendOtp(_phoneController.text)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
