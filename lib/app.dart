import 'package:flutter/material.dart';

import 'core/navigation/root_shell.dart';
import 'core/state/app_state.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/splash_screen.dart';

/// Mock build for the Play Store listing: no auth, no setup gate — splash
/// goes straight into the app with a pre-seeded business and creatives.
enum _Stage { splash, home }

class PehchaanApp extends StatefulWidget {
  const PehchaanApp({super.key});

  @override
  State<PehchaanApp> createState() => _PehchaanAppState();
}

class _PehchaanAppState extends State<PehchaanApp> {
  final _appState = AppState.withMockData();
  _Stage _stage = _Stage.splash;

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  Widget _buildStage() {
    switch (_stage) {
      case _Stage.splash:
        return SplashScreen(
          onFinished: () => setState(() => _stage = _Stage.home),
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
