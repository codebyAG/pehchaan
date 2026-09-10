import 'dart:convert';
import 'dart:typed_data';

import 'package:pehchaan/core/constants/key_constants.dart';
import 'openai_client.dart';
import 'watermark.dart';

/// Thrown for any failure generating an AI image. [message] is always
/// safe to show directly to the user.
class AiImageException implements Exception {
  AiImageException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Runs the two-stage AI image flow — user request -> GPT-enhanced prompt
/// -> generated image — directly against OpenAI using the key in
/// `key_constants.dart`.
///
/// This is the solo/local-testing setup: fine as long as this build never
/// leaves your own device. For anything shared with other people, put the
/// key back behind a backend (see /server) instead.
class AiImageService {
  const AiImageService();

  Future<List<int>> generateImage(String userRequest) async {
    if (CHAT_GPT_KEY.isEmpty) {
      throw AiImageException('OpenAI API key set nahi hai (key_constants.dart).');
    }

    final client = OpenAiClient(CHAT_GPT_KEY);
    try {
      final prompt = await client.generateImagePrompt(userRequest);
      final base64Image = await client.generateImage(prompt);
      Uint8List bytes;
      try {
        bytes = base64Decode(base64Image);
      } catch (_) {
        throw AiImageException('Image load nahi ho payi. Dobara try karein.');
      }
      try {
        return await addWatermark(bytes);
      } catch (_) {
        // Watermarking is a nice-to-have — never let it block the result.
        return bytes;
      }
    } on OpenAiException catch (e) {
      throw AiImageException(e.userMessage);
    }
  }
}
