import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:pehchaan/core/api/api_client.dart';
import 'package:pehchaan/core/api/pehchaan_api.dart';
import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';
import 'package:pehchaan/core/widgets/app_buttons.dart';

/// Verify, resend (text or voice) and lockout handling (§6.2–6.4). The
/// countdown always comes from the server's `retry_after_sec`.
class OtpVerifyScreen extends StatefulWidget {
  const OtpVerifyScreen({
    super.key,
    required this.phone,
    required this.initialRetryAfterSec,
    required this.onVerified,
    required this.onChangeNumber,
  });

  final String phone;
  final int initialRetryAfterSec;
  final Future<void> Function() onVerified;
  final VoidCallback onChangeNumber;

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  Timer? _timer;
  int _secondsLeft = 0;

  bool _verifying = false;
  bool _resending = false;

  /// Locked after too many wrong codes: no verify, no resend, just wait.
  bool _locked = false;

  /// Offer "Call me instead" once a text resend has been tried.
  bool _offerVoice = false;
  String? _error;
  String? _info;

  @override
  void initState() {
    super.initState();
    _startCountdown(widget.initialRetryAfterSec);
  }

  void _startCountdown(int seconds) {
    _timer?.cancel();
    setState(() => _secondsLeft = seconds);
    if (seconds <= 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() {
          _secondsLeft = 0;
          _locked = false;
        });
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _controller.text;
    if (code.length != 6 || _verifying || _locked) return;
    setState(() {
      _verifying = true;
      _error = null;
      _info = null;
    });
    try {
      await PehchaanApi.verifyOtp(widget.phone, code);
      await widget.onVerified();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        switch (e.statusCode) {
          case 401:
            _error = 'Galat ya expire ho chuka code';
            _controller.clear();
          case 429:
            _locked = true;
            _error = e.message;
            _startCountdown(e.retryAfterSec ?? 900);
          case 0:
            _error = 'Internet connection check karein';
          default:
            // 503 is a provider issue — never tell the user the code was
            // wrong, or they retype a correct one until locked out.
            _error = 'Verify nahi ho paaya, dobara try karein';
        }
      });
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _resend({required bool voice}) async {
    setState(() {
      _resending = true;
      _error = null;
      _info = null;
    });
    try {
      final retryAfter = await PehchaanApi.resendOtp(widget.phone, voice: voice);
      if (!mounted) return;
      setState(() {
        _info = voice ? 'Aapko call aa raha hai' : 'Code dobara bhej diya';
        _offerVoice = true;
      });
      _startCountdown(retryAfter);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _offerVoice = true;
        _error = e.statusCode == 0
            ? 'Internet connection check karein'
            : e.statusCode == 429
            ? e.message
            : 'Code nahi bhej paaye, dobara try karein';
      });
      if (e.retryAfterSec != null) _startCountdown(e.retryAfterSec!);
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  String get _countdownLabel {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final canResend = _secondsLeft == 0 && !_resending && !_locked;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) widget.onChangeNumber();
      },
      child: Scaffold(
        appBar: AppBar(leading: BackButton(onPressed: widget.onChangeNumber)),
        body: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('OTP daaliye', style: AppTextStyles.screenTitle),
                const SizedBox(height: 8),
                Wrap(
                  children: [
                    Text(
                      '+91 ${widget.phone} par bheja gaya · ',
                      style: AppTextStyles.fieldLabel,
                    ),
                    GestureDetector(
                      onTap: widget.onChangeNumber,
                      child: Text(
                        'Change',
                        style: AppTextStyles.fieldLabel.copyWith(
                          color: AppColors.violet600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _OtpBoxes(
                  controller: _controller,
                  focusNode: _focus,
                  error: _error != null,
                  enabled: !_locked && !_verifying,
                  onChanged: (v) {
                    setState(() => _error = null);
                    if (v.length == 6) _verify();
                  },
                ),
                if (_error != null || _info != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error ?? _info!,
                    style: AppTextStyles.fieldLabel.copyWith(
                      color: _error != null ? AppColors.error : AppColors.violet600,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                if (_locked)
                  Text(
                    'Bahut baar galat code — $_countdownLabel baad try karein',
                    style: AppTextStyles.body.copyWith(color: AppColors.mutedText),
                  )
                else
                  Wrap(
                    spacing: 8,
                    children: [
                      TextButton(
                        onPressed: canResend ? () => _resend(voice: false) : null,
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: Text(
                          _secondsLeft == 0
                              ? 'Dobara bhejein'
                              : 'Dobara bhejein ($_countdownLabel)',
                          style: AppTextStyles.body.copyWith(
                            color: canResend ? AppColors.violet600 : AppColors.mutedText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (_offerVoice)
                        TextButton.icon(
                          onPressed: canResend ? () => _resend(voice: true) : null,
                          icon: Icon(
                            Icons.call_rounded,
                            size: 18,
                            color: canResend ? AppColors.violet600 : AppColors.mutedText,
                          ),
                          label: Text(
                            'Call karke batayein',
                            style: AppTextStyles.body.copyWith(
                              color: canResend ? AppColors.violet600 : AppColors.mutedText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                const Spacer(),
                PrimaryButton(
                  label: _verifying ? 'Verify ho raha hai…' : 'Verify',
                  onPressed: _controller.text.length == 6 && !_verifying && !_locked
                      ? _verify
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Six boxes drawn over one real text field, so paste and SMS autofill of
/// the whole code work.
class _OtpBoxes extends StatelessWidget {
  const _OtpBoxes({
    required this.controller,
    required this.focusNode,
    required this.error,
    required this.enabled,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool error;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Stack(
        children: [
          ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, value, _) {
              final text = value.text;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) {
                  final active = focusNode.hasFocus && i == text.length.clamp(0, 5);
                  return Container(
                    width: 48,
                    height: 60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.violet100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: error
                            ? AppColors.error
                            : active
                            ? AppColors.violet600
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      i < text.length ? text[i] : '',
                      style: AppTextStyles.sectionHeading,
                    ),
                  );
                }),
              );
            },
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                enabled: enabled,
                autofocus: true,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                maxLength: 6,
                showCursor: false,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: onChanged,
                decoration: const InputDecoration(counterText: ''),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
