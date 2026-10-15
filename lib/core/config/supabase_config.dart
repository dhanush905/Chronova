/// Secure compile-time configuration for Supabase in Chronova.
/// Reads SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY passed via --dart-define.
/// Never log or hardcode secret keys.
class SupabaseConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  /// True when both URL and Publishable Key have been provided.
  static bool get isConfigured =>
      supabaseUrl.trim().isNotEmpty &&
      supabasePublishableKey.trim().isNotEmpty &&
      supabaseUrl.startsWith('http');
}
