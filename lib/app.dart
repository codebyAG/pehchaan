import 'package:flutter/material.dart';

import 'core/navigation/root_shell.dart';
import 'core/state/app_state.dart';
import 'core/theme/app_theme.dart';
import 'features/business_setup/business_setup_screen.dart';
import 'features/onboarding/splash_screen.dart';

/// No login/OTP gate for this build — but a complete business profile
/// (name, category, phone, location) is required before Home unlocks,
/// since every AI generation depends on it.
enum _Stage { splash, businessSetup, home }

class PehchaanApp extends StatefulWidget {
  const PehchaanApp({super.key});

  @override
  State<PehchaanApp> createState() => _PehchaanAppState();
}

class _PehchaanAppState extends State<PehchaanApp> {
  final _appState = AppState.withMockData();
  late final Future<void> _hydrateFuture = _appState.hydrate();
  _Stage _stage = _Stage.splash;

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  Future<void> _onSplashFinished() async {
    // Make sure anything saved on-device (a previously completed profile)
    // has loaded before deciding whether setup is needed.
    await _hydrateFuture;
    if (!mounted) return;
    final complete = _appState.business?.isProfileComplete ?? false;
    setState(() => _stage = complete ? _Stage.home : _Stage.businessSetup);
  }

  Widget _buildStage() {
    switch (_stage) {
      case _Stage.splash:
        return SplashScreen(onFinished: _onSplashFinished);
      case _Stage.businessSetup:
        return BusinessSetupScreen(
          prefilledPhone: _appState.business?.phone ?? '',
          onComplete: (business) {
            _appState.setupBusiness(business);
            setState(() => _stage = _Stage.home);
          },
        );
      case _Stage.home:
        return const RootShell();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      notifier: _appState,
      child: MaterialApp(
        title: 'Pehchaan',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: _buildStage(),
      ),
    );
  }
}
