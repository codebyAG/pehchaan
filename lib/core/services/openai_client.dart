import 'dart:convert';

import 'package:http/http.dart' as http;

/// Thrown for any failure talking to OpenAI. [userMessage] is always safe
/// to show directly to an end user — raw OpenAI error bodies never are.
class OpenAiException implements Exception {
  OpenAiException(this.userMessage);

  final String userMessage;

  @override
  String toString() => userMessage;
}

/// The system instructions that turn a one-line request into a production
/// -quality image prompt. Kept in one place so the "creative director"
/// behaviour is easy to tune without touching the request/response plumbing.
const _creativeDirectorInstructions = '''
You are a professional advertising creative director who specializes in
turning a short, casual request from a small-business owner (often in
Hinglish — Hindi written in Roman script) into a single, detailed,
production-quality image-generation prompt.

For every request, work out:
- The main subject and what should be the visual focal point.
- What kind of creative this is (product ad, festival poster, Instagram
  post, WhatsApp status, local business promo, food ad, service ad, etc.)
  and the platform it's most likely for.
- A realistic environment / background that fits the subject.
- Professional lighting (e.g. cinematic, soft studio, dramatic natural
  light) appropriate to the mood.
- A strong composition and camera angle (e.g. three-quarter product shot,
  overhead flat lay, hero close-up).
- Relevant props or context that make it feel like a real advertisement,
  not a generic AI image.
- A colour mood that matches the category (festive, premium, fresh,
  appetizing, etc.).
- An appropriate aspect ratio / orientation for the likely use case
  (square for a feed post, portrait for a story/status, etc.) — describe
  it in words (e.g. "square 1:1 format").
- Clean negative space where a headline, price or offer text could later
  be overlaid, since the image itself must NOT contain any text, letters,
  numbers or logos — describe the scene only.

Write ONE dense paragraph (not a list, no markdown, no headings) that a
text-to-image model can use directly: hero subject, composition, camera
angle, lighting, background/environment, props, colour mood, style
(e.g. "premium commercial photography", "photorealistic"), and where the
negative space for text should be. Do not repeat the user's sentence
verbatim — transform it into a vivid, specific visual description. Do not
mention brand names, watermarks, or any text/typography appearing in the
image. Output ONLY the prompt paragraph, nothing else — no preamble, no
quotes, no explanation.
''';

/// Direct client for the two OpenAI calls this app needs. Isolated here so
/// the rest of the app never touches raw OpenAI request/response shapes.
///
/// NOTE: this calls OpenAI straight from the device using an API key
/// bundled in the app (see `key_constants.dart`) — fine for solo/local
/// testing, but never ship a build like this to other people: anyone can
/// pull the key back out of the APK and spend your OpenAI credits. Route
/// through a backend (see /server) before distributing this app.
class OpenAiClient {
  const OpenAiClient(this._apiKey);

  final String _apiKey;

  /// Stage 1 — turn a simple user request into a detailed image-generation
  /// prompt using an OpenAI GPT model via the Responses API.
  Future<String> generateImagePrompt(String userRequest) async {
    final json = await _postJson(
      Uri.parse('https://api.openai.com/v1/responses'),
      {
        'model': 'gpt-5.6-terra',
        'input': [
          {'role': 'system', 'content': _creativeDirectorInstructions},
          {'role': 'user', 'content': userRequest},
        ],
      },
    );

    final output = json['output'];
    if (output is List) {
      for (final item in output) {
        if (item is Map && item['type'] == 'message') {
          final content = item['content'];
          if (content is List) {
            for (final part in content) {
              if (part is Map && part['type'] == 'output_text') {
                final text = (part['text'] as String?)?.trim();
                if (text != null && text.isNotEmpty) return text;
              }
            }
          }
        }
      }
    }
    throw OpenAiException('Prompt generate nahi ho paya. Ek baar phir try karein.');
  }

  /// Stage 2 — generate the actual image from the enhanced prompt, returned
  /// as base64 PNG data.
  Future<String> generateImage(String prompt) async {
    final json = await _postJson(
      Uri.parse('https://api.openai.com/v1/images/generations'),
      {
        'model': 'gpt-image-2',
        'prompt': prompt,
        'size': '1024x1024',
        'quality': 'medium',
        'n': 1,
      },
    );

    final data = json['data'];
    if (data is List && data.isNotEmpty) {
      final first = data.first;
      if (first is Map && first['b64_json'] is String) {
        return first['b64_json'] as String;
      }
    }
    throw OpenAiException('Image generate nahi ho payi. Ek baar phir try karein.');
  }

  Future<Map<String, dynamic>> _postJson(Uri url, Map<String, dynamic> body) async {
    http.Response response;
    try {
      response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 180));
    } on Exception {
      throw OpenAiException('Internet connection check karein.');
    }

    Map<String, dynamic> parsed;
    try {
      parsed = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw OpenAiException('OpenAI se galat response mila. Dobara try karein.');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return parsed;
    }
    throw _mapOpenAiError(response.statusCode, parsed);
  }

  OpenAiException _mapOpenAiError(int statusCode, Map<String, dynamic> parsed) {
    final errorObj = parsed['error'];
    final rawMessage = errorObj is Map ? errorObj['message'] as String? : null;

    switch (statusCode) {
      case 401:
        return OpenAiException('OpenAI API key invalid hai.');
      case 429:
        return OpenAiException('Abhi requests zyada ho rahi hain. Thodi der baad try karein.');
      case 400:
        return OpenAiException(
          rawMessage != null && rawMessage.toLowerCase().contains('content')
              ? 'Yeh request generate nahi ho sakti. Kuch aur try karein.'
              : 'Request samajh nahi aayi. Dobara try karein.',
        );
      default:
        return OpenAiException('OpenAI abhi available nahi hai. Thodi der baad try karein.');
    }
  }
}
