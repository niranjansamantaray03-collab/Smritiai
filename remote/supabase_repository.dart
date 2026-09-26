
import '../../core/backend/backend_config.dart';

class SupabaseRepository {
  SupabaseRepository._();

  static final SupabaseRepository
      instance =
      SupabaseRepository._();

  bool get configured =>
      BackendConfig.isConfigured;

  Future<void> initialize() async {
    if (!configured) {
      return;
    }

    // Production Android initialization:
    //
    // await Supabase.initialize(
    //   url: BackendConfig.supabaseUrl,
    //   anonKey: BackendConfig.supabaseAnonKey,
    // );
    //
    // The SDK dependency is deliberately not
    // installed during development on this Mac.
  }

  Future<void> signOut() async {
    // Production:
    // Supabase.instance.client.auth.signOut();
  }

  Future<Map<String, dynamic>?>
      currentAuthUser() async {
    // Production:
    // return Supabase auth user metadata.
    return null;
  }

  Future<void> save(
    String table,
    Map<String, dynamic> data,
  ) async {
    if (!configured) {
      throw StateError(
        'Supabase is not configured.',
      );
    }

    // Production:
    // await client.from(table).upsert(data);
  }

  Future<List<Map<String, dynamic>>>
      queryPatientTable(
    String table,
    String patientId,
  ) async {
    if (!configured) {
      throw StateError(
        'Supabase is not configured.',
      );
    }

    // Production query is intentionally
    // hidden behind this repository.
    return const [];
  }
}
