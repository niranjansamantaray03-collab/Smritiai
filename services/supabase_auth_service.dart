
import '../core/backend/production_backend.dart';
import '../data/remote/supabase_data_service.dart';

class SupabaseAuthService {
  SupabaseAuthService._();

  static final SupabaseAuthService instance = SupabaseAuthService._();

  bool get available => SupabaseDataService.instance.available;

  String? get currentUserId =>
      ProductionBackend.instance.currentUser?.id;

  String? get currentEmail =>
      ProductionBackend.instance.currentUser?.email;

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    final result = await SupabaseDataService.instance.signIn(
      email: email,
      password: password,
    );

    return result?.user != null;
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
    String language = 'en',
  }) async {
    final result = await SupabaseDataService.instance.signUp(
      email: email,
      password: password,
      name: name,
      role: role,
      language: language,
    );

    return result?.user != null;
  }

  Future<void> signOut() {
    return SupabaseDataService.instance.signOut();
  }
}
