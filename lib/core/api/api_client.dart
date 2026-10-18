import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'token_store.dart';

/// Any failed backend call. [statusCode] is 0 when the request never got a
/// response (offline, timeout). [message] is the server's `error` text when
/// it sent one.
class ApiException implements Exception {
  ApiException(this.statusCode, this.message, {this.retryAfterSec});

  final int statusCode;
  final String message;
  final int? retryAfterSec;

  bool get isNetwork => statusCode == 0;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiResponse {
  ApiResponse(this.statusCode, this.json, this.headers);

  final int statusCode;
  final Map<String, dynamic> json;
  final Map<String, String> headers;
}

/// Thin HTTP layer over the Pehchaan API.
///
/// Golden rule (§3): the bearer token goes only to `/v1/auth/*` and
/// `/v1/me*`. Public calls go through [get]/[post]; authenticated ones
/// through [authed], which also owns the refresh-once-and-retry flow.
class ApiClient {
  ApiClient._();

  static final instance = ApiClient._();

  static const _timeout = Duration(seconds: 20);
  static const _uploadTimeout = Duration(seconds: 90);

  final http.Client _http = http.Client();

  /// Called when the refresh token itself is rejected — the session is
  /// gone and the app must go back to the phone screen.
  void Function()? onSessionExpired;

  Future<String?>? _refreshInFlight;

  // ── Public (unauthenticated) ────────────────────────────────────────

  Future<ApiResponse> get(
    String path, {
    Map<String, String>? query,
    Map<String, String>? headers,
  }) {
    return _send(
      () => _http.get(ApiConfig.uri(path, query), headers: headers),
    );
  }

  Future<ApiResponse> post(String path, Map<String, dynamic> body) {
    return _send(
      () => _http.post(
        ApiConfig.uri(path),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ),
    );
  }

  // ── Authenticated ───────────────────────────────────────────────────

  Future<ApiResponse> authed(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) {
    return _withAuth((token) {
      final request = http.Request(method, ApiConfig.uri(path))
        ..headers['Authorization'] = 'Bearer $token';
      if (body != null) {
        request.headers['Content-Type'] = 'application/json';
        request.body = jsonEncode(body);
      }
      return _http.send(request).then(http.Response.fromStream);
    });
  }

  Future<ApiResponse> upload({
    required String kind,
    required Uint8List bytes,
    required String filename,
  }) {
    return _withAuth((token) {
      // `kind` must be written before the file (§8.3) — MultipartRequest
      // always emits fields ahead of files.
      final request =
          http.MultipartRequest('POST', ApiConfig.uri('/v1/me/uploads'))
            ..headers['Authorization'] = 'Bearer $token'
            ..fields['kind'] = kind
            ..files.add(
              http.MultipartFile.fromBytes('file', bytes, filename: filename),
            );
      return _http.send(request).then(http.Response.fromStream);
    }, timeout: _uploadTimeout);
  }

  Future<ApiResponse> _withAuth(
    Future<http.Response> Function(String token) send, {
    Duration timeout = _timeout,
  }) async {
    final tokens = await TokenStore.read();
    if (tokens == null) {
      onSessionExpired?.call();
      throw ApiException(401, 'Not signed in');
    }
    try {
      return await _send(() => send(tokens.accessToken), timeout: timeout);
    } on ApiException catch (e) {
      if (e.statusCode != 401) rethrow;
      final fresh = await refreshAccessToken();
      if (fresh == null) rethrow;
      return _send(() => send(fresh), timeout: timeout);
    }
  }

  /// Single-flight refresh: parallel 401s share one refresh call, so they
  /// can't rotate the pair out from under each other (§6.5). Returns the
  /// new access token, or null when the session is over.
  Future<String?> refreshAccessToken() {
    return _refreshInFlight ??= _doRefresh().whenComplete(
      () => _refreshInFlight = null,
    );
  }

  Future<String?> _doRefresh() async {
    final tokens = await TokenStore.read();
    if (tokens == null) return null;
    try {
      final res = await post('/v1/auth/refresh', {
        'refresh_token': tokens.refreshToken,
      });
      final fresh = AuthTokens.fromJson(
        res.json['tokens'] as Map<String, dynamic>,
      );
      // Both tokens rotate — persist before any further request.
      await TokenStore.write(fresh);
      return fresh.accessToken;
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await TokenStore.clear();
        onSessionExpired?.call();
      }
      return null;
    }
  }

  // ── Plumbing ────────────────────────────────────────────────────────

  Future<ApiResponse> _send(
    Future<http.Response> Function() send, {
    Duration timeout = _timeout,
  }) async {
    http.Response res;
    try {
      res = await send().timeout(timeout);
    } catch (_) {
      throw ApiException(0, 'Network error');
    }

    Map<String, dynamic> json = const {};
    if (res.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));
        if (decoded is Map<String, dynamic>) json = decoded;
      } catch (_) {
        // Non-JSON body; status code still tells the story.
      }
    }

    if (res.statusCode >= 200 && res.statusCode < 400) {
      return ApiResponse(res.statusCode, json, res.headers);
    }
    throw ApiException(
      res.statusCode,
      json['error'] as String? ?? 'Request failed (${res.statusCode})',
      retryAfterSec: (json['retry_after_sec'] as num?)?.toInt(),
    );
  }
}
