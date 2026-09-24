/// Runtime configuration for services that must never be hard-coded in source.
///
/// Supply values with `flutter run --dart-define=NAME=value`.  Do not commit a
/// real configuration file, API token, service-role key, or OAuth secret.
abstract final class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabasePublishableKey =
      String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
  static const backendBaseUrl = String.fromEnvironment('BACKEND_BASE_URL');

  static bool get hasSupabaseConfiguration =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;

  static bool get hasBackendConfiguration => backendBaseUrl.isNotEmpty;

  static void requireBackendConfiguration() {
    if (!hasBackendConfiguration) {
      throw StateError(
        'BACKEND_BASE_URL is not configured. Supply it with --dart-define.',
      );
    }
  }
}
