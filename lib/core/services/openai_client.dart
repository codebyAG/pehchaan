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
production-quality image-generation prompt — the kind of finished poster
a real design agency would deliver, with the offer/price and business
name actually printed on it, not a bare product photo.

The request will usually include specific details — an offer or product
name, a price, an occasion, and the business's name/category/location.
Treat these as content that MUST appear as real, legible typography
baked into the image itself:
- The offer/product headline as a bold, short headline.
- The price as a large, prominent price callout (e.g. "₹799"), styled
  like a price tag, starburst, or ribbon badge — a natural design element
  for the category (festive badge for a festival offer, clean price tag
  for a product, etc.).
- The business name (and city if given) as a smaller signature line,
  positioned like a footer/nameplate — the way real local-business
  posters always credit the shop.
Keep this text short and exact — reproduce the headline, price and
business name the user gave verbatim, do not invent extra text, and do
not add any other words, numbers or logos beyond what was actually given.

For every request, also work out:
- The main subject and what should be the visual focal point.
- What kind of creative this is (product ad, festival poster, Instagram
  post, WhatsApp status, local business promo, food ad, service ad, etc.)
  and the platform it's most likely for.
- A realistic environment / background that fits the subject.
- Professional lighting (e.g. cinematic, soft studio, dramatic natural
  light) appropriate to the mood.
- A strong composition and camera angle (e.g. three-quarter product shot,
  overhead flat lay, hero close-up) that leaves natural, uncluttered space
  for the headline, price badge and business signature to sit legibly.
- Relevant props or context that make it feel like a real advertisement,
  not a generic AI image.
- A colour mood that matches the category (festive, premium, fresh,
  appetizing, etc.), and a typography style (bold sans-serif, elegant
  script for premium, playful for festive, etc.) that matches that mood.
- An appropriate aspect ratio / orientation for the likely use case
  (square for a feed post, portrait for a story/status, etc.) — describe
  it in words (e.g. "square 1:1 format").

Write ONE dense paragraph (not a list, no markdown, no headings) that a
text-to-image model can use directly: hero subject, composition, camera
angle, lighting, background/environment, props, colour mood, style
(e.g. "premium commercial photography", "photorealistic"), the exact
headline/price/business-name text to render and where each sits, and the
typography style for each. Do not repeat the user's raw sentence
verbatim as the scene description — transform it into a vivid, specific
visual description, but DO keep the offer/price/business-name text
itself exact. Output ONLY the prompt paragraph, nothing else — no
preamble, no quotes, no explanation.
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
        // gpt-image-2.5-sunburst (Sept 2026) — OpenAI's precision-focused
        // image model, built for premium production-ready campaign
        // creative, which is exactly this app's use case. "max" is the
        // best of its six quality levels; it's slower than "high" but
        // gives the sharpest, most polished result.
        'model': 'gpt-image-2.5-sunburst',
        'prompt': prompt,
        'size': '1024x1024',
        'quality': 'max',
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
          .timeout(const Duration(seconds: 300));
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
