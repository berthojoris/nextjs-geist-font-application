class SupabaseConfig {
  // TODO: Replace with your Supabase project URL
  static const String url = 'YOUR_PROJECT_URL';
  
  // TODO: Replace with your Supabase anon/public key
  static const String anonKey = 'YOUR_ANON_KEY';
  
  // Device identification
  static String? _deviceId;
  
  static String get deviceId {
    _deviceId ??= DateTime.now().millisecondsSinceEpoch.toString();
    return _deviceId!;
  }
}
