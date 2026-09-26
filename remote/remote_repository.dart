/// Backend-independent contract.
///
/// Local repositories can implement this now.
/// Supabase implementation can be attached during the
/// cloud connection/build stage without rewriting screens.
abstract class RemoteRepository {
  Future<Map<String, dynamic>?> getProfile(String userId);

  Future<void> createProfile(
    Map<String, dynamic> data,
  );

  Future<void> updateProfile(
    String userId,
    Map<String, dynamic> data,
  );

  Future<List<Map<String, dynamic>>> getPatientTasks(
    String patientId,
  );

  Future<List<Map<String, dynamic>>> getGameSessions(
    String patientId,
  );

  Future<List<Map<String, dynamic>>> getRudasAssessments(
    String patientId,
  );

  Future<List<Map<String, dynamic>>> getMemoryStories(
    String patientId,
  );

  Future<List<Map<String, dynamic>>> getMemoryPhotos(
    String patientId,
  );

  Future<List<Map<String, dynamic>>> getMoodEntries(
    String patientId,
  );
}
