import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseRuntime {
  SupabaseRuntime._();

  static bool get available {
    try {
      return Supabase.instance.client.auth.currentSession != null ||
          Supabase.instance.client.rest != null;
    } catch (_) {
      return false;
    }
  }

  static SupabaseClient? get client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  static User? get currentUser {
    return client?.auth.currentUser;
  }
}
