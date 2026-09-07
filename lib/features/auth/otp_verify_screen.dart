import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';
import 'package:pehchaan/core/widgets/app_buttons.dart';

class OtpVerifyScreen extends StatefulWidget {
  const OtpVerifyScreen({
    super.key,
    required this.phone,
    required this.onVerified,
    required this.onChangeNumber,
  });

  final String phone;
  final VoidCallback onVerified;
  final VoidCallback onChangeNumber;

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());
  bool _error = false;
  int _secondsLeft = 28;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = 28;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    setState(() => _error = false);
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    final code = _controllers.map((c) => c.text).join();
    if (code.length == 6) {
      _verify(code);
    }
  }

  void _verify(String code) {
    if (code == '000000' || code.length < 6) {
      setState(() => _error = true);
      return;
    }
    widget.onVerified();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('OTP daaliye', style: AppTextStyles.screenTitle),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('+91 ${widget.phone} par bheja gaya · ', style: AppTextStyles.fieldLabel),
                  GestureDetector(
                    onTap: widget.onChangeNumber,
                    child: Text(
                      'Change',
                      style: AppTextStyles.fieldLabel.copyWith(color: AppColors.violet600, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) {
                  return SizedBox(
                    width: 52,
                    height: 60,
                    child: TextField(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: AppTextStyles.sectionHeading,
                      onChanged: (v) => _onDigitChanged(i, v),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: AppColors.violet100,
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: _error
                              ? const BorderSide(color: Color(0xFFD94A2B), width: 2)
                              : BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _error ? const Color(0xFFD94A2B) : AppColors.violet600,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              if (_error) ...[
                const SizedBox(height: 12),
                Text(
                  'Galat OTP. Dobara try karein.',
                  style: AppTextStyles.fieldLabel.copyWith(color: const Color(0xFFD94A2B)),
                ),
              ],
              const SizedBox(height: 20),
              TextButton(
                onPressed: _secondsLeft == 0 ? _startTimer : null,
                style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
                child: Text(
                  _secondsLeft == 0
                      ? 'Dobara bhejein'
                      : 'Dobara bhejein (00:${_secondsLeft.toString().padLeft(2, '0')})',
                  style: AppTextStyles.body.copyWith(
                    color: _secondsLeft == 0 ? AppColors.violet600 : AppColors.mutedText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Verify',
                onPressed: () => _verify(_controllers.map((c) => c.text).join()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
