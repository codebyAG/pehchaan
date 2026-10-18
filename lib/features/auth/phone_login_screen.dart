import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:pehchaan/core/api/api_client.dart';
import 'package:pehchaan/core/api/models.dart';
import 'package:pehchaan/core/api/pehchaan_api.dart';
import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';
import 'package:pehchaan/core/widgets/app_buttons.dart';

/// Login and signup are the same call (§6.1). `+91` is drawn as a fixed
/// prefix; only ten digits are sent.
class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key, required this.onOtpSent, this.initialPhone = ''});

  /// Called with the ten-digit number and the server's resend cooldown.
  final void Function(String phone, int retryAfterSec) onOtpSent;
  final String initialPhone;

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  late final _phoneController = TextEditingController(text: widget.initialPhone);
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  bool get _valid => normaliseIndianMobile(_phoneController.text) != null;

  Future<void> _send() async {
    final phone = normaliseIndianMobile(_phoneController.text);
    if (phone == null) {
      setState(() => _error = 'Sahi mobile number daaliye');
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final retryAfter = await PehchaanApi.sendOtp(phone);
      if (!mounted) return;
      widget.onOtpSent(phone, retryAfter);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = switch (e.statusCode) {
        400 => 'Sahi mobile number daaliye',
        429 => e.retryAfterSec != null
            ? '${e.message} (${e.retryAfterSec}s baad try karein)'
            : e.message,
        0 => 'Internet connection check karein',
        // 503 is a provider problem, never a number problem.
        _ => 'Code nahi bhej paaye, dobara try karein',
      });
    } finally {
      if (mounted) setState(() => _sending = false);
    }
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
                        keyboardType: TextInputType.phone,
                        autofocus: true,
                        // Accept pasted `+91 98765-43210` / `0987…` and keep
                        // just the ten digits.
                        inputFormatters: [IndianMobileFormatter()],
                        onChanged: (_) => setState(() => _error = null),
                        onSubmitted: (_) => _valid && !_sending ? _send() : null,
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
                            borderSide: _error != null
                                ? const BorderSide(color: AppColors.error, width: 2)
                                : BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: _error != null ? AppColors.error : AppColors.violet600,
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
                _error ?? 'OTP se verify karenge. Koi password nahi.',
                style: AppTextStyles.fieldLabel.copyWith(
                  color: _error != null ? AppColors.error : null,
                ),
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
                label: _sending ? 'Bhej rahe hain…' : 'Send OTP',
                onPressed: _valid && !_sending ? _send : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Keeps the field to ten digits, unwrapping a pasted `+91…` or `0…`
/// prefix instead of rejecting the paste.
class IndianMobileFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue next) {
    var digits = next.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 10) {
      digits = normaliseIndianMobile(digits) ?? digits.substring(0, 10);
    }
    return TextEditingValue(
      text: digits,
      selection: TextSelection.collapsed(offset: digits.length),
    );
  }
}
