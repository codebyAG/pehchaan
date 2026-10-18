import 'dart:async';

import 'package:flutter/material.dart';

import 'core/api/image_store.dart';
import 'core/api/models.dart';
import 'core/models/business.dart';
import 'core/navigation/root_shell.dart';
import 'core/state/app_state.dart';
import 'core/state/session.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_text_styles.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_buttons.dart';
import 'features/auth/auth_flow.dart';
import 'features/business_setup/business_form_screen.dart';
import 'features/landing/landing_screen.dart';
import 'features/onboarding/building_screen.dart';
import 'features/onboarding/language_select_screen.dart';
import 'features/onboarding/splash_screen.dart';

/// Language → phone + OTP → onboarding → building → landing or full app.
/// The screen is derived from [SessionController.stage], which is
/// recomputed from `GET /v1/me` on every open and resume (§7).
class PehchaanApp extends StatefulWidget {
  const PehchaanApp({super.key});

  @override
  State<PehchaanApp> createState() => _PehchaanAppState();
}

class _PehchaanAppState extends State<PehchaanApp> with WidgetsBindingObserver {
  final _session = SessionController();
  final _appState = AppState();
  final _navigatorKey = GlobalKey<NavigatorState>();

  SessionStage? _lastStage;
  ApiBusiness? _lastBusiness;
  ContentPayload? _lastContent;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _session.addListener(_onSessionChanged);
    _session.init();
    _appState.hydrate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _session.removeListener(_onSessionChanged);
    _session.dispose();
    _appState.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _session.onResume();
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _session.onBackground();
      default:
        break;
    }
  }

  void _onSessionChanged() {
    // A new stage means a new root screen — drop anything pushed on top of
    // the old one (a viewer, a settings page) so it can't linger.
    if (_lastStage != null && _lastStage != _session.stage) {
      _navigatorKey.currentState?.popUntil((r) => r.isFirst);
    }
    _lastStage = _session.stage;
    _syncBusiness();
  }

  /// Mirrors the server profile into [AppState] for the AI creative
  /// screens, which predate the API and use the local [Business] shape.
  void _syncBusiness() {
    final me = _session.me;
    final b = me?.business;
    if (identical(b, _lastBusiness) && identical(_session.content, _lastContent)) return;
    final logoChanged = b?.logoUrl != _lastBusiness?.logoUrl;
    _lastBusiness = b;
    _lastContent = _session.content;
    if (me == null || b == null) {
      _appState.syncBusiness(null);
      return;
    }
    _appState.syncBusiness(
      Business(
        name: b.shopName,
        category: _session.content?.trade(b.tradeKey)?.name ?? b.tradeKey,
        phone: formatIndianPhone(b.displayPhone ?? me.user.phone),
        city: b.city,
        address: b.address ?? '',
      ),
      logoUrl: b.logoUrl,
    );
    final logoUrl = b.logoUrl;
    if (logoUrl != null && logoChanged) {
      unawaited(
        ImageStore.bytes(logoUrl).then((bytes) {
          if (bytes != null) _appState.setLogoBytes(logoUrl, bytes);
        }),
      );
    }
  }

  Widget _buildStage() {
    switch (_session.stage) {
      case SessionStage.loading:
        return const SplashScreen();
      case SessionStage.language:
        return LanguageSelectScreen(
          languages: _session.languages,
          initial: _session.suggestedLanguage(),
          onContinue: _session.chooseLanguage,
        );
      case SessionStage.phone:
        return const AuthFlow();
      case SessionStage.meUnavailable:
        return _MeUnavailable(onRetry: _session.refreshMe);
      case SessionStage.onboarding:
        return const BusinessFormScreen();
      case SessionStage.building:
        return const BuildingScreen();
      case SessionStage.landing:
        return const LandingScreen();
      case SessionStage.full:
        return const RootShell();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SessionScope(
      notifier: _session,
      child: AppStateScope(
        notifier: _appState,
        child: MaterialApp(
          title: 'Pehchaan',
          navigatorKey: _navigatorKey,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: ListenableBuilder(
            listenable: _session,
            builder: (context, _) => _buildStage(),
          ),
        ),
      ),
    );
  }
}

/// Signed in, but `GET /v1/me` has never succeeded on this device and the
/// network is down — there's nothing to route on yet.
class _MeUnavailable extends StatefulWidget {
  const _MeUnavailable({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  State<_MeUnavailable> createState() => _MeUnavailableState();
}

class _MeUnavailableState extends State<_MeUnavailable> {
  bool _busy = false;

  Future<void> _retry() async {
    setState(() => _busy = true);
    await widget.onRetry();
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 56, color: AppColors.mutedText),
              const SizedBox(height: 16),
              Text(
                'Internet connection check karein',
                textAlign: TextAlign.center,
                style: AppTextStyles.sectionHeading,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: _busy ? 'Check kar rahe hain…' : 'Dobara try karein',
                onPressed: _busy ? null : _retry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
