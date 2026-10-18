import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'package:pehchaan/core/api/api_client.dart';
import 'package:pehchaan/core/api/device_store.dart';
import 'package:pehchaan/core/api/event_queue.dart';
import 'package:pehchaan/core/api/image_store.dart';
import 'package:pehchaan/core/api/models.dart';
import 'package:pehchaan/core/api/pehchaan_api.dart';
import 'package:pehchaan/core/api/token_store.dart';

enum SessionStage {
  /// Reading local state at launch.
  loading,
  language,
  phone,

  /// Signed in but no `me` yet and the network is down — nothing to route on.
  meUnavailable,
  onboarding,

  /// "Building something for you…" after the first onboarding submit.
  building,
  landing,
  full,
}

/// Owns language, content, tokens and `me`, and derives the screen from
/// them. The routing decision is never cached — it's recomputed from a
/// fresh `GET /v1/me` on every open and resume (§7).
class SessionController extends ChangeNotifier {
  SessionController() {
    ApiClient.instance.onSessionExpired = _onSessionExpired;
  }

  static const _versionCheckInterval = Duration(minutes: 30);

  SessionStage stage = SessionStage.loading;
  String? lang;
  List<Language> languages = Language.bundled;
  ContentPayload? content;
  Me? me;

  /// True while a content download is running and nothing is stored yet.
  bool contentLoading = false;

  bool _signedIn = false;
  bool _syncingContent = false;

  bool get signedIn => _signedIn;

  /// Prefer a server string for [key]; fall back to the bundled copy so a
  /// missing key still renders something (§5.1).
  String t(String key, String fallback) => content?.strings[key] ?? fallback;

  // ── Launch ──────────────────────────────────────────────────────────

  Future<void> init() async {
    lang = await DeviceStore.lang();
    final storedLanguages = await DeviceStore.languages();
    if (storedLanguages != null && storedLanguages.isNotEmpty) {
      languages = storedLanguages.map(Language.fromJson).toList();
    }

    final stored = await DeviceStore.content();
    if (stored != null && stored.lang == lang) {
      content = ContentPayload.fromJson(stored.json);
    }

    _signedIn = await TokenStore.read() != null;
    final storedMe = await DeviceStore.me();
    if (_signedIn && storedMe != null) me = Me.fromJson(storedMe);

    if (lang == null) {
      stage = SessionStage.language;
      unawaited(refreshLanguages());
    } else if (!_signedIn) {
      stage = SessionStage.phone;
    } else {
      // Route from the last known `me` right away, then confirm online.
      stage = me != null ? _stageFor(me!) : SessionStage.meUnavailable;
      unawaited(refreshMe());
    }
    notifyListeners();

    if (lang != null) unawaited(syncContent());
    unawaited(EventQueue.appOpen().then((_) => EventQueue.flush()));
    unawaited(ImageStore.evictIfNeeded());
  }

  Future<void> refreshLanguages() async {
    try {
      final fresh = await PehchaanApi.languages();
      if (fresh.isNotEmpty) {
        languages = fresh;
        notifyListeners();
      }
    } catch (_) {
      // Keep stored/bundled list.
    }
  }

  /// Device locale if it's offered, else Hindi (§4).
  String suggestedLanguage() {
    final device = ui.PlatformDispatcher.instance.locale.languageCode;
    return languages.any((l) => l.code == device) ? device : 'hi';
  }

  // ── Language ────────────────────────────────────────────────────────

  Future<void> chooseLanguage(String code) async {
    final changed = code != lang;
    lang = code;
    await DeviceStore.setLang(code);
    if (changed) {
      content = null;
      await DeviceStore.clearVersionCheck();
    }
    if (stage == SessionStage.language) {
      stage = _signedIn ? (me != null ? _stageFor(me!) : SessionStage.meUnavailable)
          : SessionStage.phone;
    }
    notifyListeners();
    unawaited(syncContent(force: true));
    if (_signedIn) unawaited(_mirrorLanguage());
  }

  Future<void> _mirrorLanguage() async {
    final code = lang;
    if (code == null) return;
    try {
      await PehchaanApi.setAccountLanguage(code);
    } catch (_) {}
  }

  // ── Content (§5.2) ──────────────────────────────────────────────────

  Future<void> syncContent({bool force = false}) async {
    final code = lang;
    if (code == null || _syncingContent) return;
    _syncingContent = true;
    if (content == null) {
      contentLoading = true;
      notifyListeners();
    }
    try {
      if (!force && content != null) {
        final last = await DeviceStore.lastVersionCheck();
        if (last != null && DateTime.now().difference(last) < _versionCheckInterval) {
          return;
        }
      }

      if (content != null) {
        final v = await PehchaanApi.contentVersion(code);
        await DeviceStore.markVersionChecked();
        if (v != null && v == await DeviceStore.contentVersion()) return;
      }

      final stored = await DeviceStore.content();
      final etag = content != null && stored?.lang == code ? stored?.etag : null;
      final res = await PehchaanApi.content(code, etag: etag);
      await DeviceStore.markVersionChecked();
      if (res == null) return; // 304 — what we have is current.

      final parsed = ContentPayload.fromJson(res.json);
      // Language switched while downloading — drop this payload.
      if (lang != code) return;
      await DeviceStore.saveContent(
        json: res.json,
        version: parsed.version,
        lang: code,
        etag: res.etag,
      );
      content = parsed;
      if (parsed.languages.isNotEmpty) {
        languages = parsed.languages;
        unawaited(
          DeviceStore.setLanguages(parsed.languages.map((l) => l.toJson()).toList()),
        );
      }
    } on LanguageGoneException {
      // The language was removed: re-prompt rather than show nothing.
      lang = null;
      content = null;
      stage = SessionStage.language;
      unawaited(refreshLanguages());
    } catch (_) {
      // Offline / 429 / 5xx — keep the old payload and version.
    } finally {
      _syncingContent = false;
      contentLoading = false;
      notifyListeners();
    }
  }

  // ── Auth ────────────────────────────────────────────────────────────

  /// After a successful OTP verify. Branch on `me.business`, never on
  /// `is_new_user` (§6.3).
  Future<void> onSignedIn() async {
    _signedIn = true;
    unawaited(_mirrorLanguage());
    await refreshMe();
    if (me == null) {
      stage = SessionStage.meUnavailable;
      notifyListeners();
    }
  }

  Future<void> signOut({bool everywhere = false}) async {
    everywhere ? await PehchaanApi.logoutEverywhere() : await PehchaanApi.logout();
    await _clearSession();
  }

  void _onSessionExpired() {
    if (!_signedIn) return;
    unawaited(_clearSession());
  }

  Future<void> _clearSession() async {
    await TokenStore.clear();
    await DeviceStore.setMe(null);
    _signedIn = false;
    me = null;
    stage = SessionStage.phone;
    notifyListeners();
  }

  // ── Me (§7) ─────────────────────────────────────────────────────────

  Future<void> refreshMe() async {
    if (!_signedIn) return;
    try {
      final fresh = await PehchaanApi.me();
      _applyMe(fresh);
    } on ApiException catch (e) {
      // 401 after a failed refresh is handled by onSessionExpired; for
      // offline/5xx keep routing on the last stored `me` (§12).
      if (e.statusCode == 401) return;
    } catch (_) {}
  }

  void _applyMe(Me fresh) {
    me = fresh;
    unawaited(DeviceStore.setMe(fresh.raw));
    // Don't yank the user off the "building" screen; it routes itself.
    if (stage != SessionStage.building && stage != SessionStage.language) {
      stage = _stageFor(fresh);
    }
    notifyListeners();
  }

  /// Onboarding / profile-edit submit result.
  void onBusinessSaved(Me fresh, {required bool created}) {
    if (created) stage = SessionStage.building;
    _applyMe(fresh);
  }

  /// Called by the "building" screen when it's done.
  void finishBuilding() {
    stage = me != null ? _stageFor(me!) : SessionStage.meUnavailable;
    notifyListeners();
  }

  SessionStage _stageFor(Me m) {
    if (m.business == null) return SessionStage.onboarding;
    return m.access.hasFullApp ? SessionStage.full : SessionStage.landing;
  }

  // ── Lifecycle ───────────────────────────────────────────────────────

  void onResume() {
    unawaited(refreshMe());
    unawaited(syncContent());
    // Time band may have changed (good morning → good night) — rebuild.
    notifyListeners();
  }

  void onBackground() {
    unawaited(EventQueue.flush());
  }
}

class SessionScope extends InheritedNotifier<SessionController> {
  const SessionScope({
    super.key,
    required SessionController super.notifier,
    required super.child,
  });

  static SessionController of(BuildContext context, {bool listen = true}) {
    final scope = listen
        ? context.dependOnInheritedWidgetOfExactType<SessionScope>()
        : context.getInheritedWidgetOfExactType<SessionScope>();
    assert(scope != null, 'SessionScope not found in context');
    return scope!.notifier!;
  }
}
