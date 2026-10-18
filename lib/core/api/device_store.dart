import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Everything the API flow keeps on the device (§13), apart from tokens,
/// which live in secure storage. Every call swallows its own failures —
/// a storage hiccup must never strand the app.
class DeviceStore {
  DeviceStore._();

  static const _langKey = 'pehchaan.lang';
  static const _languagesKey = 'pehchaan.languages';
  static const _contentVersionKey = 'pehchaan.contentVersion';
  static const _contentLangKey = 'pehchaan.contentLang';
  static const _contentEtagKey = 'pehchaan.contentEtag';
  static const _lastVersionCheckKey = 'pehchaan.lastVersionCheck';
  static const _meKey = 'pehchaan.me';
  static const _deviceIdKey = 'pehchaan.deviceId';
  static const _eventQueueKey = 'pehchaan.eventQueue';
  static const _contentFile = 'content.json';

  static Future<SharedPreferences?> _prefs() async {
    try {
      return await SharedPreferences.getInstance();
    } catch (_) {
      return null;
    }
  }

  static Future<String?> _getString(String key) async =>
      (await _prefs())?.getString(key);

  static Future<void> _setString(String key, String? value) async {
    try {
      final p = await _prefs();
      if (p == null) return;
      value == null ? await p.remove(key) : await p.setString(key, value);
    } catch (_) {}
  }

  // ── Language ────────────────────────────────────────────────────────

  static Future<String?> lang() => _getString(_langKey);
  static Future<void> setLang(String code) => _setString(_langKey, code);

  static Future<List<Map<String, dynamic>>?> languages() async {
    final raw = await _getString(_languagesKey);
    if (raw == null) return null;
    try {
      return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    } catch (_) {
      return null;
    }
  }

  static Future<void> setLanguages(List<Map<String, dynamic>> list) =>
      _setString(_languagesKey, jsonEncode(list));

  // ── Content ─────────────────────────────────────────────────────────

  static Future<File?> _contentPath([String suffix = '']) async {
    try {
      final dir = await getApplicationSupportDirectory();
      return File('${dir.path}/$_contentFile$suffix');
    } catch (_) {
      return null;
    }
  }

  static Future<({Map<String, dynamic> json, String? lang, String? etag})?>
  content() async {
    try {
      final file = await _contentPath();
      if (file == null || !await file.exists()) return null;
      final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      return (
        json: json,
        lang: await _getString(_contentLangKey),
        etag: await _getString(_contentEtagKey),
      );
    } catch (_) {
      return null;
    }
  }

  /// Replaces the stored payload atomically: write a temp file, then
  /// rename over the old one, then record its version. A crash midway
  /// leaves the previous payload intact (§5.2).
  static Future<void> saveContent({
    required Map<String, dynamic> json,
    required int version,
    required String lang,
    String? etag,
  }) async {
    try {
      final file = await _contentPath();
      final tmp = await _contentPath('.tmp');
      if (file == null || tmp == null) return;
      await tmp.writeAsString(jsonEncode(json), flush: true);
      await tmp.rename(file.path);
      final p = await _prefs();
      await p?.setInt(_contentVersionKey, version);
      await p?.setString(_contentLangKey, lang);
      etag == null
          ? await p?.remove(_contentEtagKey)
          : await p?.setString(_contentEtagKey, etag);
    } catch (_) {}
  }

  static Future<int?> contentVersion() async =>
      (await _prefs())?.getInt(_contentVersionKey);

  static Future<DateTime?> lastVersionCheck() async {
    final ms = (await _prefs())?.getInt(_lastVersionCheckKey);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  static Future<void> markVersionChecked() async {
    try {
      await (await _prefs())?.setInt(
        _lastVersionCheckKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (_) {}
  }

  static Future<void> clearVersionCheck() async {
    try {
      await (await _prefs())?.remove(_lastVersionCheckKey);
    } catch (_) {}
  }

  // ── Me ──────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> me() async {
    final raw = await _getString(_meKey);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> setMe(Map<String, dynamic>? json) =>
      _setString(_meKey, json == null ? null : jsonEncode(json));

  // ── Device id ───────────────────────────────────────────────────────

  static String? _deviceId;

  /// Generated once on first launch, never changes, survives sign-out.
  static Future<String> deviceId() async {
    if (_deviceId != null) return _deviceId!;
    final existing = await _getString(_deviceIdKey);
    if (existing != null) return _deviceId = existing;
    final id = uuidV4();
    await _setString(_deviceIdKey, id);
    return _deviceId = id;
  }

  // ── Event queue ─────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> eventQueue() async {
    final raw = await _getString(_eventQueueKey);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  static Future<void> setEventQueue(List<Map<String, dynamic>> events) =>
      _setString(_eventQueueKey, jsonEncode(events));
}

final _random = Random.secure();

/// RFC 4122 version-4 UUID from a secure RNG.
String uuidV4() {
  final b = List<int>.generate(16, (_) => _random.nextInt(256));
  b[6] = (b[6] & 0x0f) | 0x40;
  b[8] = (b[8] & 0x3f) | 0x80;
  final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
  return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-'
      '${h.substring(16, 20)}-${h.substring(20)}';
}
