import 'package:flutter/material.dart';

import 'package:pehchaan/core/state/session.dart';
import 'otp_verify_screen.dart';
import 'phone_login_screen.dart';

/// Phone → OTP as one stage, so nothing is left pushed on the navigator
/// when sign-in completes and the session routes onward.
class AuthFlow extends StatefulWidget {
  const AuthFlow({super.key});

  @override
  State<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<AuthFlow> {
  String _phone = '';
  int? _retryAfter;

  @override
  Widget build(BuildContext context) {
    if (_retryAfter == null) {
      return PhoneLoginScreen(
        initialPhone: _phone,
        onOtpSent: (phone, retryAfter) => setState(() {
          _phone = phone;
          _retryAfter = retryAfter;
        }),
      );
    }
    return OtpVerifyScreen(
      phone: _phone,
      initialRetryAfterSec: _retryAfter!,
      onChangeNumber: () => setState(() => _retryAfter = null),
      onVerified: () => SessionScope.of(context, listen: false).onSignedIn(),
    );
  }
}
