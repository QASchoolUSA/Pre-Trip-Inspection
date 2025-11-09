class SupabaseConfig {
  // Defaults for cloud Supabase (HTTPS) — overridden via --dart-define in builds
  static const String _defaultUrl = "https://ybatcvqdvenpmiqizbca.supabase.co";
  static const String _defaultAnonKey =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InliYXRjdnFkdmVucG1pcWl6YmNhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI2OTc5NTYsImV4cCI6MjA3ODI3Mzk1Nn0.aSo9bxPXu_0GoS3ZstBrcFKU5556GuKGoFDZj4VCyn4";

  // Override with: --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: _defaultUrl);
  static const String supabaseAnonKey = String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: _defaultAnonKey);

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}