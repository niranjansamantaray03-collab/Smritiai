
import '../remote/supabase_data_service.dart';

class SupabaseSyncService {
  SupabaseSyncService._();

  static final SupabaseSyncService instance = SupabaseSyncService._();

  final SupabaseDataService _cloud = SupabaseDataService.instance;

  bool get available => _cloud.available;

  Future<Map<String, dynamic>> pullPatientData(
    String patientId,
  ) async {
    if (!available) {
      return {};
    }

    final results = await Future.wait([
      _cloud.getRudasAssessments(patientId),
      _cloud.getRudasCheckpoints(patientId),
      _cloud.getGameSessions(patientId),
      _cloud.getTasks(patientId),
      _cloud.getReminders(patientId),
      _cloud.getMemoryStories(patientId),
      _cloud.getMemoryPeople(patientId),
      _cloud.getMemoryMedia(patientId),
      _cloud.getMoodEntries(patientId),
      _cloud.getStoryRecalls(patientId),
    ]);

    return {
      'rudas_assessments': results[0],
      'rudas_checkpoints': results[1],
      'game_sessions': results[2],
      'tasks': results[3],
      'reminders': results[4],
      'memory_stories': results[5],
      'memory_people': results[6],
      'memory_media': results[7],
      'mood_entries': results[8],
      'story_recall_events': results[9],
      'synced_at': DateTime.now().toIso8601String(),
    };
  }

  Future<int> completedGameSessions(
    String patientId,
  ) {
    return _cloud.countCompletedGameSessions(patientId);
  }
}
