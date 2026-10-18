import 'dart:typed_data';

import 'api_client.dart';
import 'device_store.dart';
import 'models.dart';
import 'token_store.dart';

/// Thrown when `/v1/version` or `/v1/content` 404s — the language was
/// removed server-side (§12).
class LanguageGoneException implements Exception {}

/// Typed wrappers over every endpoint in §3.
class PehchaanApi {
  PehchaanApi._();

  static final _c = ApiClient.instance;

  // ── Languages & content (no token, ever) ────────────────────────────

  static Future<List<Language>> languages() async {
    final res = await _c.get('/v1/languages');
    final list = (res.json['languages'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => e.cast<String, dynamic>())
        .toList();
    await DeviceStore.setLanguages(list);
    return list.map(Language.fromJson).where((l) => l.code.isNotEmpty).toList();
  }

  static Future<int?> contentVersion(String lang) async {
    try {
      final res = await _c.get('/v1/version', query: {'lang': lang});
      final v = res.json['content'];
      return v is num ? v.toInt() : null;
    } on ApiException catch (e) {
      if (e.statusCode == 404) throw LanguageGoneException();
      rethrow;
    }
  }

  /// Returns null on `304 Not Modified`.
  static Future<({Map<String, dynamic> json, String? etag})?> content(
    String lang, {
    String? etag,
  }) async {
    try {
      final res = await _c.get(
        '/v1/content',
        query: {'lang': lang},
        headers: etag == null ? null : {'If-None-Match': etag},
      );
      if (res.statusCode == 304) return null;
      return (json: res.json, etag: res.headers['etag']);
    } on ApiException catch (e) {
      if (e.statusCode == 404) throw LanguageGoneException();
      rethrow;
    }
  }

  static Future<void> sendEvents(List<Map<String, dynamic>> events) async {
    await _c.post('/v1/events', {
      'device_id': await DeviceStore.deviceId(),
      'events': events,
    });
  }

  // ── Auth ────────────────────────────────────────────────────────────

  /// Returns `retry_after_sec` for the Resend countdown.
  static Future<int> sendOtp(String phone) async {
    final res = await _c.post('/v1/auth/otp/send', {'phone': phone});
    return (res.json['retry_after_sec'] as num?)?.toInt() ?? 30;
  }

  static Future<int> resendOtp(String phone, {required bool voice}) async {
    final res = await _c.post('/v1/auth/otp/resend', {
      'phone': phone,
      'channel': voice ? 'voice' : 'text',
    });
    return (res.json['retry_after_sec'] as num?)?.toInt() ?? 30;
  }

  static Future<void> verifyOtp(String phone, String otp) async {
    final res = await _c.post('/v1/auth/otp/verify', {
      'phone': phone,
      'otp': otp,
      'device_id': await DeviceStore.deviceId(),
    });
    await TokenStore.write(
      AuthTokens.fromJson(res.json['tokens'] as Map<String, dynamic>),
    );
  }

  /// Signs out this device. Clears local tokens whatever the response.
  static Future<void> logout() async {
    final tokens = await TokenStore.read();
    await TokenStore.clear();
    if (tokens == null) return;
    try {
      await _c.post('/v1/auth/logout', {'refresh_token': tokens.refreshToken});
    } catch (_) {}
  }

  /// Signs out every device. Clears local tokens whatever the response.
  static Future<void> logoutEverywhere() async {
    try {
      await _c.authed('DELETE', '/v1/auth/me');
    } catch (_) {}
    await TokenStore.clear();
  }

  static Future<void> setAccountLanguage(String code) async {
    await _c.authed('PATCH', '/v1/auth/me', body: {'language': code});
  }

  // ── Me ──────────────────────────────────────────────────────────────

  static Future<Me> me() async {
    final res = await _c.authed('GET', '/v1/me');
    return Me.fromJson(res.json);
  }

  /// Full replace (§8.2). Returns the new `me` and whether this was the
  /// first onboarding (`201` — trial just started).
  static Future<({Me me, bool created})> putBusiness(
    Map<String, dynamic> body,
  ) async {
    final res = await _c.authed('PUT', '/v1/me/business', body: body);
    return (me: Me.fromJson(res.json), created: res.statusCode == 201);
  }

  /// `kind` is `logo` or `shop_photo`. Returns the URL to put in the form.
  static Future<String> upload({
    required String kind,
    required Uint8List bytes,
  }) async {
    final res = await _c.upload(
      kind: kind,
      bytes: bytes,
      filename: '$kind.${_extensionFor(bytes)}',
    );
    final url = res.json['url'];
    if (url is! String) throw ApiException(500, 'Upload returned no URL');
    return url;
  }

  static String _extensionFor(Uint8List b) {
    if (b.length > 3 && b[0] == 0x89 && b[1] == 0x50) return 'png';
    if (b.length > 11 && b[8] == 0x57 && b[9] == 0x45) return 'webp';
    return 'jpg';
  }
}
