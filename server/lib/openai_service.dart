import 'dart:convert';
import 'dart:io';

/// Thrown for any failure talking to OpenAI. [userMessage] is always safe
/// to show directly to an end user — raw OpenAI error bodies never are.
class OpenAiException implements Exception {
  OpenAiException(this.userMessage, {this.statusCode = 502});

  final String userMessage;
  final int statusCode;

  @override
  String toString() => 'OpenAiException($statusCode): $userMessage';
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

/// Stage 1 — turn a simple user request into a detailed image-generation
/// prompt using an OpenAI GPT model via the Responses API.
Future<String> generateImagePrompt(String userRequest, {required String apiKey}) async {
  final body = {
    'model': 'gpt-5.6-terra',
    'input': [
      {
        'role': 'system',
        'content': _creativeDirectorInstructions,
      },
      {
        'role': 'user',
        'content': userRequest,
      },
    ],
  };

  final json = await _postJson(
    Uri.parse('https://api.openai.com/v1/responses'),
    apiKey: apiKey,
    body: body,
  );

  final output = json['output'];
  if (output is! List) {
    throw OpenAiException('Prompt generate nahi ho paya. Ek baar phir try karein.');
  }

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

  throw OpenAiException('Prompt generate nahi ho paya. Ek baar phir try karein.');
}

/// Stage 2 — generate the actual image from the enhanced prompt using
/// OpenAI's image generation model, returned as base64 PNG data.
Future<String> generateImage(String prompt, {required String apiKey}) async {
  final body = {
    // gpt-image-2.5-sunburst (Sept 2026) — OpenAI's precision-focused
    // image model, built for premium production-ready campaign creative.
    'model': 'gpt-image-2.5-sunburst',
    'prompt': prompt,
    'size': '1024x1024',
    // "max" is the best of its six quality levels — slower (a few
    // minutes) but the sharpest, most polished result.
    'quality': 'max',
    'n': 1,
  };

  final json = await _postJson(
    Uri.parse('https://api.openai.com/v1/images/generations'),
    apiKey: apiKey,
    body: body,
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

Future<Map<String, dynamic>> _postJson(
  Uri url, {
  required String apiKey,
  required Map<String, dynamic> body,
}) async {
  final client = HttpClient();
  client.connectionTimeout = const Duration(seconds: 20);
  try {
    final request = await client.postUrl(url).timeout(
          const Duration(seconds: 20),
          onTimeout: () => throw OpenAiException('Network slow hai. Dobara try karein.', statusCode: 504),
        );
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $apiKey');
    request.add(utf8.encode(jsonEncode(body)));

    final response = await request.close().timeout(
          const Duration(seconds: 300),
          onTimeout: () => throw OpenAiException('OpenAI se response nahi aaya. Dobara try karein.', statusCode: 504),
        );
    final raw = await response.transform(utf8.decoder).join();

    Map<String, dynamic> parsed;
    try {
      parsed = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      throw OpenAiException('OpenAI se galat response mila. Dobara try karein.');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return parsed;
    }

    throw _mapOpenAiError(response.statusCode, parsed);
  } on OpenAiException {
    rethrow;
  } on SocketException {
    throw OpenAiException('Internet connection check karein.', statusCode: 503);
  } on HttpException {
    throw OpenAiException('Network mein dikkat aayi. Dobara try karein.', statusCode: 503);
  } catch (_) {
    throw OpenAiException('Kuch galat ho gaya. Dobara try karein.');
  } finally {
    client.close(force: true);
  }
}

OpenAiException _mapOpenAiError(int statusCode, Map<String, dynamic> parsed) {
  final errorObj = parsed['error'];
  final rawMessage = errorObj is Map ? errorObj['message'] as String? : null;

  switch (statusCode) {
    case 401:
      return OpenAiException('OpenAI API key invalid hai. Server ka OPENAI_API_KEY check karein.', statusCode: 401);
    case 429:
      return OpenAiException('Abhi requests zyada ho rahi hain. Thodi der baad try karein.', statusCode: 429);
    case 400:
      return OpenAiException(
        rawMessage != null && rawMessage.toLowerCase().contains('content')
            ? 'Yeh request generate nahi ho sakti. Kuch aur try karein.'
            : 'Request samajh nahi aayi. Dobara try karein.',
        statusCode: 400,
      );
    default:
      return OpenAiException('OpenAI abhi available nahi hai. Thodi der baad try karein.', statusCode: 502);
  }
}
