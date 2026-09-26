
class BackendConfig {
  BackendConfig._();

  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL');

  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  static const String environment =
      String.fromEnvironment(
        'SMRITIAI_ENV',
        defaultValue: 'development',
      );

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty &&
      supabaseUrl.startsWith('https://') &&
      supabaseUrl.contains('.supabase.co');

  static bool get isProduction =>
      environment.toLowerCase() == 'production';

  static bool get isDevelopment =>
      !isProduction;
}
