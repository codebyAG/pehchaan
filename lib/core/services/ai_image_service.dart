/// Thrown for any failure generating an AI image. [message] is always
/// safe to show directly to the user.
class AiImageException implements Exception {
  AiImageException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// The single seam for AI image generation.
///
/// The app used to call OpenAI directly with a key bundled in the APK.
/// That's gone: no key may ship in the app, and the Pehchaan API
/// (APP-INTEGRATION.md) has no generation endpoint yet. Until the backend
/// provides one, [isAvailable] is false and the UI hides the AI entry
/// points. When the endpoint lands, implement [generateImage] against it
/// (via `PehchaanApi`, authenticated) and flip [isAvailable].
class AiImageService {
  const AiImageService();

  static const isAvailable = false;

  Future<List<int>> generateImage(String userRequest) async {
    throw AiImageException('AI creatives jaldi aa rahe hain.');
  }
}
