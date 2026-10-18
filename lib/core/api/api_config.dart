/// Build-time configuration for the Pehchaan backend.
///
/// Override per build with `--dart-define`, e.g.
/// `flutter run --dart-define=API_BASE_URL=http://1.2.3.4:3012`.
class ApiConfig {
  ApiConfig._();

  /// Staging is plain HTTP until the custom domain arrives. The default is
  /// the Android emulator's alias for the host machine.
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3012',
  );

  /// Sales number the "buy plan" CTA opens WhatsApp / a call to (§9.3).
  /// Ten digits, no +91. Empty until the product owner shares it.
  static const salesPhone = String.fromEnvironment('SALES_PHONE');

  /// Placeholder video URLs per slot until `/v1/content` carries them.
  /// Empty means "show the bundled poster placeholder".
  static const onboardingVideoUrl = String.fromEnvironment('ONBOARDING_VIDEO_URL');
  static const fallbackWelcomeVideoUrl = String.fromEnvironment('WELCOME_VIDEO_URL');
  static const testimonialVideoUrls = String.fromEnvironment('TESTIMONIAL_VIDEO_URLS');

  static Uri uri(String path, [Map<String, String>? query]) =>
      Uri.parse('$baseUrl$path').replace(queryParameters: query);
}
