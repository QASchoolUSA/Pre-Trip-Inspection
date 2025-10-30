class SupabaseConfig {
  // Self-hosted Supabase configuration from Coolify
  static const String supabaseUrl = "http://supabasekong-ygcsg4oskowsss4cc40ckskw.152.53.240.47.sslip.io";
  static const String supabaseAnonKey = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzdXBhYmFzZSIsImlhdCI6MTc2MTYwNjQyMCwiZXhwIjo0OTE3MjgwMDIwLCJyb2xlIjoiYW5vbiJ9.IpPTUxcEXBCOatste0JkpiMCoQXjvhkbnMadyaZL1IQ";

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}