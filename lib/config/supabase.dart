import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://idqvgxvhpgxapjeuipig.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlkcXZneHZocGd4YXBqZXVpcGlnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMxNzYxOTUsImV4cCI6MjA5ODc1MjE5NX0.lEB3RZz-tsWmXwtLODP_fPVWykyM1Ck2h0X0BqVnMKE';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: anonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
