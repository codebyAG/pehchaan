import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthTokens {
  const AuthTokens({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;

  factory AuthTokens.fromJson(Map<String, dynamic> json) => AuthTokens(
    accessToken: json['access_token'] as String? ?? '',
    refreshToken: json['refresh_token'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'access_token': accessToken,
    'refresh_token': refreshToken,
  };
}

/// Access + refresh tokens in secure storage, always written together as one
/// value so a crash can never leave a mismatched pair behind (§6.5, §13).
class TokenStore {
  TokenStore._();

  static const _key = 'pehchaan.tokens';
  static const _storage = FlutterSecureStorage();

  static AuthTokens? _cached;

  static Future<AuthTokens?> read() async {
    if (_cached != null) return _cached;
    try {
      final raw = await _storage.read(key: _key);
      if (raw == null) return null;
      _cached = AuthTokens.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      return _cached;
    } catch (_) {
      return null;
    }
  }

  static Future<void> write(AuthTokens tokens) async {
    _cached = tokens;
    try {
      await _storage.write(key: _key, value: jsonEncode(tokens.toJson()));
    } catch (_) {
      // Keep the in-memory pair; the next successful write persists it.
    }
  }

  static Future<void> clear() async {
    _cached = null;
    try {
      await _storage.delete(key: _key);
    } catch (_) {}
  }
}
