import 'dart:convert';
import 'dart:io';

import 'package:pehchaan_server/openai_service.dart';

/// Minimal local backend for the Pehchaan AI image MVP.
///
/// Holds the OpenAI API key server-side (never shipped in the Flutter app)
/// and exposes one endpoint the app calls:
///
///   POST /generate-image   { "request": "Jeera ka premium poster banao" }
///   ->   200 { "success": true, "imageBase64": "..." }
///   ->   4xx/5xx { "success": false, "error": "a user-friendly message" }
///
/// Run with:
///   OPENAI_API_KEY=sk-... dart run bin/server.dart
/// or drop a `.env` file next to this one with OPENAI_API_KEY=sk-...
Future<void> main() async {
  final apiKey = _loadApiKey();
  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;

  final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  stdout.writeln('Pehchaan AI server listening on http://0.0.0.0:$port');
  if (apiKey == null) {
    stdout.writeln(
      'WARNING: OPENAI_API_KEY not set. Every request will fail until you set it '
      '(env var or server/.env) and restart.',
    );
  }

  await for (final request in server) {
    _handle(request, apiKey);
  }
}

Future<void> _handle(HttpRequest request, String? apiKey) async {
  // Minimal CORS so this also works from `flutter run -d chrome` during testing.
  request.response.headers.set('Access-Control-Allow-Origin', '*');
  request.response.headers.set('Access-Control-Allow-Headers', 'Content-Type');
  request.response.headers.set('Access-Control-Allow-Methods', 'POST, OPTIONS');

  if (request.method == 'OPTIONS') {
    request.response.statusCode = HttpStatus.noContent;
    await request.response.close();
    return;
  }

  if (request.method != 'POST' || request.uri.path != '/generate-image') {
    await _respondJson(request, HttpStatus.notFound, {
      'success': false,
      'error': 'Not found.',
    });
    return;
  }

  if (apiKey == null || apiKey.isEmpty) {
    await _respondJson(request, HttpStatus.internalServerError, {
      'success': false,
      'error': 'Server configure nahi hai. OPENAI_API_KEY set karein.',
    });
    return;
  }

  String userRequest;
  try {
    final raw = await utf8.decodeStream(request);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    userRequest = (json['request'] as String?)?.trim() ?? '';
  } catch (_) {
    await _respondJson(request, HttpStatus.badRequest, {
      'success': false,
      'error': 'Request sahi format mein nahi hai.',
    });
    return;
  }

  if (userRequest.isEmpty) {
    await _respondJson(request, HttpStatus.badRequest, {
      'success': false,
      'error': 'Pehle batayein aapko kaisi image chahiye.',
    });
    return;
  }

  try {
    final enhancedPrompt = await generateImagePrompt(userRequest, apiKey: apiKey);
    final imageBase64 = await generateImage(enhancedPrompt, apiKey: apiKey);
    await _respondJson(request, HttpStatus.ok, {
      'success': true,
      'imageBase64': imageBase64,
    });
  } on OpenAiException catch (e) {
    await _respondJson(request, e.statusCode, {
      'success': false,
      'error': e.userMessage,
    });
  } catch (e) {
    stderr.writeln('Unexpected error: $e');
    await _respondJson(request, HttpStatus.internalServerError, {
      'success': false,
      'error': 'Kuch galat ho gaya. Dobara try karein.',
    });
  }
}

Future<void> _respondJson(HttpRequest request, int statusCode, Map<String, dynamic> body) async {
  request.response.statusCode = statusCode;
  request.response.headers.contentType = ContentType.json;
  request.response.write(jsonEncode(body));
  await request.response.close();
}

/// Accepted names for the key, in priority order. `OPENAI_API_KEY` is the
/// canonical one; the others are accepted so a `.env` dropped in by hand
/// still works without edits.
const _apiKeyNames = ['OPENAI_API_KEY', 'CHAT_GPT_KEY', 'OPENAI_KEY'];

/// Checks env vars first, then a `KEY=value` line in a `.env` file — looked
/// for next to this script (`server/.env`) and one level up (the Flutter
/// project root `.env`), so it works wherever it's dropped (simple,
/// dependency-free).
String? _loadApiKey() {
  for (final name in _apiKeyNames) {
    final fromEnv = Platform.environment[name];
    if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
  }

  for (final path in ['.env', '../.env']) {
    final envFile = File(path);
    if (!envFile.existsSync()) continue;

    for (final line in envFile.readAsLinesSync()) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
      final eq = trimmed.indexOf('=');
      if (eq == -1) continue;
      final key = trimmed.substring(0, eq).trim();
      if (_apiKeyNames.contains(key)) {
        var value = trimmed.substring(eq + 1).trim();
        if (value.length >= 2 && value.startsWith('"') && value.endsWith('"')) {
          value = value.substring(1, value.length - 1);
        }
        if (value.isNotEmpty) return value;
      }
    }
  }
  return null;
}
