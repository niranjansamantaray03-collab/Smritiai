
import 'media_repository.dart';

class SupabaseMediaRepository
    implements MediaRepository {
  SupabaseMediaRepository();

  @override
  Future<String?> uploadPhoto({
    required String patientId,
    required String localPath,
    required String fileName,
  }) async {
    // Production implementation:
    //
    // Supabase Storage bucket:
    // memory-photos
    //
    // Private path:
    // patients/<patientId>/photos/<fileName>
    //
    // The service-role key must never be used here.

    return null;
  }

  @override
  Future<String?> uploadAudio({
    required String patientId,
    required String localPath,
    required String fileName,
  }) async {
    // Production implementation:
    // memory-audio/patients/<patientId>/...
    return null;
  }

  @override
  Future<void> deleteMedia({
    required String patientId,
    required String path,
  }) async {
    // Production deletion through authenticated
    // Supabase client.
  }
}
